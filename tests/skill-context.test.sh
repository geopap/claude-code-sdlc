#!/usr/bin/env bash
# Every !`cmd` line in a skill runs before the skill loads, and Claude Code aborts the
# skill if the command exits non-zero. Run each one in an empty, non-git directory
# (the worst case: a repo that hasn't run /sdlc:setup) and require exit 0.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
empty="$(mktemp -d)"
trap 'rm -rf "$empty"' EXIT

pass=0
fail=0
while IFS= read -r line; do
  file="${line%%:*}"
  cmd="${line#*:}"
  cmd="${cmd#\!\`}"
  cmd="${cmd%\`}"
  if out="$(cd "$empty" && bash -c "$cmd" 2>&1)"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL %s\n  cmd: %s\n  out: %s\n' "${file#"$root"/}" "$cmd" "$(printf '%s\n' "$out" | head -3)"
  fi
done < <(grep -o '!`[^`]*`' "$root"/skills/*/SKILL.md)

echo "skill context commands: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
