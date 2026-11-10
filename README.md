# Claude Code SDLC — v2: PR-native

A Claude Code plugin that runs **one issue → small pull requests → continuous delivery**, with independent AI review, real verification and humans in control of merge and data. v1 was built around sprints and big releases. v2 is built around the pull request.

> **Status: v2.0.0-alpha.** v1 (17 agents, 8 rounds, sprint gates) is preserved unchanged in [`legacy/v1/`](legacy/v1/). See [Migrating from v1](docs/migrating-from-v1.md).

Part of a five-stage product and AI life cycle: [Product Strategy Cockpit](https://github.com/geopap/product-strategy-cockpit) (strategy) → [AI Use-Case Intake](https://github.com/geopap/ai-use-case-intake) (decide) → [AI Portfolio Office](https://github.com/geopap/ai-portfolio-office) (fund, govern and prove the value) → **Claude Code SDLC** (build) → [AI Eval Workbench](https://github.com/geopap/ai-eval-workbench) (prove).

## The pipeline

```
 GitHub issue
     │  /sdlc:plan      spec · acceptance criteria · risk tier · PR-sized slices
     ▼
 feature branch
     │  /sdlc:build     implementer + test-engineer → local checks (Stop hook) → draft PR
     ▼
 draft PR
     │  /sdlc:review    code-reviewer ∥ security-reviewer → findings verified → fix loop (≤2)
     │  /sdlc:verify    verifier runs preview or local app, evidence per AC
     ▼
 ready for review ─── CI (required) ── ci · claude-review · pr-hygiene (title, risk label, migration guard)
     │                CODEOWNERS ───── human approval on high-risk paths
     ▼
 human merges → deploy (flags for unfinished work) → release-please builds notes and tags
```

`/sdlc:ship <issue>` runs the whole loop and stops at a ready-for-review PR. The individual skills let you run any step on its own.

## What changed from v1, and why

| v1 | v2 | Why |
|---|---|---|
| Sprint is the unit of work | **PR is the unit of work** | Small, frequent, independently deployable changes |
| 8 gates enforced by prose ("NEVER SKIP") | **Hooks + required CI checks + CODEOWNERS** | Gates that can't be skipped, instead of gates the model is asked not to skip |
| 17 agent prompt files pasted into `general-purpose` | **6 native subagents** with `model`, `tools` and `effort` frontmatter | Reviewers are read-only because they have no Edit tool, not because a prompt says so |
| 701-line CLAUDE.md loaded every session | **~40-line project CLAUDE.md**; process lives in skills that load on demand | Less context spent on process every turn |
| SPRINT.md / BACKLOG.md / BACKLOG_BOARD.md synced by hand | **GitHub Issues, PRs and labels** | No sync gate, no corrupted markdown tables |
| Backend → frontend sequential rounds | **One implementer builds a vertical slice** | No context loss at handoffs |
| LLM "manual UAT" | **Verifier exercises the running app**; humans click through high-risk flows only | Evidence, not role-play |
| Release manager at sprint close | **release-please** on every merge | Continuous, automatic changelog and tags |
| Gate 7 velocity retro | **`/sdlc:retro`**: lead time, PR size, change failure rate, escaped bugs | Delivery metrics from real PR data |
| `bootstrap.md` copy-paste | **Plugin + marketplace**; `/sdlc:setup` writes the project files | Install, update and version like any tool |

What survived: separation of duties, parallel independent review of the diff, risk-based tiering, multi-tenant and security non-negotiables, git safety, migration discipline, and "every rule exists because something went wrong without it".

## Install

In Claude Code:

```
/plugin marketplace add geopap/claude-code-sdlc
/plugin install sdlc@geopap
```

Or from a terminal (also works in the desktop app's Terminal panel):

```bash
claude plugin marketplace add geopap/claude-code-sdlc
claude plugin install sdlc@geopap
```

Restart any open sessions; they don't pick up a new plugin. Then, in your project:

```
/sdlc:setup
```

### What setup does

`/sdlc:setup` detects your stack and writes `.claude/sdlc.json`, a lean `CLAUDE.md`, the PR and issue templates, `CODEOWNERS`, the labeler config and four workflows. It asks before overwriting anything and commits nothing. You then:

1. Add the `ANTHROPIC_API_KEY` (or `CLAUDE_CODE_OAUTH_TOKEN`) repository secret.
2. Protect `main`: require PRs, require the `ci`, `claude-review` and `pr-hygiene` checks, require Code Owner review, and block force-pushes.
3. Optional: turn on preview deployments so `/sdlc:verify` tests the real build.

### Updating

Claude Code keeps a local copy of the marketplace and only checks that copy, so refresh it first, then update the plugin and restart your sessions:

```bash
claude plugin marketplace update geopap
claude plugin update sdlc@geopap
```

If `update` says "already at the latest version" right after a release, you skipped the first command.

## Skills

| Skill | Does |
|---|---|
| `/sdlc:plan <issue>` | Spec with testable AC, risk tier and slices of ≤ ~400 lines. Checks for existing code and duplicate issues first. Posts the spec on the issue. |
| `/sdlc:build <issue> [slice]` | Branch → implementer → test-engineer → local checks → draft PR (`Closes #n`, Conventional Commit title, risk label). |
| `/sdlc:review [base] [--post]` | Code and security reviewers in parallel, chosen by risk tier. Every blocking finding is verified before it's reported. `--post` comments on the PR (used by CI). |
| `/sdlc:verify [url] [--post]` | Runs the preview or local app and checks each AC, with evidence. |
| `/sdlc:ship <issue>` | All of the above with a fix loop (≤ 2 rounds), ending at a ready-for-review PR. Never merges. |
| `/sdlc:retro [days]` | Delivery metrics and up to 3 concrete process changes. |
| `/sdlc:setup` | One-time project setup and re-sync. |

## Agents

| Agent | Model | Tools | Role |
|---|---|---|---|
| `planner` | opus | read-only | Spec, AC, risk, slices, query and migration design |
| `implementer` | opus | all | One vertical slice: data → API → UI → tests |
| `test-engineer` | opus | all | AC → test map, isolation and role edge cases, full suite |
| `code-reviewer` | sonnet | read-only | Correctness, N+1 and pagination, contracts, UI states |
| `security-reviewer` | opus | read-only | Auth, tenant isolation, injection, secrets, AI calls, dependencies |
| `verifier` | sonnet | read-only | Exercises the running app per AC, with evidence |

The routing principle from v1 still holds: the strongest model goes where mistakes are expensive or irreversible, and a cheaper one goes where the output is checklist-shaped and reviewed anyway. See [docs/model-routing.md](docs/model-routing.md).

## Guardrails (hooks)

- **`guard-git`** (PreToolUse): blocks `reset --hard`, `clean -f`, `checkout -- / .` and `restore` on a dirty tree, and blocks any push to the base branch. Covered by [`tests/guard-git.test.sh`](tests/guard-git.test.sh).
- **`stop-check`** (Stop): if code changed since the last passing check, runs `commands.check` before Claude ends its turn, and sends failures back once. It's opt-in per repo with `stopHook.runCheck`.

## Risk tiers

Tiers come from **paths touched**, not T-shirt sizes. `risk.high` globs (auth, payments, webhooks, migrations, workflows) get a deep security review, `CODEOWNERS` human approval and, for migrations, a `db:approved` label a human must add. `risk.low` (docs, tests) gets a code review only.

## Docs

- [How it works](docs/how-it-works.md): the loop, where each v1 gate went, and CI wiring
- [Migrating from v1](docs/migrating-from-v1.md)
- [Model routing](docs/model-routing.md)

## Roadmap

- Optional **product pack** plugin carrying v1's PM, data-analyst, marketing, SEO and technical-writer agents, outside the delivery loop
- Plugin evals (`claude plugin eval`) for the reviewers: seeded-bug PRs and their precision and recall
- Stacked-PR support for multi-slice specs

## License

MIT. See [LICENSE](LICENSE). Built by [George Papadongonas](https://github.com/geopap).
