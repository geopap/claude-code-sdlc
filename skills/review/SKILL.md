---
name: review
description: Run the independent code and security reviewers in parallel on the current branch's diff, verify every finding, and either report locally or post on the PR. Use before marking a PR ready, and from CI on every PR update.
argument-hint: "[base-ref] [--post]"
allowed-tools: Bash(git diff *) Bash(git log *) Bash(git merge-base *) Bash(gh pr view *) Bash(gh pr diff *)
---

# /sdlc:review

Arguments: `$ARGUMENTS`. The base ref defaults to `origin/<baseBranch>` (or `origin/main`). `--post` posts the results on the PR, which is what CI uses.

## Context
- Branch: !`git branch --show-current`
- Diff size: !`git diff --shortstat --merge-base origin/HEAD 2>/dev/null || git diff --shortstat HEAD~1`
- PR: !`gh pr view --json number,title,labels,url -q '"#\(.number) \(.title) [\([.labels[].name]|join(","))] \(.url)"' 2>/dev/null || echo "(no PR for this branch)"`

## Steps
1. **Scope.** Find the base and the list of changed files. Read the linked issue's spec (the `Closes #n` line in the PR body) for the AC, if there is one.
2. **Pick reviewers by risk.**
   - `risk:low` (docs, copy or tests only): `sdlc:code-reviewer` only.
   - `risk:standard`: `sdlc:code-reviewer` and `sdlc:security-reviewer`.
   - `risk:high`: both reviewers, and tell `sdlc:security-reviewer` that it's high-risk so it goes deep on auth, isolation and migrations.
   If there's no label, infer the tier from `risk.high` and `risk.low` globs in `.claude/sdlc.json`.
3. **Run them in parallel**, in one message with multiple Agent calls. Give each the base ref and the AC. Don't paste your own opinion of the code into their prompts. Independence is the point.
4. **Verify findings.** For each `blocking`, `critical` or `high` finding, check it yourself against the code: read the lines, the callers and the tests. Mark it `confirmed` or `dismissed (reason)`. Merge duplicates across reviewers.
5. **Output.**
   - Locally: show one table (severity, file:line, finding, status) and the overall verdict.
   - With `--post`: post a single summary comment with `gh pr comment --body-file`, and inline comments on confirmed findings if the inline-comment tool is available. Don't post dismissed findings.
6. **Verdict.** Use `REQUEST_CHANGES` if any confirmed finding is blocking, critical or high. Otherwise use `APPROVE` (with suggestions if there are any). In CI, write the single word to `.sdlc-review/verdict`. The workflow's next step reads it and fails the required check on anything other than `APPROVE`.

This skill reports findings. It doesn't fix them. Locally, offer to send confirmed findings back to `sdlc:implementer`.
