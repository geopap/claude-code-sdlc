# Migrating from v1

v1 is unchanged in [`legacy/v1/`](../legacy/v1/). Projects running it keep working. Migrate one repo at a time.

## Steps

1. **Finish or park the current sprint.** Close what's done the v1 way. Convert open items into GitHub issues, one per BACKLOG item. Paste the user story and AC into the body and add a `risk:*` label.
2. **Install the plugin** (`/plugin marketplace add geopap/claude-code-sdlc`, then `/plugin install sdlc@geopap`) and run `/sdlc:setup`.
3. **Shrink CLAUDE.md.** Keep the project facts: stack, commands, layout, non-obvious rules. Delete the pipeline, gates, roster, model table and bracket-notation sections. The plugin's skills and agents carry them now. Your project-specific security rules (for example "use `getUser()` from …") stay.
4. **Remove the v1 project files** once you've exported anything you need. SPRINT.md, BACKLOG.md, BACKLOG_BOARD.md and SPRINT_FINDINGS.md are replaced by issues, PRs and labels. SPRINT_ARCHIVE.md and RELEASES.md become the GitHub Releases history. Keep SOLUTION_DESIGN.md if it's useful as architecture docs. v2 no longer requires it per item, but the planner reads it if it exists.
5. **Turn on branch protection** with the required checks and Code Owner review.
6. **Retire the v1 hooks** in `.claude/settings.json` (git safety, typecheck-on-commit). The plugin's `guard-git` hook replaces the first, and CI (plus an optional pre-commit tool such as lefthook) replaces the second.

## Agent mapping

| v1 agent | v2 |
|---|---|
| scrum-master | The `/sdlc:ship` skill (orchestration) plus GitHub (state) |
| product-manager, solution-architect (R2), data-analyst | `planner` |
| backend-, frontend-, ai-ml-engineer | `implementer` |
| test-engineer | `test-engineer` |
| code-reviewer, qa-reviewer | `code-reviewer` |
| security-reviewer | `security-reviewer` |
| tester | `verifier` (+ humans for high-risk flows) |
| solution-architect (R7) | PR description, plus docs updated in the same PR |
| release-manager | release-please workflow |
| marketing-manager, content-creator, seo-reviewer, technical-writer | Planned optional "product pack" plugin. For now, use the v1 prompts from `legacy/v1/agents/` as needed |

## Habits that change

- **Ask for PRs, not sprints:** "ship #142", not "run sprint 7".
- **Size by slices:** if the planner can't cut it into slices of 400 lines or fewer, it needs a flag or a spike.
- **Let CI say no.** If the AI review check is noisy, tune the reviewer prompt or the risk globs. Don't skip the check.
