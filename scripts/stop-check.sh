#!/usr/bin/env bash
# Stop hook: before Claude ends its turn with unchecked code changes, run the project's check command.
# - Opt-in per repo: .claude/sdlc.json -> "stopHook": { "runCheck": true }, "commands": { "check": "..." }
# - Runs only when the code state changed since the last passing check (fingerprint stored in the git dir).
# - Blocks the stop once with the failure output; never loops (respects stop_hook_active).
set -uo pipefail

input="$(cat)"
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

cd "${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.cwd // "."')}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

cfg=".claude/sdlc.json"
[ -f "$cfg" ] || exit 0
[ "$(jq -r '.stopHook.runCheck // false' "$cfg")" = "true" ] || exit 0
check="$(jq -r '.commands.check // empty' "$cfg")"
[ -n "$check" ] || exit 0
base="$(jq -r '.baseBranch // "main"' "$cfg")"

# Files changed on this branch or in the working tree
changed="$( { git diff --name-only HEAD 2>/dev/null
             git ls-files --others --exclude-standard 2>/dev/null
             git diff --name-only "origin/${base}...HEAD" 2>/dev/null; } | sort -u )"
[ -z "$changed" ] && exit 0
# Docs-only changes don't need a check
code_changed="$(printf '%s\n' "$changed" | grep -vE '\.(md|mdx|txt|rst)$|^docs/' || true)"
[ -z "$code_changed" ] && exit 0

gitdir="$(git rev-parse --git-dir)"
stamp="${gitdir}/sdlc-last-passing-check"
fingerprint="$( { git rev-parse HEAD; git diff HEAD; git ls-files --others --exclude-standard | xargs -I{} shasum {} 2>/dev/null; } | shasum | cut -d' ' -f1 )"
[ -f "$stamp" ] && [ "$(cat "$stamp")" = "$fingerprint" ] && exit 0

if out="$(bash -c "$check" 2>&1)"; then
  printf '%s' "$fingerprint" > "$stamp"
  exit 0
fi

tail_out="$(printf '%s' "$out" | tail -n 60)"
jq -n --arg r "Project checks failed (\`${check}\`). Fix them before finishing, or tell the user why they can't pass yet. Last lines:
${tail_out}" '{decision:"block", reason:$r}'
exit 0
