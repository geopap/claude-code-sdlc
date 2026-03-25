# Claude Code SDLC

A production-tested framework for running a **17-agent software development team** inside [Claude Code](https://claude.ai/code). Covers the full SDLC: requirements, architecture, build, review, testing, and release — orchestrated automatically through an 8-round pipeline with mandatory quality gates.

## Why This Exists

Most people use Claude Code for single-shot tasks. This framework turns it into an **automated development pipeline** where specialized agents handle different concerns — a product manager writes requirements, an architect designs the system, engineers build it, reviewers catch issues, and testers verify quality. All coordinated by a scrum master agent that drives the pipeline forward without manual intervention.

**Built from 15+ production sprints**, not a toy example. Every rule in the pipeline exists because something went wrong without it.

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

## Quickstart

### 1. Copy the framework files to your project

```bash
# Clone this repo
git clone https://github.com/geopap/claude-code-sdlc.git

# Copy the core files to your project
cp claude-code-sdlc/CLAUDE.md your-project/
cp -r claude-code-sdlc/agents/ your-project/agents/
cp -r claude-code-sdlc/commands/ your-project/.claude/commands/
```

### 2. Fill in the placeholders

Open `CLAUDE.md` and replace all `[PLACEHOLDER]` fields with your project details:
- `[YOUR_PROJECT_NAME]` — your project name
- `[YOUR_TECH_STACK]` — e.g., "Next.js 16, TypeScript, PostgreSQL, Prisma"
- `[YOUR_BACKEND_DIR]`, `[YOUR_FRONTEND_DIR]` — your source code paths
- `[YOUR_COMPLIANCE_REQUIREMENTS]` — e.g., "GDPR", "CCPA", "HIPAA"

Do the same for each file in `agents/`.

### 3. Initialize your project documents

Use `bootstrap.md` to create your project documents (SPRINT.md, BACKLOG.md, PRD.md, etc.) or create them manually following the templates.

### 4. Create your first backlog

Add items to `BACKLOG.md` with user stories, priorities (P0-P3), and effort estimates (XS-XL).

### 5. Run your first sprint

```
/run-sprint 1
```

The scrum master will verify readiness (Gate 6), then execute the pipeline for each item automatically.

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

Built by [George Papadakis](https://github.com/geopap) through iterative development across 15+ production sprints. The framework evolved from real needs — every gate, every rule, every agent exists because something went wrong without it.
