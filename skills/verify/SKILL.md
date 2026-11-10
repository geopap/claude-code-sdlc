---
name: verify
description: Prove a branch or PR works by running it (preview deployment or local dev server) and exercising each acceptance criterion with the verifier subagent, then attach the evidence to the PR. Use before marking a PR ready for review.
argument-hint: "[preview-url] [--post]"
---

# /sdlc:verify

Arguments: `$ARGUMENTS`. This is an optional preview URL, and `--post` to attach the evidence to the PR.

## Steps
1. **Find the AC.** Use the linked issue's spec (from the `Closes #n` line in the PR body), or ask the user for what to verify.
2. **Find the target**, in this order:
   1. A URL argument.
   2. A preview deployment on the PR. Check the PR comments and deployment statuses with `gh pr view --json comments` and `gh api repos/{owner}/{repo}/deployments?ref=<branch>`.
   3. Local: start `commands.dev` from `.claude/sdlc.json` in the background and use `verify.url`.
3. **Delegate** to `sdlc:verifier` with the AC, the verification steps and the target URL.
4. **If a check fails**, show which AC failed with the evidence, and offer to send it to `sdlc:implementer`.
5. **With `--post`**, add the verifier's evidence table to the PR as a comment.
6. For `risk:high` PRs, end by telling the user which flows need a human to click through before approving. Don't claim human UAT happened.

Stop any dev server you started before finishing.
