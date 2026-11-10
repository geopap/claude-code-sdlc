---
name: setup
description: Set up the PR-native SDLC in the current repository — write .claude/sdlc.json, a lean CLAUDE.md, the PR and issue templates, CODEOWNERS, risk labels and the CI workflows. Use once per repo, or to re-sync after changing risk paths.
disable-model-invocation: true
---

# /sdlc:setup

Templates live in `${CLAUDE_PLUGIN_ROOT}/templates/`.

## Context
- Repo root: !`git rev-parse --show-toplevel 2>/dev/null || echo "(not a git repository)"`
- Remote: !`gh repo view --json nameWithOwner,defaultBranchRef -q '"\(.nameWithOwner) default=\(.defaultBranchRef.name)"' 2>/dev/null || echo "(no GitHub remote)"`
- Existing setup: !`for f in .claude/sdlc.json CLAUDE.md .github/workflows .github/pull_request_template.md .github/CODEOWNERS; do if [ -e "$f" ]; then echo "present: $f"; else echo "missing: $f"; fi; done`
- Package scripts: !`if [ -f package.json ]; then jq -r '.scripts // {} | keys | join(", ")' package.json 2>/dev/null || echo "(package.json unreadable)"; else echo "(no package.json)"; fi`

## Steps
1. **Detect the stack.** Look at the package manager, test runner, typecheck and lint commands, the dev server and its port, the migrations directory, and the auth, payments and multi-tenant code paths. Read the files. Don't guess.
2. **Draft `.claude/sdlc.json`** from `templates/sdlc.json`. Fill in the commands, `baseBranch`, `verify.url`, `migrations.paths` and `risk.high` / `risk.low` globs. Show it to the user and get confirmation.
3. **Generate the files.** Write each from its template. If a file already exists, show a diff and ask before overwriting. Never overwrite silently.
   | Template | Destination | Notes |
   |---|---|---|
   | `CLAUDE.md` | `CLAUDE.md` | Lean project facts only. If one exists, merge into it instead of replacing it. |
   | `github/pull_request_template.md` | `.github/pull_request_template.md` | Definition of Done |
   | `github/ISSUE_TEMPLATE/feature.yml` | `.github/ISSUE_TEMPLATE/feature.yml` | Definition of Ready |
   | `github/CODEOWNERS` | `.github/CODEOWNERS` | Generate from `risk.high`, with the user's handle as owner |
   | `github/labeler.yml` | `.github/labeler.yml` | Generate from `risk.high` / `risk.low` |
   | `github/workflows/ci.yml` | `.github/workflows/ci.yml` | Substitute the real commands |
   | `github/workflows/claude-review.yml` | `.github/workflows/claude-review.yml` | |
   | `github/workflows/pr-hygiene.yml` | `.github/workflows/pr-hygiene.yml` | PR title, risk labels, migration guard |
   | `github/workflows/release.yml` | `.github/workflows/release.yml` | Only if the user wants automated releases |
4. **Create the labels**, if `gh` is authenticated and the user agrees: `risk:low`, `risk:standard`, `risk:high` and `db:approved`. Use `gh label create <name> --color <hex> --force`.
5. **Print the manual steps.** The user does these themselves; you can't:
   - Add the `ANTHROPIC_API_KEY` (or `CLAUDE_CODE_OAUTH_TOKEN`) repo secret.
   - Set up branch protection on the base branch: require PRs, require the `ci`, `claude-review` and `pr-hygiene` checks, require CODEOWNERS review, and disallow force-push.
   - Optionally, set up preview deployments (Vercel, Netlify, Render and others) so `/sdlc:verify` can use them.
6. **Remind them:** nothing is committed. Offer to commit the setup on a `chore/sdlc-setup` branch and open a PR.
