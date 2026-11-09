#!/usr/bin/env bash
# PreToolUse(Bash) guard.
# 1. Blocks destructive git commands (reset --hard, clean -f, checkout -- / ., restore) on a dirty tree.
# 2. Blocks pushes to the base branch and force-pushes to it.
# Stdin: hook JSON with .tool_input.command and .cwd. Denies via hookSpecificOutput.permissionDecision.
set -uo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
[ -z "$cmd" ] && exit 0
case "$cmd" in *git*) ;; *) exit 0 ;; esac

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

cd "${cwd:-${CLAUDE_PROJECT_DIR:-.}}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

cfg="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}/.claude/sdlc.json"
base="main"
if [ -f "$cfg" ]; then base="$(jq -r '.baseBranch // "main"' "$cfg" 2>/dev/null || echo main)"; fi

# "git" possibly as /usr/bin/git, with optional global flags like -C <dir>
G='(^|[;&|[:space:]({])(/usr/bin/|/opt/homebrew/bin/|/usr/local/bin/)?git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+'

# --- 1. destructive commands on a dirty tree --------------------------------
destructive="${G}(reset[[:space:]]+(.*[[:space:]])?--hard|clean[[:space:]]+(.*[[:space:]])?-[a-zA-Z]*f|checkout[[:space:]]+(.*[[:space:]])?(--[[:space:]]|\.([[:space:]]|$))|restore[[:space:]]+([^-]|-[^-]|--(worktree|source)))"
if printf '%s' "$cmd" | grep -qE "$destructive"; then
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    deny "BLOCKED by sdlc guard: destructive git command on a dirty working tree. Uncommitted work would be lost. Run 'git status', then 'git stash push -u' (recoverable) or commit before retrying."
  fi
fi

# --- 2. pushes to the base branch -------------------------------------------
if printf '%s' "$cmd" | grep -qE "${G}push([[:space:]]|$)"; then
  current="$(git branch --show-current 2>/dev/null)"
  push_part="$(printf '%s' "$cmd" | grep -oE "${G}push[^;&|]*" | head -1)"
  # Explicit refspec naming the base branch (main, HEAD:main, refs/heads/main, +main)
  if printf '%s' "$push_part" | grep -qE "[[:space:]:+/]${base}([[:space:]]|$)"; then
    deny "BLOCKED by sdlc guard: pushing to the base branch '${base}'. Push a feature branch and open a pull request instead."
  fi
  # Implicit push while on the base branch (no refspec, or only a remote name)
  if [ "$current" = "$base" ]; then
    deny "BLOCKED by sdlc guard: you are on '${base}'. Create a feature branch ('git switch -c <type>/<issue>-<slug>') and push that instead."
  fi
fi

exit 0
