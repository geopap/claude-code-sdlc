# Sprint Retrospective — Sprint 5

## Velocity

- **Planned**: 4 items / 1L + 1M + 1S + 1S = estimated ~20 story points
- **Completed**: 4 items / 4 completed / 0 carried over
- **Delivery rate**: 100%

## Pipeline Execution Summary

| Item | Tier | Rounds Run | R5 Findings | R6 Tests | UAT |
|------|------|-----------|-------------|----------|-----|
| ITEM-100 Stat Card | Fast Track (S) | R1→R4→R5(code+security)→Done | 0 HIGH | 3 unit | N/A |
| ITEM-101 Dashboard Redesign | Full (L) | R1→R2→R3→R4→R5(all 4)→R6→R7 | 5 HIGH, 3 MED, 2 LOW | 12 (4 e2e + 6 int + 2 unit) | PASS |
| ITEM-102 Search & Filter | Full (M) | R1→R2→R3→R4→R5(all 4)→R6→R7 | 2 HIGH, 1 MED | 8 (2 e2e + 4 int + 2 unit) | PASS |
| ITEM-103 Date Picker Fix | Fast Track (S) | R1→R4→R5(code+security)→Done | 0 HIGH | 3 unit (updated) | N/A |

**Total new tests**: 26
**Full regression suite**: 476 tests, 0 failures

## What Went Well

- **Fast Track tier worked perfectly** — ITEM-100 and ITEM-103 were done in 3 rounds each, freeing pipeline capacity for the L and M items
- **R5 caught a critical org-scope missing check** (ITEM-101, finding #1) — this would have been a data leak in production. The security reviewer justified its Opus model assignment.
- **Parallel R5 reviews** saved significant time — 4 reviewers running simultaneously on ITEM-101 completed in the time it would take 1 reviewer, and the deduplicated findings had zero overlap

## What to Improve

- **Rate limiting deferred twice now** — ITEM-101 activity endpoint and a prior sprint both deferred rate limiting. Need to prioritize this as a standalone item.
- **N+1 query pattern recurring** — this is the third sprint where [code-reviewer] caught an N+1 query. Engineers should proactively use joins instead of loops.
- **Empty state inconsistency** — finding #7 showed generic "No data" text. Need a standard empty state component that all pages use consistently.

## Action Items for Next Sprint

- [ ] Add rate limiting backlog item (P1, effort S) — assign to [backend-engineer]
- [ ] Create shared empty state component with contextual messaging — standardize across all list pages
- [ ] Add N+1 query check to [backend-engineer] agent prompt as a pre-commit mental checklist item
