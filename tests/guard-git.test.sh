#!/usr/bin/env bash
# Tests for scripts/guard-git.sh. Feeds hook JSON to the guard in a throwaway repo and
# asserts allow/deny. The sample commands are never executed.
# Usage: bash tests/guard-git.test.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/scripts/guard-git.sh"
T="$(mktemp -d "${TMPDIR:-/tmp}/sdlc-guard.XXXXXX")"
trap 'rm -rf "$T"' EXIT
cd "$T" || exit 1
git init -q -b main
git -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m init
echo a > f && git add f && git -c user.email=t@example.com -c user.name=t commit -q -m f

fails=0
expect() {
  local want="$1" cmd="$2" got
  got="$(jq -n --arg c "$cmd" --arg d "$T" '{tool_input:{command:$c},cwd:$d}' \
        | CLAUDE_PROJECT_DIR="$T" bash "$GUARD" \
        | jq -r '.hookSpecificOutput.permissionDecision // "allow"' 2>/dev/null)"
  got="${got:-allow}"
  if [ "$got" = "$want" ]; then printf 'ok    %-6s %s\n' "$want" "$cmd"
  else printf 'FAIL  want=%s got=%s  %s\n' "$want" "$got" "$cmd"; fails=$((fails+1)); fi
}

echo "# clean tree, on main"
expect allow "git reset --hard"
expect allow "git status"
expect deny  "git push"
expect deny  "git push origin main"

echo "# dirty tree, on main"
echo b > f
expect deny  "git reset --hard HEAD"
expect deny  "/usr/bin/git checkout -- f"
expect deny  "git checkout ."
expect deny  "git restore f"
expect deny  "git clean -fd"
expect deny  "cd sub && git -C . reset --hard"
expect allow "git restore --staged f"
expect allow "git checkout -b feat/y"
expect allow "git stash push -u"
expect allow "git diff"

echo "# feature branch"
git switch -q -c feat/z
expect allow "git push -u origin HEAD"
expect allow "git push origin feat/z"
expect allow "git push origin feat/main-menu"
expect allow "echo maintenance && git push origin feat/z"
expect deny  "git push origin HEAD:main"
expect deny  "git push --force origin +main"
expect deny  "git push origin refs/heads/main"

echo
if [ "$fails" -eq 0 ]; then echo "All guard tests passed."; else echo "$fails guard test(s) failed."; exit 1; fi
