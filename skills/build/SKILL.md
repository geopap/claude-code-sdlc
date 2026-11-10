---
name: build
description: Build one slice of a planned issue on a feature branch with the implementer and test-engineer subagents, then push and open a draft PR linked to the issue. Use after /sdlc:plan, or directly for small low-risk fixes.
argument-hint: <issue-number> [slice-number]
allowed-tools: Bash(git status *) Bash(git branch *) Bash(git log *) Bash(gh issue view *) Bash(gh pr view *)
---

# /sdlc:build

Arguments: `$ARGUMENTS`. The first is the issue number; the optional second is the slice number (default: the first slice that isn't done).

## Context
- Branch: !`git branch --show-current`
- Working tree: !`git status --short | head -20`
- Config: !`cat .claude/sdlc.json 2>/dev/null || echo "(missing: run /sdlc:setup first)"`

## Steps
1. **Load the spec.** Run `gh issue view <n> --comments` and find the latest `## Spec` comment. If there's no spec and the change is more than a small low-risk fix, stop and suggest `/sdlc:plan <n>`.
2. **Branch.** If the working tree is dirty, stop and ask the user. Never stash or discard someone's work silently. Fetch, then create `<type>/<n>-<slug>` from `origin/<baseBranch>`. If a branch for this issue already exists, continue on it.
   - If the user wants several slices or issues built in parallel, run each `sdlc:implementer` with `isolation: worktree` so they never share a working tree.
3. **Implement.** Delegate to `sdlc:implementer` with the spec, the slice to build, and the config commands. Wait for its report.
4. **Fill test gaps.** If the implementer's AC → test coverage has gaps, or the risk tier is `standard` or `high`, delegate to `sdlc:test-engineer`.
5. **Check locally.** Run `commands.check` (or `test`, `typecheck` and `lint`). If it fails, send the failure back to the implementer. After two failed rounds, stop and report to the user.
6. **Open a draft PR.**
   - Push with `git push -u origin HEAD`.
   - Create the PR with `gh pr create --draft --base <baseBranch> --title "<type>(<scope>): <summary>" --body-file <tmp>`. Use a Conventional Commit title (release automation depends on it), fill the body from the repo's `.github/pull_request_template.md`, and include `Closes #<n>` (or `Part of #<n>` for a non-final slice).
   - Add the `risk:<tier>` label.
7. Report the PR URL. The next step is `/sdlc:review` and `/sdlc:verify`, or let `/sdlc:ship` run the rest.

Never push to the base branch, never merge, and never apply migrations to a shared database.
