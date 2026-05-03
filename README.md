# Claude Code SDLC

A production-tested framework for running a **17-agent software development team** inside [Claude Code](https://claude.ai/code). Covers the full SDLC: requirements, architecture, build, review, testing, and release — orchestrated automatically through an 8-round pipeline with mandatory quality gates.

## Why This Exists

Most people use Claude Code for single-shot tasks. This framework turns it into an **automated development pipeline** where specialized agents handle different concerns — a product manager writes requirements, an architect designs the system, engineers build it, reviewers catch issues, and testers verify quality. All coordinated by a scrum master agent that drives the pipeline forward without manual intervention.

**Built from 100+ production sprints**, not a toy example. Every rule in the pipeline exists because something went wrong without it.

## What You Get

- **17 specialized agents** with defined roles, responsibilities, and file ownership
- **8-round automated pipeline** with parallel execution where possible
- **8 mandatory quality gates** that cannot be skipped
- **3 pipeline tiers** sized to the task (Fast Track, Full, Spike-First)
- **Smart model routing** — Opus for high-stakes agents, Sonnet for structured work
- **Document governance** — sprint board, backlog, architecture docs, all kept in sync
- **Bootstrap script** — one file to initialize the entire framework for a new project

## The Pipeline

```
ROUND 1 — DEFINITION     [product-manager] + [data-analyst] + [marketing-manager]*     PARALLEL
ROUND 2 — ARCHITECTURE   [solution-architect]                                          SEQUENTIAL
ROUND 3 — BUILD          [backend-engineer] + [ai-ml-engineer]**                       PARALLEL
ROUND 4 — BUILD          [frontend-engineer]                                           SEQUENTIAL
ROUND 5 — REVIEW         [seo] + [code] + [security] + [qa]                           PARALLEL
ROUND 6 — TESTING        [test-engineer] then [tester]                                 SEQUENTIAL
ROUND 7 — CLOSE          [solution-architect] updates docs                             SEQUENTIAL
ROUND 8 — POST-CLOSE     [marketing-manager]* + [technical-writer]**                   PARALLEL

SPRINT CLOSE             [release-manager] tags, releases, deploys                     SEQUENTIAL
```

`*` Optional — only for user-facing features
`**` Only if they don't share database tables; otherwise sequential

The pipeline runs **automatically**. After each round completes, the scrum master agent launches the next round without waiting for human input. Quality gates enforce that no step is skipped.

## The 17 Agents

| # | Agent | Round | Writes Code? | Role |
|---|-------|-------|:---:|------|
| 1 | `[scrum-master]` | All | No | Pipeline orchestration, sprint tracking, context routing |
| 2 | `[product-manager]` | R1 | No | User stories, acceptance criteria, backlog management |
| 3 | `[data-analyst]` | R1 | No | Analytics events, success metrics, KPIs |
| 4 | `[marketing-manager]` | R1, R8 | No | Marketing strategy, feature positioning, launch plans |
| 5 | `[solution-architect]` | R2, R7 | No | DB schema, API contracts, security model, architecture docs |
| 6 | `[backend-engineer]` | R3 | Yes | API routes, migrations, auth, validations, types |
| 7 | `[ai-ml-engineer]` | R3 | Yes | AI agents, RAG pipelines, orchestration, prompts |
| 8 | `[frontend-engineer]` | R4 | Yes | Pages, components, hooks, forms, UX |
| 9 | `[seo-reviewer]` | R5 | No | Technical SEO, content SEO, accessibility |
| 10 | `[code-reviewer]` | R5 | No | Architecture, patterns, performance, DRY |
| 11 | `[security-reviewer]` | R5 | No | Auth, data isolation, compliance, vulnerabilities |
| 12 | `[qa-reviewer]` | R5 | No | Type safety, error handling, edge cases, accessibility |
| 13 | `[test-engineer]` | R6 | Yes | E2E, integration, and unit tests |
| 14 | `[tester]` | R6 | No | Manual UAT — PASS/FAIL per test case |
| 15 | `[content-creator]` | R8+ | No | Marketing copy, content briefs |
| 16 | `[technical-writer]` | R8 | No | User manuals, feature documentation |
| 17 | `[release-manager]` | Close | No | Git tags, GitHub releases, deployment verification |

## Three Pipeline Tiers

Not every task needs 8 rounds. The framework sizes the pipeline to the work:

### Fast Track (XS/S effort)
Bug fixes, CSS tweaks, copy updates. **3 rounds only:**
```
R1 [product-manager] → R3/R4 Build → R5 [code-reviewer] + [security-reviewer] → Done
```

### Full Pipeline (M/L effort)
New features, refactors, multi-component changes. **All 8 rounds**, all gates enforced.

### Spike-First (XL effort)
High-complexity items with unknowns. **R0 discovery spike** before the full pipeline:
```
R0 [solution-architect] spike → R1-R8 full pipeline
```

## 8 Quality Gates

| Gate | When | What It Enforces |
|------|------|-----------------|
| Gate 1 | After R3/R4 | All R5 reviewers must launch — no skipping reviews |
| Gate 2 | After R5 | Automated tests + UAT must run before "done" |
| Gate 3 | Before sprint close | Every item has UAT PASS status |
| Gate 4 | R7 close | Full release checklist — reviews, tests, docs, rollback plans |
| Gate 5 | Every item | Backlog, board, and sprint docs stay 100% in sync |
| Gate 6 | Before sprint starts | All items pass Definition of Ready |
| Gate 7 | After sprint close | Retrospective written — velocity, improvements, action items |
| Gate 8 | UAT to PROD | Multi-environment promotion checks (activates when you have staging) |

## Model Routing (Cost Optimization)

Running 17 agents on the most expensive model wastes money. The framework assigns models based on risk:

**Opus (7 agents)** — Where errors are expensive or irreversible:
- `[scrum-master]` — orchestration errors cascade to all agents
- `[solution-architect]` — architecture decisions are costly to reverse
- `[security-reviewer]` — missed vulnerabilities have asymmetric risk
- `[backend-engineer]`, `[ai-ml-engineer]`, `[frontend-engineer]` — code correctness
- `[test-engineer]` — test quality determines what ships

**Sonnet (10 agents)** — Structured, checklist-driven, or reviewed by Opus agents:
- All other agents — their output is validated by at least one Opus agent before shipping

This creates an **"Opus Trident"** safety net: every piece of Sonnet-generated work passes through the scrum master (process), architect (design), or security reviewer (safety) before it's done.

## Getting Started

This is the full walk-through for setting up the framework in a brand-new or existing project. If you've already cloned the repo and just want a one-line cheat sheet, jump to [Daily Use](#daily-use).

### Step 1 — Drop the framework into your project

The framework is a set of markdown files that Claude Code reads. It lives **inside your project** so Claude Code picks it up automatically when you open the folder.

```bash
# Clone this repo somewhere outside your project
git clone https://github.com/geopap/claude-code-sdlc.git ~/tools/claude-code-sdlc

# Inside YOUR project root
cd ~/code/your-project

# Copy the framework files
cp ~/tools/claude-code-sdlc/CLAUDE.md ./
cp ~/tools/claude-code-sdlc/bootstrap.md ./
cp -r ~/tools/claude-code-sdlc/agents ./
mkdir -p .claude && cp -r ~/tools/claude-code-sdlc/commands .claude/commands
```

After this, your project root should contain:

```
your-project/
├── CLAUDE.md          # Framework rules — Claude Code reads this on every turn
├── bootstrap.md       # One-shot setup guide (you'll run this in Step 3)
├── agents/            # 17 agent definitions
└── .claude/
    └── commands/      # Slash commands like /run-sprint, /sprint-close
```

> **Why a folder, not a global install?** Claude Code's `CLAUDE.md` and `agents/` are project-scoped on purpose. Different projects need different tech stacks, compliance rules, and file layouts — keeping the framework inside the project means each project gets the right version.

### Step 2 — Create an `/onboarding` folder for your project context

The framework doesn't know anything about *your* product, customers, or constraints. Create an `onboarding/` folder at the project root and drop in everything the agents will need to read during Sprint 0:

```
your-project/
└── onboarding/
    ├── product-brief.md       # What you're building, for whom, why
    ├── tech-stack.md          # Languages, frameworks, hosting, DB
    ├── compliance.md          # GDPR, HIPAA, SOC 2, etc. (if applicable)
    ├── existing-architecture.md  # If brownfield: current system overview
    ├── credentials.md         # What API keys/services exist (NOT the secrets themselves)
    └── design-assets/         # Brand guidelines, design system pointers
```

The content can be rough notes — you don't need to format anything. The `[product-manager]` and `[solution-architect]` agents will read these files in Sprint 0 and turn them into structured `PRD.md`, `SOLUTION_DESIGN.md`, and `BACKLOG.md` documents.

### Step 3 — Run `bootstrap.md` to generate the framework

Open the project in Claude Code and tell it:

> Run bootstrap.md to initialize this project.

The bootstrap process:
1. Reads `bootstrap.md` and the `onboarding/` folder
2. Customizes `CLAUDE.md` placeholders (`[YOUR_PROJECT_NAME]`, `[YOUR_TECH_STACK]`, file paths, compliance, etc.)
3. Customizes each agent file in `agents/` for your stack
4. Creates skeleton documents: `SPRINT.md`, `BACKLOG.md`, `PRD.md`, `SOLUTION_DESIGN.md`, `BUSINESS_PLAN.md`, `MARKETING_PLAN.md`, `SPRINT_ARCHIVE.md`

When it's done, **review the customizations** before doing anything else. Skim `CLAUDE.md` for any leftover `[PLACEHOLDER]` fields and check that the file paths match your repo layout.

### Step 4 — Run Sprint 0 (project foundation)

Sprint 0 is the only sprint that doesn't ship product code. It exists to lock down requirements and architecture before any engineer writes anything. Tell Claude Code:

> Run Sprint 0.

In Sprint 0:
- `[product-manager]` reads `onboarding/` and writes `PRD.md` + initial `BACKLOG.md`
- `[solution-architect]` writes `SOLUTION_DESIGN.md` (DB schema, API conventions, security model)
- `[marketing-manager]` (optional) writes `STRATEGIC_PLAN.md` + `MARKETING_PLAN.md`
- `[scrum-master]` produces a Sprint 1 plan with prioritized items

**Stop and review** the outputs of Sprint 0 with a human eye. Architecture and requirements decisions made here shape every later sprint.

### Step 5 — Plan Sprint 1

Once Sprint 0 outputs look right, ask the scrum master to plan Sprint 1:

> [scrum-master] plan Sprint 1.

The scrum master will:
1. Read `BACKLOG.md` and pick items by priority (P0 first) + effort (fits in one sprint)
2. Verify each item passes Definition of Ready (Gate 6) — user story, AC, effort, dependencies, architecture review
3. Tag each item with a tier: Fast Track (XS/S), Full (M/L), or Spike-First (XL)
4. Write the proposed sprint to `SPRINT.md` and present it for your approval

**Do not skip the approval step.** Per the `Sprint Workflow` rule, planning and execution are separate phases. Review the sprint plan, adjust scope if needed, then explicitly say "go" before execution starts.

### Step 6 — Run Sprint 1

```
/run-sprint 1
```

The scrum master takes over from here:
- Verifies Gate 6 (sprint readiness)
- Drives every item through its tier's pipeline (3 rounds for Fast Track, 8 for Full, 9 for Spike-First)
- Launches parallel agents where the rules allow (R1 definition, R3 build, R5 review, R8 post-close)
- Updates `SPRINT.md`, `BACKLOG.md`, and `BACKLOG_BOARD.md` after every round
- Stops only at hard checkpoints — UAT (manual browser testing) and release merge approval

You'll see updates streaming as `[agent-name] <status>` lines. The pipeline runs without further prompting until it's blocked or done.

### Step 7 — Close the sprint

When all items hit "done" status, run:

```
/sprint-close
```

The scrum master will:
1. Verify Gate 4 (release checklist) — every item has reviews, tests, UAT PASS, docs updated
2. Verify Gate 5 (backlog accuracy) — `BACKLOG.md`, `BACKLOG_BOARD.md`, `SPRINT.md` are in sync
3. Write the Gate 7 retrospective into `SPRINT.md`
4. Hand off to `[release-manager]` for the actual release (see below)
5. Archive completed items into `SPRINT_ARCHIVE.md` and reset `SPRINT.md` for the next sprint

## Delegating Git, Releases, and Other Risky Actions

The framework is opinionated about what Claude Code is allowed to do without asking.

### Git operations

- **Commits**: agents will draft commits for the work they did, but **you** (the human) approve and run `git commit`. Engineers don't push commits silently.
- **Branches**: agents create feature branches per sprint item by convention (`sprint-N/<item-id>-slug`), but they ask before deleting branches.
- **Force-push, reset --hard, branch deletion**: never. The `Git Safety` rules in `CLAUDE.md` prohibit destructive git on tracked files with uncommitted changes.

If you want fully-autonomous commits, edit `CLAUDE.md` and add an explicit override — but you're taking on the risk.

### Release process (`[release-manager]`)

When a sprint closes, `[release-manager]` runs the release sequence. By default it requires human approval at every destructive step:

1. Pre-flight verification (Gate 4 + Gate 7 must have passed)
2. Determine semantic version from completed items
3. Compile structured release notes from `SPRINT.md`
4. Open a PR from `develop` to `main` — **you approve and merge**
5. Tag the release and create a GitHub Release — runs after merge
6. Sync `develop` with `main`
7. Verify deployment (if you have CI/CD wired)
8. Document rollback commands in `RELEASES.md`

Steps 4 and 5 hit shared/external systems, so they always pause for explicit approval. If you want a fully-autonomous release for a low-risk project, you can override that in your fork — but read the [Sprint Close Checklist](#) section in `CLAUDE.md` first.

### Database migrations

Migrations are flagged before sprint close. The framework will **never silently apply a migration to a remote database**. The `[release-manager]` lists pending migrations, you run them yourself (or approve the command), and only then is the sprint marked closed.

## Daily Use

After the initial setup is done, your daily commands are short:

| What you want to do | Command |
|---|---|
| Plan the next sprint | `[scrum-master] plan Sprint N` |
| Start sprint execution | `/run-sprint N` |
| Pause and ask "where are we?" | `[scrum-master] sprint status` |
| Close the sprint and release | `/sprint-close` |
| Audit document drift | `/doc-audit` |
| Add a new backlog item | `[product-manager] add backlog item: <description>` |

Anything else (writing code, reviews, tests, docs) flows automatically through the pipeline once a sprint is running.

## Common Pitfalls

- **Skipping Sprint 0** — every later sprint assumes `PRD.md` and `SOLUTION_DESIGN.md` exist. Don't skip it.
- **Empty `onboarding/` folder** — agents will produce generic output. Spend an hour on the onboarding docs; you'll save days later.
- **Approving sprint plans without reading them** — the scrum master proposes scope; you own scope. Cut items you don't actually want to ship.
- **Letting the scrum master close a sprint without UAT** — Gate 3 requires manual UAT. If you skip this, the framework's quality guarantees stop applying.
- **Editing `BACKLOG.md` mid-sprint without flagging it** — read the `Scope Change Control` and `Sprint Close Checklist` rules in `CLAUDE.md`.

## Repository Structure

```
claude-code-sdlc/
├── README.md                 # This file
├── LICENSE                   # MIT
├── CLAUDE.md                 # Core framework — copy to your project root
├── bootstrap.md              # All-in-one setup guide with document templates
├── agents/                   # 17 agent definitions — copy to your project
│   ├── scrum-master.md       # Pipeline orchestrator
│   ├── product-manager.md    # Requirements & backlog
│   ├── solution-architect.md # Architecture & design
│   ├── backend-engineer.md   # Backend code
│   ├── frontend-engineer.md  # Frontend code
│   ├── ai-ml-engineer.md     # AI/ML code
│   ├── test-engineer.md      # Automated tests
│   ├── code-reviewer.md      # Code quality review
│   ├── security-reviewer.md  # Security review
│   ├── qa-reviewer.md        # QA review
│   ├── seo-reviewer.md       # SEO review
│   ├── tester.md             # Manual UAT
│   ├── data-analyst.md       # Analytics & metrics
│   ├── marketing-manager.md  # Marketing strategy
│   ├── content-creator.md    # Marketing content
│   ├── technical-writer.md   # Documentation
│   └── release-manager.md    # Releases & deployment
├── commands/                 # Slash commands for .claude/commands/
│   ├── run-sprint.md         # Execute a sprint autonomously
│   ├── sprint-close.md       # Close sprint with parallel agents
│   └── doc-audit.md          # Audit document consistency
├── docs/
│   ├── how-it-works.md       # Pipeline mechanics deep dive
│   ├── customization-guide.md # Adapting to your stack
│   ├── model-routing.md      # Opus vs Sonnet rationale
│   └── example-sprint/       # Sanitized real sprint execution
│       ├── README.md
│       ├── SPRINT.md
│       ├── r5-findings.md
│       └── retrospective.md
└── .claude/
    └── settings.json.example # Example Claude Code settings with hooks
```

## Customization

The framework has two layers:

**Universal (don't change):**
- Pipeline structure (8 rounds, parallelization rules)
- Quality gates (8 gates, enforcement rules)
- Agent roles and responsibilities
- Document governance (sprint board, backlog sync)
- Context discipline (summarize-don't-quote, SPRINT.md as context contract)

**Project-specific (customize):**
- Tech stack rules (database patterns, auth library, framework conventions)
- File paths (source directories, test directories, migration paths)
- Compliance requirements (GDPR, CCPA, HIPAA, etc.)
- Localization (supported languages, date format)
- Build/test commands (test runner, type checker, linter)

See [docs/customization-guide.md](docs/customization-guide.md) for details.

## Key Concepts

### Agent Bracket Notation
Every agent response starts with `[agent-name]` — e.g., `[scrum-master] Sprint 5 has 4 active items.` This tells you which agent is working at a glance.

### SPRINT.md as Context Contract
Agents don't read each other's full output. The scrum master summarizes each round's results into SPRINT.md, and the next agent reads that summary. This keeps context lean and prevents bloat.

### Definition of Ready / Definition of Done
Every item has explicit readiness criteria (before build starts) and completion criteria (before marking done). No shortcuts.

### Pipeline Continuation
The pipeline runs automatically. After each round, the scrum master immediately launches the next round. You don't need to ask "what's next?" — it drives forward until blocked or done.

## FAQ

**Q: Do I need all 17 agents?**
No. The framework includes `[marketing-manager]`, `[content-creator]`, and `[seo-reviewer]` which are optional for many projects. The pipeline marks them as optional with `*` and skips them when not relevant. At minimum, you need the core 10: scrum-master, product-manager, solution-architect, backend-engineer, frontend-engineer, code-reviewer, security-reviewer, qa-reviewer, test-engineer, and tester.

**Q: What about the AI/ML engineer?**
If your project doesn't have an AI component, skip `[ai-ml-engineer]` in R3. The pipeline handles this gracefully — just remove it from the parallel round.

**Q: How much does this cost in API tokens?**
A full sprint with 3-4 items (M effort) typically runs through ~50-80 agent invocations. Using the Opus/Sonnet split saves roughly 40% compared to running everything on Opus. Actual cost depends on your codebase size and item complexity.

**Q: Can I use this with other AI coding tools?**
This framework is designed specifically for Claude Code's Agent tool, which supports parallel agent execution, model selection, and background tasks. The concepts (pipeline, gates, agent roles) are transferable, but the implementation relies on Claude Code's capabilities.

**Q: What if a gate fails?**
The scrum master routes failures back to the responsible agent. For example, if the security reviewer finds a CRITICAL issue, the backend engineer is relaunched with the specific findings. The pipeline doesn't proceed until the gate passes.

## Contributing

Contributions are welcome. If you've adapted the framework and found improvements, please open a PR.

Areas where contributions would be valuable:
- Agent definitions for additional roles (DevOps, DBA, UX researcher)
- Pipeline adaptations for different team structures
- Integration examples with CI/CD systems
- Cost optimization strategies

## License

MIT — see [LICENSE](LICENSE).

## Credits

Built by [George Papadongonas](https://github.com/geopap) through iterative development across 100+ production sprints. The framework evolved from real needs — every gate, every rule, every agent exists because something went wrong without it.
