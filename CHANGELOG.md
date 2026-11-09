# Changelog

## 2.0.0-alpha.1 — unreleased

v2 rebuilds the framework around the pull request instead of the sprint.

### Added
- Claude Code plugin and marketplace (`sdlc@geopap`).
- 6 native subagents: planner, implementer, test-engineer, code-reviewer, security-reviewer, verifier.
- Skills: `/sdlc:plan`, `/sdlc:build`, `/sdlc:review`, `/sdlc:verify`, `/sdlc:ship`, `/sdlc:retro`, `/sdlc:setup`.
- Hooks: `guard-git` (destructive git on a dirty tree, pushes to the base branch) and `stop-check` (run project checks before ending a turn with unchecked code).
- Project templates: `.claude/sdlc.json`, lean `CLAUDE.md`, PR and issue templates, CODEOWNERS, labeler, and the `ci`, `claude-review`, `pr-hygiene` (title, risk label, migration guard) and `release` workflows.
- Framework CI: plugin validation, shellcheck, and guard-hook tests.

### Changed
- Gates now live in hooks, required CI checks and CODEOWNERS instead of CLAUDE.md prose.
- Risk tiers come from paths touched rather than effort size.

### Moved
- v1 (17 agents, 8 rounds, sprint gates, bootstrap.md) is preserved unchanged in `legacy/v1/`.
