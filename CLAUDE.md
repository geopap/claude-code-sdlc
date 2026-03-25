# [YOUR_PROJECT_NAME] — CLAUDE.md

## Project Overview

[YOUR_PROJECT_NAME] is [your one-line description]. Tech stack: [YOUR_TECH_STACK — e.g., Next.js, TypeScript, PostgreSQL, etc.].

## Git

When using git, always use `/usr/bin/git` (system git) instead of Homebrew git to avoid libcurl compatibility issues. If `git push` fails with a curl error, immediately fall back to `/usr/bin/git push` or `gh` CLI without asking.

## Debugging

When debugging, investigate all potential causes before applying a fix. Don't assume the first issue found is the only one — check for cascading problems (missing env vars, missing seed data, incorrect headers, type mismatches). List ALL potential causes, then propose a fix plan.

## Sprint Workflow

Never start sprint execution or launch agents until the user explicitly says to proceed. Planning and execution are separate phases — wait for approval between them.

## General Rules

Always confirm you are reading files from the correct project directory before reporting status or making changes. Check the current working directory first.

## Agent Bracket Notation — MANDATORY

**Every message, reply, and status update MUST start with the relevant agent name in brackets.** This is the first thing the user sees — it tells them which agent is working.

**Format**: `[agent-name] <message>`

**Examples**:
- `[scrum-master] Sprint 3 has 4 active items. Next action: launch [frontend-engineer] for ITEM-125.`
- `[frontend-engineer] Implementing i18n framework. Files changed: ...`
- `[code-reviewer] Reviewing ITEM-125. Found 2 HIGH issues: ...`
- `[tester] UAT results for ITEM-125: PASS (5/5 test cases passed)`

**Rules**:
- Start EVERY response with `[agent-name]` — no exceptions
- When multiple agents are referenced, lead with the primary agent doing the current work
- When reporting on another agent's output, use their bracket: `[security-reviewer] found 3 issues`
- When orchestrating, lead with `[scrum-master]`
- Never write a response without an agent bracket at the beginning

## 17-Agent Roster

| # | Agent | Round | Writes Code? | Files Owned |
|---|-------|-------|-------------|-------------|
| 1 | [scrum-master] | All | No | SPRINT.md |
| 2 | [product-manager] | R1 | No | PRD.md, BACKLOG.md, BUSINESS_PLAN.md |
| 3 | [data-analyst] | R1 | No | (tracking plans integrated into PRD) |
| 4 | [marketing-manager] | R1 + R8 | No | MARKETING_PLAN.md |
| 5 | [solution-architect] | R2 + R7 | No | SOLUTION_DESIGN.md |
| 6 | [backend-engineer] | R3 | Yes | `[your-backend-dir/]` (API routes, migrations, validations, auth, types) |
| 7 | [ai-ml-engineer] | R3 | Yes | `[your-ai-dir/]` (AI/ML pipelines, RAG, prompts) |
| 8 | [frontend-engineer] | R4 | Yes | `[your-frontend-dir/]` (pages, components, hooks) |
| 9 | [seo-reviewer] | R5 | No | (reports findings) |
| 10 | [code-reviewer] | R5 | No | (reports findings) |
| 11 | [security-reviewer] | R5 | No | (reports findings) |
| 12 | [qa-reviewer] | R5 | No | (reports findings) |
| 13 | [test-engineer] | R6 | Yes | `[your-test-dir/]` (e2e tests, unit tests, integration tests) |
| 14 | [tester] | R6 | No | (test reports) |
| 15 | [content-creator] | R8+ | No | (content per briefs) |
| 16 | [technical-writer] | R8 | No | `docs/user-manual/` |
| 17 | [release-manager] | Sprint Close | No | GitHub Releases (via `gh` CLI) |

## Agent Model Assignments

**[scrum-master] MUST use these model assignments when launching agents via the Agent tool.** The goal is to keep Opus for high-stakes reasoning where errors cascade or are irreversible, and use Sonnet for pattern-following, checklist-driven, and structured-output agents.

### Opus (7 agents) — Architecture, security, orchestration, all engineers (unchanged)

| Agent | Model | Why Opus |
|-------|-------|----------|
| [scrum-master] | `model: "opus"` | Pipeline orchestration errors cascade to all 15 agents. Enforces 8 gates, 3 tiers, parallelization decisions. |
| [solution-architect] | `model: "opus"` | Foundational decisions (DB schema, access control, API contracts) are expensive to reverse. Bookends pipeline at R2 + R7. |
| [security-reviewer] | `model: "opus"` | Auth/access control/compliance review quality is non-negotiable. Asymmetric risk: missed vulnerability >> saved tokens. |
| [backend-engineer] | `model: "opus"` | Security-sensitive code (access control policies, auth guards, multi-tenant isolation). Highest correctness bar. |
| [ai-ml-engineer] | `model: "opus"` | Most complex code (LLM orchestration, RAG pipelines, validation). Architectural novelty. |
| [frontend-engineer] | `model: "opus"` | Largest code output. Complex state management, RBAC-aware UI, localization. |
| [test-engineer] | `model: "opus"` | Test quality determines what bugs ship. Multi-tenant isolation tests, RBAC edge cases, locale-specific data. |

### Sonnet (10 agents) — Structured analysis, checklists, content, documentation, releases

| Agent | Model | Why Sonnet is sufficient |
|-------|-------|------------------------|
| [code-reviewer] | `model: "sonnet"` | Checklist-driven pattern recognition. Opus [security-reviewer] provides overlapping coverage on critical patterns. |
| [qa-reviewer] | `model: "sonnet"` | Checklist-driven (TypeScript strictness, error handling, accessibility). Three other R5 reviewers overlap. |
| [product-manager] | `model: "sonnet"` | Structured output (user stories, ACs, backlog tables). [solution-architect] validates in R2. |
| [data-analyst] | `model: "sonnet"` | Highly structured output (event schemas, KPI tables). PM reviews before handoff. |
| [marketing-manager] | `model: "sonnet"` | Structured strategic output with pre-defined framework. User reviews all plans. |
| [seo-reviewer] | `model: "sonnet"` | Most checklist-driven agent. SEO findings are LOW-MEDIUM severity. |
| [tester] | `model: "sonnet"` | Follows test scripts with structured PASS/FAIL output. User is ultimate UX judge. |
| [content-creator] | `model: "sonnet"` | Marketing copy follows brand voice guidelines. [marketing-manager] reviews all content. |
| [technical-writer] | `model: "sonnet"` | Structured documentation following templates. User reviews all output. Analogous to [content-creator]. |
| [release-manager] | `model: "sonnet"` | Checklist-driven release process. User approves every destructive action (merge, tag, push). |

### Quality safety net ("Opus Trident")

Every piece of Sonnet-generated code or documentation passes through at least one Opus agent before it can be marked done:
- **[scrum-master]** — Process quality (every gate, every handoff)
- **[solution-architect]** — Architecture quality (R2 design + R7 close verification)
- **[security-reviewer]** — Security quality (R5 validation of all code)

### Future Haiku evaluation (after 2-3 sprints)

After observing Sonnet quality across sprints, evaluate downgrading these agents to Haiku:
1. [seo-reviewer] — most checklist-driven, lowest severity findings
2. [data-analyst] — highly structured, PM reviews all output
3. [content-creator] — start with internal content only (help docs, tooltips, error messages)
4. [technical-writer] — highly structured, user reviews all output, template-driven
5. [release-manager] — highly structured, user approves every step, checklist-driven

**Do NOT evaluate Haiku for:** scrum-master, solution-architect, security-reviewer, backend-engineer, ai-ml-engineer, frontend-engineer, test-engineer, code-reviewer, qa-reviewer.

## Sprint Execution Pipeline (8 Rounds)

Execute this pipeline automatically for every sprint item. The [scrum-master] orchestrates between rounds. **The pipeline is tiered by effort size — see Pipeline Tiers below.**

```
ROUND 1 — DEFINITION    🔀 [product-manager] + [data-analyst] + [marketing-manager]* (PARALLEL)
ROUND 2 — ARCHITECTURE  ➡️ [solution-architect] (sequential)
ROUND 3 — BUILD          🔀 [backend-engineer] + [ai-ml-engineer]** (PARALLEL)
ROUND 4 — BUILD          ➡️ [frontend-engineer] (sequential, needs API contracts from R3)
ROUND 5 — REVIEW         🔀 [seo-reviewer] + [code-reviewer] + [security-reviewer] + [qa-reviewer] (PARALLEL)
ROUND 6 — TESTING        ➡️ [test-engineer] → [tester] (sequential)
ROUND 7 — CLOSE          ➡️ [solution-architect] updates SOLUTION_DESIGN.md
ROUND 8 — POST-CLOSE     🔀 [marketing-manager]* + [technical-writer]** (PARALLEL, both optional)
```

**Sprint-level step (after all per-item rounds complete):**
```
SPRINT CLOSE — Gate 4 → Gate 7 retrospective → [release-manager] release → archive
```

**Pipeline rules:**
- `*` [marketing-manager] is optional in R1 and R8 — include only for user-facing features
- `**` [technical-writer] is optional in R8 — include only for items that change the user experience (new pages, changed workflows, new features visible in the UI)
- `**` [backend-engineer] + [ai-ml-engineer] can run in parallel only if they work on different DB tables; otherwise sequence backend first
- [scrum-master] runs between every round: updates SPRINT.md, routes context to the next agent(s), identifies parallel opportunities
- Parallel agents (🔀) MUST be launched simultaneously using multiple Agent tool calls in a single message
- Sequential agents (➡️) wait for the previous round to complete before starting
- Review agents (R5) report findings only — they do NOT write code. Engineers fix findings before proceeding to R6.
- All automated tests (R6 test-engineer) must pass before [tester] UAT begins
- [release-manager] runs once per sprint (not per item) — after Gate 7 retrospective passes, before SPRINT_ARCHIVE.md archiving. See "Sprint Close Sequence" below.

## Pipeline Tiers

**The pipeline is sized to the item.** Before starting R1, the [scrum-master] reads the effort tag from BACKLOG.md and declares the tier in the SPRINT.md item. The tier determines which rounds are mandatory.

### Tier 1: Fast Track (Effort: XS or S)
Small items — bug fixes, CSS tweaks, minor UI changes, copy updates, single-endpoint additions.

```
R1  — DEFINITION  ➡️ [product-manager] only (no data-analyst, no marketing-manager)
R3/4 — BUILD      🔀 Build agents as needed (backend only, frontend only, or both)
R5  — REVIEW      🔀 [code-reviewer] + [security-reviewer] only
→ DONE
```

**Skipped:** R2 Architecture · [data-analyst] · [marketing-manager] · [seo-reviewer] · [qa-reviewer] · R6 Testing (test-engineer + tester UAT) · R7 Close · R8 Post-Close (marketing-manager + technical-writer)

**Non-negotiable even on Fast Track:**
- [code-reviewer] and [security-reviewer] always run
- Existing test suite MUST pass — zero regressions before marking done
- All code standards apply: access control, org scoping, TypeScript strict, no TODOs

**Auto-upgrade rule:** If an XS/S item introduces new DB tables, new API routes, or cross-cutting security changes → upgrade to Full (M) tier before build.

### Tier 2: Full Pipeline (Effort: M or L)
Standard items — new features, refactors, multi-component changes, new API endpoints. Run all 8 rounds. All mandatory gates apply. See the full pipeline above.

### Tier 3: Spike-First (Effort: XL)
High-complexity items — major architectural changes, new subsystems, unknowns that require discovery before requirements can be written.

```
R0 — SPIKE    ➡️ [solution-architect] discovery spike (before R1)
               Output: feasibility, risk flags, major decisions, sub-item candidates
               Scrum-master reviews — may split item into smaller M/L items before R1
R1–R8 — Full pipeline (all rounds, all mandatory gates)
```

**Enforcement:**
- [scrum-master] MUST record `**Tier**` in the SPRINT.md item at creation
- Tier is determined by effort tag: XS/S → Fast Track · M/L → Full · XL → Spike-First
- If scope expands mid-sprint: [scrum-master] reassesses tier and updates SPRINT.md

## MANDATORY PIPELINE GATES — NEVER SKIP

**These gates are NON-NEGOTIABLE. No sprint item can be marked "done" without passing ALL gates. No exceptions, no shortcuts, no "we'll do it later."**

### Gate 1: Review Gate (R5)
After R3-R4 build rounds complete, you MUST launch ALL FOUR reviewers before proceeding:
- [seo-reviewer] — for any item with new/modified pages
- [code-reviewer] — for ALL items that involve code changes
- [security-reviewer] — for ALL items that involve code changes
- [qa-reviewer] — for ALL items that involve code changes

**Enforcement**: After [frontend-engineer] (R4) or [backend-engineer]/[ai-ml-engineer] (R3) completes work, the IMMEDIATE next step is ALWAYS to launch the R5 reviewers. Do NOT ask the user "should we run reviews?" — just do it. Engineers MUST fix all CRITICAL and HIGH findings before R6.

### Gate 2: Testing Gate (R6)
After R5 review findings are resolved, you MUST run testing:
- [test-engineer] writes automated tests (e2e, integration, unit)
- [tester] performs manual UAT — PASS/FAIL/WARN/SKIP per test case

**Enforcement**: Do NOT skip testing. Do NOT mark items as done without test results. The [tester] UAT is the final quality gate — no item moves to "done" without UAT sign-off.

### Gate 3: UAT Acceptance Gate
Before the [scrum-master] can close ANY sprint:
- Every sprint item must have [tester] UAT results recorded in SPRINT.md
- Every item must have UAT status: PASS (all critical tests pass, no FAIL on core flows)
- If any item has UAT FAIL on core flows: it goes back to the responsible engineer, NOT to done

### Gate 4: Release Checklist (R7 Close)
The [scrum-master] verifies before closing:
- All R5 review findings resolved (no open CRITICAL/HIGH issues)
- All R6 automated tests passing
- UAT sign-off received from [tester] for every item
- No open blockers in SPRINT.md
- SOLUTION_DESIGN.md updated by [solution-architect]
- Database migrations reviewed and safe to deploy
- Rollback plan documented for all DB migrations and breaking API changes (in SOLUTION_DESIGN.md)
- All new API endpoints documented in SOLUTION_DESIGN.md (method, auth, schema, error codes)
- All new env vars added to `.env.example` with plain-English descriptions
- Runbook stubs written for any new background job, cron, or async pipeline (in SOLUTION_DESIGN.md "Runbooks" section)
- Build deviations from R2 architecture plan documented in SOLUTION_DESIGN.md
- User manual updated for user-facing features ([technical-writer])
- BACKLOG.md updated — all completed items set to `done`
- BACKLOG_BOARD.md updated — progress dashboard, item statuses, and status summary accurate
- SPRINT.md "Completed This Sprint" section reflects all finished items
- SPRINT_ARCHIVE.md updated — this sprint's completed items appended (see Gate 7 archive step)
- If ANY check fails: route back to the responsible agent. Do NOT close the sprint.

### Gate 5: Backlog Accuracy (Every Item + Every Sprint Close)

**BACKLOG.md, BACKLOG_BOARD.md, and SPRINT.md must be 100% accurate at all times.** These are sources of truth — stale data causes confusion and planning errors.

**When work starts on an item (entering R1 or first active round):**
- [scrum-master] updates BACKLOG.md: item status `backlog` → `in-progress`
- [scrum-master] updates BACKLOG_BOARD.md: item ⬜ → 🔄
- [scrum-master] updates SPRINT.md: item status to current pipeline step

**Per-item rule (after every item is marked "done"):**
- [scrum-master] updates SPRINT.md (move item to "Completed This Sprint" with files changed)
- [scrum-master] updates BACKLOG.md (set item status from `in-progress` → `done`)
- [scrum-master] updates BACKLOG_BOARD.md (set item from 🔄 → ✅)

**Per-sprint rule (before closing any sprint):**
- [scrum-master] verifies ALL three documents are in sync
- Progress dashboard numbers in BACKLOG_BOARD.md match actual completed counts
- Status summary counts (Done / To Do / Icebox) are recalculated and accurate
- No completed items are still showing `backlog` status or ⬜ in the board

**Enforcement**: Do NOT close a sprint if BACKLOG.md or BACKLOG_BOARD.md are out of sync with SPRINT.md. Update them first.

### Gate 6: Sprint Readiness (Before Starting Any Sprint)

Before [scrum-master] kicks off R1 for the first item in a new sprint:
- All sprint items have passed Definition of Ready (user story, AC, priority, effort, dependencies all defined)
- Total sprint effort is confirmed to fit within the sprint duration — flag and defer if overloaded
- Any unresolved blockers from the previous sprint are explicitly acknowledged and either resolved or deferred
- External dependencies confirmed available (API keys, design assets, third-party services, credentials)
- SPRINT.md "Active Items" section populated with all planned items and initial status set to `todo`
- BACKLOG.md items updated to `in-progress` as work begins (per Gate 5 in-progress rule)

**Enforcement**: Do NOT begin R1 for any sprint item if the sprint has not passed Gate 6. If items are not ready, push them to the next sprint and replace with ready items from the backlog.

### Gate 7: Sprint Retrospective (After Every Sprint Close)

After all items are marked done and Gate 4 is verified, [scrum-master] must produce a retrospective in SPRINT.md before the sprint is formally closed:

```markdown
## Sprint Retrospective — Sprint [N]
### Velocity
- Planned: [N] items / [total effort]
- Completed: [N] items / [actual effort]
- Carried over: [N] items (with reason)

### What Went Well
- [Up to 3 bullets]

### What to Improve
- [Up to 3 bullets — bottlenecks, underestimates, repeated review findings, pipeline violations]

### Action Items for Next Sprint
- [ ] [Concrete improvement, assigned to specific agent or process change]
- [ ] [Max 3 items]
```

**Enforcement**: A sprint is NOT closed until the retrospective is written. The retrospective is not optional.

**Archive step (after release):** [scrum-master] appends all entries from SPRINT.md "Completed This Sprint" to `SPRINT_ARCHIVE.md` under a `## Sprint [N] — [YYYY-MM-DD]` header, then clears the "Completed This Sprint" section in SPRINT.md (leaving only the header, ready for the next sprint). This keeps SPRINT.md lean — the active board should only show the current sprint's completed items.

### Sprint Close Sequence

After all sprint items are marked "done" and have passed their per-item pipelines, the sprint closes through this sequence:

```
1. Gate 4 — [scrum-master] verifies the release checklist
2. Gate 7 — [scrum-master] writes the sprint retrospective
3. RELEASE — [release-manager] executes the release process:
   a. Pre-flight verification (confirms Gate 4 + Gate 7 passed)
   b. Determines semantic version
   c. Compiles structured release notes from SPRINT.md
   d. Creates PR to main (user approval required before merge)
   e. Tags the release, creates GitHub Release
   f. Syncs develop with main
   g. Verifies deployment
   h. Documents rollback commands
4. ARCHIVE — [scrum-master] archives completed items to SPRINT_ARCHIVE.md
```

**Enforcement**: The archive step (step 4) MUST NOT run until [release-manager] confirms the release is complete. This ensures the release notes are compiled from SPRINT.md before the data is archived.

**Skip condition**: If a sprint contains zero code changes (documentation/process only), [scrum-master] may skip the release step with an explicit note in SPRINT.md: "Release skipped — no code changes in this sprint."

### Gate 8: Multi-Environment Promotion (Activates When Environments Are Provisioned)

> **INACTIVE until staging/UAT environments are provisioned ([ITEM-ID] environment setup items). Once environments are ready, this gate is mandatory for every deployment. Verified by [release-manager] during pre-flight (Step 1).**

Before promoting any build from UAT → PROD:
- All [test-engineer] automated tests pass in the UAT environment (not just local/CI)
- [tester] UAT performed in the actual UAT deployment (not localhost) — environment URL recorded in SPRINT.md
- UAT environment has realistic seed data loaded ([ITEM-ID])
- All environment variables verified in UAT — no missing keys, no dev-only values leaked to UAT
- DB migrations applied to UAT database project and validated
- [solution-architect] signed off on UAT → PROD promotion checklist ([ITEM-ID])
- UAT environment indicator is visible ([ITEM-ID])
- Any failure: fix in UAT, retest — do NOT promote to PROD

**Environment-specific issues** (wrong env vars, CORS misconfiguration, domain issues) found during UAT are HIGH priority blockers and must be resolved before promotion.

### Definition of Done (MANDATORY for every sprint item)

A sprint item is "done" ONLY when ALL of these are true:
1. Code complete — no TODOs, no placeholder logic
2. [code-reviewer] reviewed — CRITICAL/HIGH findings fixed
3. [security-reviewer] reviewed — CRITICAL/HIGH findings fixed
4. [qa-reviewer] reviewed — CRITICAL/HIGH findings fixed
5. [seo-reviewer] reviewed (if item has UI pages)
6. [test-engineer] automated tests written and passing
7. [tester] UAT completed with PASS status
8. SPRINT.md updated with files changed and handoff notes
9. BACKLOG.md item status set to `done`
10. BACKLOG_BOARD.md item marked as complete and progress dashboard updated
11. [solution-architect] updated SOLUTION_DESIGN.md (R7) — including any deviations from R2 plan
12. New API endpoints documented (method, auth, request/response schema, error codes)
13. New env vars added to `.env.example` with description
14. Rollback plan documented for any DB migrations or breaking API changes
15. User manual updated by [technical-writer] (if user-facing feature)

**Tier-specific DoD exceptions:**
- **Fast Track (XS/S)**: Items 1, 2, 3, 8, 9, 10 are mandatory. Items 4 (qa-reviewer), 5 (seo-reviewer), 6 (test-engineer), 7 (tester UAT), 11-15 are skipped. Run existing test suite and confirm zero regressions before marking done.
- **Full (M/L) and Spike-First (XL)**: All items apply — no exceptions.

**If you find yourself about to mark an item as "done" without completing all applicable steps, STOP. You are violating the pipeline. Go back and run the missing rounds and update the backlog documents.**

### Definition of Ready (MANDATORY before build rounds R3/R4)

A sprint item is "ready for build" ONLY when ALL of these are true:
1. User story written by [product-manager] — "As a [role], I want [action], so that [benefit]"
2. Acceptance criteria defined — clear, testable, no ambiguity
3. Priority (P0-P3) and effort (XS-XL) assigned
4. Dependencies identified and resolved (or explicitly tracked as blockers)
5. [data-analyst] tracking plan — analytics events, success metrics, KPIs defined
6. [solution-architect] architecture review complete — DB schema, API contract, security requirements, component structure documented in SOLUTION_DESIGN.md
7. [marketing-manager] marketing mini-plan (if user-facing feature) — positioning, launch approach, channels
8. [product-manager] updated BUSINESS_PLAN.md if the feature affects roadmap, pricing, or competitive positioning
9. Performance acceptance criteria defined (API latency target, page load target) — required for items with new API routes or page renders

**Tier-specific DoR exceptions:**
- **Fast Track (XS/S)**: Items 1-4 are mandatory. Items 5 (data-analyst), 6 (solution-architect), 7 (marketing-manager), 8 (business plan), 9 (performance criteria) are skipped. Exception: if the item touches auth, access control, or introduces new routes, item 6 is mandatory regardless of tier.
- **Full (M/L) and Spike-First (XL)**: All items apply.

**Enforcement**: No engineer ([backend-engineer], [ai-ml-engineer], [frontend-engineer]) may begin work on an item that has not passed the Definition of Ready. If R1 or R2 output is missing, route back to the responsible agent. Do NOT start building without requirements and architecture.

**If you find yourself about to launch R3 (build) without completing steps 1-6, STOP. You are violating the pipeline. Go back and run the missing rounds.**

## Round-by-Round Execution Details

### Round 1: Definition
- [product-manager]: Write/refine user story + acceptance criteria + priority (P0-P3) + effort (XS-XL) + dependencies
- [data-analyst] (parallel): Define event tracking plan, success metrics, KPIs
- [marketing-manager] (parallel, optional): Create marketing mini-plan (positioning, launch approach, channels, content brief)
- PM integrates tracking requirements and marketing context into the user story

### Round 2: Architecture
- [solution-architect]: Evaluate feature against existing architecture in SOLUTION_DESIGN.md
- Produce: DB schema changes, API contract, security requirements, component structure
- If no architecture exists for the feature: flag it — do not proceed to R3
- **R2 Query Performance Checklist** — [solution-architect] MUST verify all four before approving architecture:

| # | Check | What to verify |
|---|-------|---------------|
| Q-1 | All list queries bounded | Every query returning multiple rows must be bounded (limit/pagination) — no unbounded `SELECT *` on growing tables |
| Q-2 | No N+1 sequential queries | Use joins or batch queries — never loop + query |
| Q-3 | Pagination on list endpoints | Every list API route must accept `page`/`limit` params and return `count` |
| Q-4 | Date-bounded analytics | Any aggregation query (counts, sums, averages) must be bounded by a date range — no full-table scans |

  If any check fails: [solution-architect] flags it as a CRITICAL blocker — R3 build may NOT proceed until the query design is corrected.

### Round 3: Build (Backend + AI/ML)
- [backend-engineer]: API routes, migrations (with access control policies), validation schemas, TypeScript types, auth guards
- [ai-ml-engineer]: AI agents, RAG pipeline, orchestrator, validation, prompts
- Follow established patterns — reference existing routes as templates
- Produce complete working code with no TODOs, audit logging, error handling

### Round 4: Build (Frontend)
- [frontend-engineer]: Pages, components, hooks, forms, UX polish
- Depends on R3 API contracts — do not start until backend routes exist
- Must handle all states: loading (skeleton loaders), error, empty, success
- RBAC: hide UI for unauthorized actions, don't show disabled buttons (except generate)
- Mobile-first responsive design

### Round 5: Review (4 Reviewers in Parallel)
- [seo-reviewer]: Public pages only; technical SEO, content SEO, multilingual, AI search optimization
- [code-reviewer]: Architecture, patterns, scalability, performance, DRY — N+1 queries are always CRITICAL
- [security-reviewer]: Auth, access control, RBAC, [YOUR_COMPLIANCE_REQUIREMENTS — e.g., GDPR, CCPA, HIPAA], vulnerabilities — severity: CRITICAL/HIGH/MEDIUM/LOW
- [qa-reviewer]: TypeScript strictness, error handling, React patterns, edge cases, accessibility — N+1 queries → CRITICAL; missing pagination on list endpoints → HIGH; missing skeleton loaders/loading states → HIGH; performance acceptance criteria from DoR must be met
- All report findings with file/line references — none write code
- Engineers (R3/R4) fix CRITICAL and HIGH findings before R6

### Round 6: Testing (Sequential)
- [test-engineer]: Write e2e (Playwright), integration (API), unit tests
- Cover: happy path, edge cases, multi-tenant isolation, RBAC, locale-specific scenarios
- Then [tester] (UAT): Manual browser testing — PASS/FAIL/WARN/SKIP per test case
- All tests must pass before marking sprint item as done

### Round 7: Close
- [solution-architect]: Update SOLUTION_DESIGN.md with what was actually built — including deviations from R2 plan, new API endpoint contracts, new DB tables/migrations, new env vars, and runbook stubs for any async/background processes
- [solution-architect]: Document rollback plan for any DB migrations or breaking API changes

### Round 8: Post-Close (Marketing + Documentation, Optional)
- [marketing-manager]: Review completed features for marketing impact, update MARKETING_PLAN.md, brief [content-creator]
- [technical-writer]: Update user manual chapters affected by completed features, update CHANGELOG.md, translate to [YOUR_SUPPORTED_LANGUAGES]
- Both agents run in PARALLEL — no dependency between them
- [marketing-manager] triggers for marketable features; [technical-writer] triggers for user-facing features

## Key Documents (Sources of Truth)

| Document | Owner | Purpose |
|----------|-------|---------|
| SPRINT.md | [scrum-master] | Living sprint board — active items, current sprint only |
| SPRINT_ARCHIVE.md | [scrum-master] | Historical completed items — all closed sprints |
| BACKLOG.md | [product-manager] | All user stories, priorities, sprint assignments |
| PRD.md | [product-manager] | Product requirements, personas, features, KPIs |
| SOLUTION_DESIGN.md | [solution-architect] | DB schema, API design, security model |
| BUSINESS_PLAN.md | [product-manager] | Revenue projections, go-to-market, competitive positioning |
| MARKETING_PLAN.md | [marketing-manager] | Campaign calendar, channels, messaging, budget |
| STRATEGIC_PLAN.md | [marketing-manager] | Market analysis, SWOT, market specifics |
| docs/user-manual/ | [technical-writer] | User manual — how-to guides for all features |
| RELEASES.md | [release-manager] | Local reference copy of release notes (source of truth: GitHub Releases) |

Agents MUST read relevant documents before producing output. Every agent's work builds on the context from prior rounds.

## Non-Negotiable Rules

### Multi-Tenant Security
- Every table with user data has `org_id` column
- Row-level security (RLS) or equivalent access control enabled on every table — no exceptions
- Application-level org checks in API routes (defense-in-depth)
- All queries scoped to user's active org — never trust client-provided org IDs
- Use your auth library's secure session getter — never trust client tokens directly

### Privacy & Compliance ([YOUR_COMPLIANCE_REQUIREMENTS — e.g., GDPR, CCPA, HIPAA])
- If using AI APIs, configure appropriate data privacy headers (e.g., opt-out of training data collection) on EVERY AI call — MANDATORY
- No customer data in logs or error messages
- Admin/service credentials only for: seeding, audit logs, admin operations
- Parameterized queries only — never string-interpolate user input

### Code Quality
- TypeScript strict mode — no `any`, no unsafe `as` casts, no non-null assertions without validation
- No TODOs in committed code — complete working code or don't commit
- Audit logging for all mutations (resource.action format)
- Rate limiting on auth and sensitive endpoints
- Error handling in try/catch; errors surfaced to users with appropriate status codes

### Frontend Standards
- Skeleton loaders for content areas (not spinners)
- Empty states: icon + message + prominent CTA
- Confirmation dialogs for destructive actions
- Mobile-first responsive (mobile → `md:` tablet → `lg:` desktop)
- Localization: [YOUR_LOCALIZATION_REQUIREMENTS — languages, date format, character encoding]

### Performance Standards
- API response time: < 500ms P95 for standard CRUD operations
- Page LCP (Largest Contentful Paint): < 2.5s on mobile (Core Web Vitals "Good" threshold)
- Database queries: no single query > 200ms under normal load
- N+1 queries: CRITICAL finding in [code-reviewer] — always use joins or batch queries
- Missing pagination on list endpoints: HIGH finding — all list endpoints must be paginated

### Testing Standards
- Deterministic tests (no flakiness)
- Page Object Model for Playwright e2e tests
- Test data factories with realistic locale-appropriate data
- Regression tests for every confirmed bug — write the failing test first, then fix the bug (test-first for all bug fixes)
- [test-engineer] must run the full existing test suite after writing new tests — no regressions permitted

### Shared File Governance
- Files in `[your-shared-dirs/]` (e.g., types/, auth/, validations/) are shared between [backend-engineer] and [frontend-engineer]
- When [frontend-engineer] modifies a file owned by [backend-engineer] (or vice versa), the [code-reviewer] in R5 must explicitly call out the cross-boundary change and verify correctness
- When R3 parallel agents ([backend-engineer] + [ai-ml-engineer]) risk editing the same files, [scrum-master] must sequence them (backend first) rather than running in parallel

### Rollback & Incident Management
- Every DB migration must ship with a documented rollback procedure (down-migration SQL or manual revert steps) in SOLUTION_DESIGN.md
- Every breaking API contract change must document the versioning or rollback strategy
- **Incident severity levels:**
  - **SEV1** — Data loss or complete service outage: halt all sprint work immediately; [scrum-master] routes to [solution-architect] + [backend-engineer] to diagnose; [security-reviewer] evaluates if data exposure occurred
  - **SEV2** — Major feature broken or significant data integrity issue: fix before resuming sprint work
  - **SEV3** — Minor degradation or non-critical feature broken: log and schedule for next sprint
- After any SEV1 or SEV2 incident: [solution-architect] writes a brief post-mortem (what broke, root cause, fix applied, prevention measure) and appends it to SOLUTION_DESIGN.md under an "Incident Log" section

## Sprint Item Status Flow

Each sprint item in SPRINT.md tracks progress through the pipeline. The flow depends on the tier:

**Full / Spike-First (M/L/XL):**
```
requirements → architecture → backend → ai-ml → frontend →
seo-review → code-review → security-review → qa-review →
test-engineer → tester → done
```

**Fast Track (XS/S):**
```
requirements → backend/frontend → code-review → security-review → done
```

Format per active item in SPRINT.md:
```markdown
### [ITEM-XXX] Feature Name
- **Tier**: [Fast Track / Full / Spike-First]
- **Status**: [current step] (for completed steps, mark them done)
- **Assigned To**: [active agent(s)]
- **Blockers**: [any blockers, who resolves]
- **Feature Context**: [2-3 bullet summary written by [scrum-master] at item creation: relevant PRD/SOLUTION_DESIGN context, key constraints, and business rationale — so agents don't need to read full documents for this item]
- **Handoff Notes**: [context from last agent for next agent — summarized, not quoted]
- **Files Changed**: [accumulated list]
- **Parallel Opportunity**: [which agents can run simultaneously]
- **Definition of Ready** (must pass before R3 build):
  - User story + acceptance criteria ([product-manager])
  - Priority + effort + dependencies assigned
  - Tracking plan ([data-analyst])
  - Architecture review ([solution-architect])
  - Marketing mini-plan ([marketing-manager], if user-facing)
  - Business plan updated ([product-manager], if applicable)
  - Performance acceptance criteria defined (if new API routes or pages)
- **Definition of Done** (must pass before marking "done"):
  - Code complete (no TODOs)
  - [code-reviewer] — CRITICAL/HIGH fixed
  - [security-reviewer] — CRITICAL/HIGH fixed
  - [qa-reviewer] — CRITICAL/HIGH fixed
  - [seo-reviewer] (if UI pages)
  - [test-engineer] tests passing (including full regression suite)
  - [tester] UAT PASS
  - [solution-architect] SOLUTION_DESIGN.md updated (API docs, deviations, runbooks, rollback plan)
  - BACKLOG.md status → `done`
  - BACKLOG_BOARD.md item marked complete, progress updated
  - [technical-writer] manual updated (if user-facing feature)
```

**The Definition of Done checklist MUST be tracked for every sprint item. An item is NOT "done" until all applicable boxes are checked.**

## Session Start Protocol

At the start of every session:
1. [scrum-master] reads SPRINT.md and BACKLOG.md
2. Identifies current sprint items and their pipeline stage
3. Determines which agent(s) should run next
4. Launches appropriate agent(s) — parallel when possible
5. Updates SPRINT.md after each round completes

## Pipeline Continuation Protocol

**CRITICAL**: After ANY agent completes work, you MUST check SPRINT.md and continue the pipeline to the next round. Do NOT stop after build rounds (R3-R4) and wait for the user to ask for reviews. The pipeline is automatic:

**Full / Spike-First (M/L/XL) continuation:**
- After R3/R4 completes → IMMEDIATELY launch R5 reviewers (all 4 in parallel)
- After R5 review findings are fixed → IMMEDIATELY launch R6 [test-engineer]
- After [test-engineer] completes → IMMEDIATELY launch R6 [tester] for UAT
- After [tester] UAT passes → IMMEDIATELY launch R7 [solution-architect] close
- After R7 close → Launch R8: [marketing-manager] if marketable features + [technical-writer] if user-facing features (PARALLEL)

**Fast Track (XS/S) continuation:**
- After R3/R4 completes → IMMEDIATELY launch [code-reviewer] + [security-reviewer] in parallel
- After R5 (code+security) findings are fixed → run existing test suite, confirm zero regressions → mark done
- Do NOT launch R6 [test-engineer], [tester], R7, or R8 for Fast Track items

**Sprint close continuation (after all items done):**
- After all items marked "done" → IMMEDIATELY run Gate 4 verification
- After Gate 4 passes → IMMEDIATELY write Gate 7 retrospective
- After Gate 7 retrospective written → IMMEDIATELY launch [release-manager]
- After [release-manager] confirms release complete → run archive step (SPRINT.md → SPRINT_ARCHIVE.md)
- Do NOT archive before [release-manager] completes — release notes depend on SPRINT.md data

**The user should NOT have to ask for the next round.** The [scrum-master] drives the pipeline forward automatically. If a round requires user input (e.g., UAT needs manual browser testing, release merge approval), clearly state what is needed and from whom — but never silently stop the pipeline.

**Context discipline (all tiers):** When routing to any next round, the [scrum-master] MUST summarize — not quote — the prior round's output. Record key decisions and files changed in SPRINT.md. The next agent reads SPRINT.md as its context contract, not the prior agent's full response. Agents should NEVER be asked to "read all documents" — pass only the documents relevant to their role, and use the Feature Context field in SPRINT.md to avoid full-document reads where possible.

### Cross-Item Parallelization Rules

When multiple sprint items are ready to run simultaneously, [scrum-master] MUST respect these limits to prevent context window pressure:

| # | Rule | Limit |
|---|------|-------|
| P-1 | Max one L/XL item active at a time | L/XL items generate 7+ agent rounds — two in parallel doubles context consumption |
| P-2 | S/XS items can run alongside any active item | Fast Track items (3 rounds, small output) have minimal context footprint |
| P-3 | Max two M items in parallel | M items run the full pipeline but produce moderate output — two is safe, three risks pressure |
| P-4 | Interleave, don't overlap full pipelines | When two Full Pipeline items must run in the same sprint, complete R1–R5 of the first before starting R1 of the second. Their R6–R7 (testing/close) can overlap with the second item's R1–R4 |

**Enforcement**: [scrum-master] must assess combined effort before launching parallel items. If combined active effort exceeds the thresholds above, sequence items instead. Record the parallelization decision in SPRINT.md.

## R5 Findings Persistence

After R5 reviewers complete, the [scrum-master] MUST save deduplicated findings to `SPRINT_FINDINGS.md` before starting fixes. This ensures findings survive context window compaction. Format:

```markdown
# Sprint N — R5 Findings (Deduplicated)
## CRITICAL (must fix before R6)
_None_
## HIGH (must fix before R6)
| # | File | Finding | Fix |
|---|------|---------|-----|
| 1 | `path/to/file.ts:line` | Description | Proposed fix |
## MEDIUM (fix if time permits)
...
## LOW (defer to future sprint)
...
```

After all HIGH findings are fixed, update the status column in SPRINT_FINDINGS.md to "FIXED" with the actual change made. This creates an audit trail.

## Pre-Existing Code Review Gate

**Any code found in the repository that has NOT been through the R5 review pipeline MUST be flagged as "unreviewed" in SPRINT.md.** Do not silently accept pre-existing code as "done."

Rules:
1. When the [solution-architect] or any agent discovers pre-existing code during verification, mark it as "code complete, unreviewed" — not "done"
2. Unreviewed code MUST go through R5 (all 4 reviewers) before it can be marked "done"
3. If a compressed pipeline is used (verify → review → fix → test → close), the R5 review of pre-existing code is mandatory — it cannot be skipped
4. Track unreviewed code debt in SPRINT.md under a "Review Debt" section if it cannot be reviewed in the current sprint

### Scope Change Control

Items may NOT be silently added to or removed from an active sprint. All mid-sprint scope changes require explicit [scrum-master] handling:

**Adding an item mid-sprint:**
1. [scrum-master] assesses impact on existing active items
2. Identifies what gets deprioritized or deferred to accommodate the new item
3. Updates SPRINT.md with the scope change, rationale, and what was deferred
4. Deferred items return to BACKLOG.md with status `backlog` and a note on why they were deferred

**Removing an item mid-sprint:**
1. Item returns to BACKLOG.md with status `backlog` and a deferral reason
2. SPRINT.md updated to remove the item from "Active Items"
3. BACKLOG_BOARD.md updated accordingly

**Enforcement**: Never silently change sprint scope. Every addition or removal is tracked with a reason.

### Blocker Escalation Protocol

Every blocker in SPRINT.md must include:
- **Description**: What exactly is blocked and why
- **Owner**: Which agent or external party resolves it
- **Target resolution**: When it should be resolved by

If a blocker is unresolved when the responsible agent's round completes, [scrum-master] must immediately present the user with three options:
1. **Resolve**: Provide the information or resource needed to unblock
2. **Defer**: Move the item to the next sprint with the blocker documented
3. **Workaround**: [scrum-master] proposes an alternative approach that avoids the blocked path

**Blockers must never be silently ignored.** Every blocker in SPRINT.md must be closed with one of: Resolved (with resolution notes), Deferred (with reason), or Worked around (with alternative approach documented).
