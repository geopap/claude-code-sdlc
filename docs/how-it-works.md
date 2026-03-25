# How It Works

This document explains the mechanics of the 17-agent pipeline — how agents are launched, how context flows between them, and how quality gates enforce standards.

## The Core Loop

The `[scrum-master]` agent is the orchestrator. It:

1. Reads `SPRINT.md` to understand the current state
2. Determines which agents should run next (and whether they can run in parallel)
3. Generates complete invocation prompts for each agent using the **Mandatory Invocation Template**
4. Launches agents via Claude Code's Agent tool
5. After agents complete, summarizes results into `SPRINT.md`
6. Repeats until the sprint is done

The human's role is to approve sprint scope, provide input when blocked, and approve releases. Everything else is automated.

## Context Discipline

**The #1 cause of pipeline failures is context bloat.** When an agent's output is pasted verbatim into the next agent's prompt, the context window fills up fast and quality degrades. The framework solves this with two rules:

### Rule 1: Summarize, Don't Quote

After each agent completes, the scrum master writes a **2-5 bullet summary** in SPRINT.md — not the full output. Key decisions, files changed, and flags raised. That's it.

**Bad:**
```
Here's the full output from the backend engineer: [200 lines of code and explanation]
```

**Good:**
```
Handoff Notes:
- Created /api/users/route.ts with GET (paginated, org-scoped) and POST endpoints
- Added migration 015_users_table.sql with RLS policies
- Flag: the POST endpoint needs rate limiting — deferred to security review
- Files: api/users/route.ts, migrations/015_users_table.sql, types/user.ts
```

### Rule 2: SPRINT.md is the Context Contract

Every agent reads SPRINT.md for its context — not the conversation history, not the prior agent's full response. SPRINT.md is the single source of execution state.

This means SPRINT.md must be kept current, lean, and precise. If context is lost (e.g., due to conversation compression), the scrum master can reconstruct state entirely from SPRINT.md.

## The Mandatory Invocation Template

Every agent invocation uses this structure:

```
SPRINT ITEM: [ITEM-ID] — [Feature Name]
TIER: [Fast Track / Full / Spike-First]
CURRENT PIPELINE STEP: [e.g., R4 — Frontend Build]

FEATURE CONTEXT:
[2-3 bullets: PRD context, architecture constraints, business rationale]

CONTEXT FROM PRIOR ROUND:
[2-5 bullets summarizing the previous agent's key decisions and outputs]

DOCUMENTS TO READ:
[Only the documents this specific agent needs — not all documents]

FILES CHANGED SO FAR: [accumulated list]

YOUR SPECIFIC TASK:
[Precise, scoped task with acceptance criteria references]

EXPECTED OUTPUT FORMAT:
[What to return: working code, findings report, test results, etc.]
```

This template exists because agents start fresh — they have no memory of prior rounds. The template gives them everything they need without overloading them.

## Parallel Execution

Claude Code supports launching multiple agents simultaneously. The pipeline exploits this wherever there are no dependencies:

- **R1**: Product manager + data analyst + marketing manager — all work from the backlog independently
- **R3**: Backend engineer + AI/ML engineer — if they don't share database tables
- **R5**: All 4 reviewers — each reviews independently, no coordination needed
- **R8**: Marketing manager + technical writer — independent post-close tasks

Sequential rounds (R2, R4, R6, R7) have hard dependencies — the next agent needs the previous one's output.

## R5 Findings Persistence

Review findings (R5) are critical data that must survive context window compression. After R5 completes, the scrum master saves deduplicated findings to `SPRINT_FINDINGS.md`:

```markdown
# Sprint N — R5 Findings (Deduplicated)

## CRITICAL (must fix before R6)
| # | File | Finding | Fix | Status |
|---|------|---------|-----|--------|
| 1 | api/users/route.ts:42 | SQL injection via string interpolation | Use parameterized query | FIXED |

## HIGH (must fix before R6)
...

## MEDIUM (fix if time permits)
...

## LOW (defer to future sprint)
...
```

After fixes are applied, the Status column is updated to "FIXED" with the actual change made. This creates an audit trail.

## Pipeline Tiers in Practice

### Fast Track (XS/S)

A CSS color change doesn't need an architecture review. Fast Track skips R2, R6, R7, R8 and uses only code + security reviewers:

```
R1 [product-manager] → Build → R5 [code-reviewer] + [security-reviewer] → Run existing tests → Done
```

**Auto-upgrade rule:** If an XS/S item turns out to need new database tables, new API routes, or cross-cutting security changes, it gets upgraded to Full Pipeline before build starts.

### Full Pipeline (M/L)

The standard path. All 8 rounds, all gates enforced. Most new features and refactors fall here.

### Spike-First (XL)

For items where you don't know enough to write requirements yet. The solution architect runs a discovery spike (R0) that produces feasibility analysis, risk flags, and may split the XL item into smaller M/L items before the full pipeline runs.

## Sprint Close Sequence

After all items are done:

1. **Gate 4** — Scrum master verifies the release checklist
2. **Gate 7** — Scrum master writes the retrospective (velocity, improvements, action items)
3. **Release** — Release manager creates PR, tags, GitHub Release
4. **Archive** — Completed items move from SPRINT.md to SPRINT_ARCHIVE.md

The archive step must wait for the release to complete — release notes are compiled from SPRINT.md.

## Cross-Item Parallelization

When multiple sprint items are active simultaneously:

| Rule | Limit | Why |
|------|-------|-----|
| Max 1 L/XL item active | L/XL items generate 7+ agent rounds | Context pressure |
| S/XS items can run alongside anything | Fast Track = 3 rounds, small output | Minimal footprint |
| Max 2 M items in parallel | Full pipeline but moderate output | Two is safe, three risks pressure |
| Interleave, don't overlap | Complete R1-R5 of item 1 before starting R1 of item 2 | Prevents context collision |

## Blocker Escalation

When something is blocked, the scrum master:

1. Documents the blocker in SPRINT.md (description, owner, target resolution)
2. If the responsible agent's round completes without resolution, presents 3 options:
   - **Resolve** — provide the missing information/resource
   - **Defer** — move the item to the next sprint
   - **Workaround** — propose an alternative approach

Blockers are never silently ignored. Every one is closed as: resolved, deferred, or worked around.
