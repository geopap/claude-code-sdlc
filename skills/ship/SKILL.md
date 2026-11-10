---
name: ship
description: Drive one issue from spec to a ready-for-review pull request — plan if needed, build, review, fix confirmed findings, verify, then mark the PR ready. A human still approves and merges. Use when the user says "ship #123" or wants the whole pipeline for one issue.
argument-hint: <issue-number>
disable-model-invocation: true
---

# /sdlc:ship

Issue: `$ARGUMENTS`

This is v2's pipeline. It replaces v1's 8 rounds and sprint close with one loop per PR:

```
spec ─▶ build ─▶ review ─▶ fix ─▶ verify ─▶ ready for review ─▶ (human) merge ─▶ CD
          ▲        │
          └────────┘  up to 2 fix rounds, then stop and ask
```

## Steps
1. **Spec.** If the issue has no `## Spec` comment, run the `/sdlc:plan` flow and get the user's approval before building. This is the only stop before the PR, unless something blocks.
2. **Build.** Follow `/sdlc:build` for the first open slice. You now have a draft PR.
3. **Review.** Follow `/sdlc:review` locally (without `--post`).
4. **Fix.** Send confirmed blocking, critical and high findings to `sdlc:implementer`, push, and re-run only the reviewer that raised them. Stop after 2 rounds if findings remain, and report them to the user.
5. **Verify.** Follow `/sdlc:verify --post`. Send any failing AC back to the implementer (this counts toward the same 2-round limit).
6. **Ready.** Make sure the PR body's checklist reflects reality, then run `gh pr ready`. CI now runs the authoritative gates: tests, typecheck, AI review as a required check, migration guard, and CODEOWNERS approval for high-risk paths.
7. **Hand off.** Report the PR URL, the risk tier, what was verified, and what a human must still do (approve, click through high-risk flows, add `db:approved` for migrations). Then stop.

## Never
- Merge, approve your own PR, push to the base branch, or bypass branch protection.
- Apply database migrations, change environment variables, or deploy.
- Start the next slice or issue unasked. Offer it instead.
