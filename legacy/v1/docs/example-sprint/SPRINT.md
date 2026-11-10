# Current Sprint

## Sprint Goal
Improve dashboard usability and add search/filter functionality to the projects list page.

## Active Items

### [ITEM-101] Dashboard Redesign — Activity Feed + Quick Actions
- **Tier**: Full (L)
- **Status**: ✅ requirements → ✅ architecture → ✅ backend → ✅ frontend → ✅ code-review → ✅ security-review → ✅ qa-review → ✅ test-engineer → tester (UAT)
- **Assigned To**: [tester]
- **Blockers**: None
- **Feature Context**:
  - Dashboard is the most-visited page — needs activity feed showing recent actions and quick-action buttons for common workflows
  - PRD specifies: recent activity (last 30 days), quick-create buttons, usage stats
  - Architecture: new `/api/dashboard/activity` endpoint with org-scoped pagination
- **Handoff Notes**:
  - [test-engineer] wrote 12 tests: 4 e2e (dashboard load, activity feed scroll, quick action navigation, empty state), 6 integration (API pagination, org scoping, date filtering), 2 unit (activity feed component rendering)
  - All 12 tests passing. Full regression suite: 450 tests, 0 failures
  - Flagged: activity feed has no rate limiting on the API — deferred to next sprint per security reviewer
- **Files Changed**:
  - `src/app/api/dashboard/activity/route.ts` (new)
  - `src/app/(dashboard)/dashboard/page.tsx`
  - `src/components/dashboard/activity-feed.tsx` (new)
  - `src/components/dashboard/quick-actions.tsx` (new)
  - `src/components/dashboard/stat-card.tsx` (new)
  - `src/types/dashboard.ts` (new)
  - `tests/e2e/dashboard.spec.ts` (new)
  - `tests/integration/dashboard-api.test.ts` (new)
  - `tests/unit/activity-feed.test.ts` (new)
- **Definition of Done**:
  - [x] Code complete (no TODOs)
  - [x] [code-reviewer] — CRITICAL/HIGH fixed
  - [x] [security-reviewer] — CRITICAL/HIGH fixed
  - [x] [qa-reviewer] — CRITICAL/HIGH fixed
  - [ ] [seo-reviewer] (internal page — skipped)
  - [x] [test-engineer] tests passing (including full regression suite)
  - [ ] [tester] UAT PASS ← **awaiting**
  - [ ] [solution-architect] SOLUTION_DESIGN.md updated
  - [ ] BACKLOG.md status → `done`
  - [ ] BACKLOG_BOARD.md item → done

---

### [ITEM-102] Projects List — Search and Filter
- **Tier**: Full (M)
- **Status**: ✅ requirements → ✅ architecture → ✅ backend → frontend
- **Assigned To**: [frontend-engineer]
- **Blockers**: None
- **Feature Context**:
  - Users with 10+ projects can't find what they need — need search by name and filter by status/date
  - Architecture: server-side filtering via query params on existing `/api/projects` endpoint
  - No new tables — extends existing query with WHERE clauses
- **Handoff Notes**:
  - [backend-engineer] added `search`, `status`, and `dateRange` query params to GET /api/projects
  - Existing pagination preserved, filters compose with each other
  - Search uses case-insensitive ILIKE on project name and description
  - New Zod schema: `projectFilterSchema` in `src/lib/validations/project.ts`
  - Files: `src/app/api/projects/route.ts` (modified), `src/lib/validations/project.ts` (modified)
- **Files Changed**:
  - `src/app/api/projects/route.ts` (modified — added filter params)
  - `src/lib/validations/project.ts` (modified — added filter schema)
- **Parallel Opportunity**: None — [frontend-engineer] needs API contract from R3
- **Definition of Done**:
  - [ ] Code complete (no TODOs)
  - [ ] [code-reviewer] — CRITICAL/HIGH fixed
  - [ ] [security-reviewer] — CRITICAL/HIGH fixed
  - [ ] [qa-reviewer] — CRITICAL/HIGH fixed
  - [ ] [seo-reviewer] (internal page — skipped)
  - [ ] [test-engineer] tests passing
  - [ ] [tester] UAT PASS
  - [ ] [solution-architect] SOLUTION_DESIGN.md updated
  - [ ] BACKLOG.md status → `done`
  - [ ] BACKLOG_BOARD.md item → done

---

### [ITEM-103] Fix Date Picker Timezone Bug
- **Tier**: Fast Track (S)
- **Status**: ✅ requirements → ✅ frontend → code-review + security-review
- **Assigned To**: [code-reviewer] + [security-reviewer] (parallel)
- **Blockers**: None
- **Feature Context**:
  - Bug: date picker shows wrong date for users in UTC- timezones
  - Root cause: `new Date()` without timezone normalization in `DatePicker` component
  - Fix: use `startOfDay()` from date-fns with explicit timezone
- **Handoff Notes**:
  - [frontend-engineer] fixed `src/components/ui/date-picker.tsx` — replaced raw `new Date()` with `startOfDay(date, { in: userTimezone })`
  - Also fixed same pattern in `src/components/filters/date-range-filter.tsx`
  - Existing tests updated to cover UTC-5 and UTC+2 scenarios
- **Files Changed**:
  - `src/components/ui/date-picker.tsx` (modified)
  - `src/components/filters/date-range-filter.tsx` (modified)
  - `tests/unit/date-picker.test.ts` (modified — added timezone cases)
- **Definition of Done**:
  - [x] Code complete (no TODOs)
  - [ ] [code-reviewer] — awaiting
  - [ ] [security-reviewer] — awaiting
  - [x] Existing test suite passes with zero regressions

---

## Completed This Sprint

### [ITEM-100] Stat Card Component
- **Status**: ✅ done | **Tier**: Fast Track (S) | Completed 2026-03-20
- **Files Changed**: `src/components/dashboard/stat-card.tsx` (new), `tests/unit/stat-card.test.ts` (new)
- **Notes**: Foundation component used by ITEM-101. Code + security review passed. 3 tests, all passing.

## Blockers & Decisions Needed

_None currently — all items progressing._
