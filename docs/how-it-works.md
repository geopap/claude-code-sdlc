# How v2 works

## One loop per pull request

```
issue ─▶ spec ─▶ branch ─▶ build ─▶ local checks ─▶ draft PR ─▶ review ─▶ fix ─▶ verify ─▶ ready ─▶ CI gates ─▶ human merge ─▶ deploy
```

- **The issue is the backlog item.** Its comments hold the spec, and its labels hold the risk tier.
- **The PR is the sprint item.** Its checklist is the Definition of Done, its checks are the gates, and its comments are the review and verification record.
- **main is always releasable.** Unfinished user-facing work ships behind a feature flag, and migrations are expand/contract so every PR deploys on its own.

## Where each v1 gate went

| v1 gate | v2 mechanism | Enforced by |
|---|---|---|
| Gate 1: review (4 reviewers) | `/sdlc:review` locally, `claude-review` in CI | Required status check |
| Gate 2: testing | implementer and test-engineer write tests; `ci` runs them | Required status check, plus the Stop hook locally |
| Gate 3: UAT | `/sdlc:verify` evidence on the PR; a human clicks through `risk:high` flows | PR comment, plus CODEOWNERS approval |
| Gate 4: release checklist | PR template DoD, plus release-please | PR review, release PR |
| Gate 5: backlog sync | `Closes #n`, labels, GitHub Projects automation | GitHub |
| Gate 6: sprint readiness | Issue template (Definition of Ready) and `/sdlc:plan` | Issue template, spec comment |
| Gate 7: retrospective | `/sdlc:retro` weekly from PR data | Habit (schedule it with `/schedule` if you like) |
| Gate 8: environment promotion | Your deploy pipeline: preview → production, with flags | Hosting platform |
| Migration approval | `migration-guard` job requires a human-added `db:approved` label | Required status check |
| Git safety | `guard-git` hook | PreToolUse hook |

## Tiers

| Tier | Triggered by | Review | Human |
|---|---|---|---|
| `risk:low` | Only `risk.low` paths changed | code-reviewer | Merge |
| `risk:standard` | Default | code-reviewer + security-reviewer | Approve + merge |
| `risk:high` | Any `risk.high` path | Both, with the security reviewer told to go deep | CODEOWNERS approval, click-through of flagged flows, `db:approved` for migrations |

Labels come from `actions/labeler` (deterministic). The skills fall back to the globs in `.claude/sdlc.json` when there's no label.

## Review quality

Reviewers are separate subagents with fresh context and no write tools. They get the base ref, not the author's reasoning, and must give a concrete failure scenario for every finding. The orchestrating skill then verifies each blocking finding against the code before it's reported or posted. This keeps the signal-to-noise ratio high enough that a required AI check doesn't get muted.

## Parallel work

- Two independent issues: run `/sdlc:ship` in two sessions or worktrees. The desktop app and `claude --worktree` both give each session its own checkout.
- Several slices of one spec: `/sdlc:build` can start one `implementer` per slice with `isolation: worktree`. Each slice becomes its own PR (stack them if they depend on each other).

## Configuration: `.claude/sdlc.json`

| Key | Used by |
|---|---|
| `baseBranch` | Branch creation, guard hook, review base |
| `commands.check/test/typecheck/lint/dev` | Implementer, test-engineer, Stop hook, verifier |
| `verify.url` | Verifier (local fallback when there's no preview) |
| `migrations.paths` | Planner, implementer, migration guard (via setup) |
| `risk.high` / `risk.low` | Planner, review, labeler and CODEOWNERS (via setup) |
| `compliance` | Security reviewer |
| `stopHook.runCheck` | Stop hook opt-in |

## Cost notes

- Low-risk PRs skip the Opus security reviewer.
- Reviewers read the diff, not the repo. They open other files only for context.
- The Stop hook runs checks only when the code fingerprint changed since the last passing run.
