# Sprint 5 — R5 Findings (Deduplicated)

_Generated after R5 review round for ITEM-101 (Dashboard Redesign). Four reviewers ran in parallel: [code-reviewer], [security-reviewer], [qa-reviewer], [seo-reviewer]._

## CRITICAL (must fix before R6)

_None_

## HIGH (must fix before R6)

| # | Reviewer | File | Finding | Proposed Fix | Status |
|---|----------|------|---------|-------------|--------|
| 1 | [security-reviewer] | `src/app/api/dashboard/activity/route.ts:28` | Activity endpoint missing org-scope check — returns all activities across all organizations | Add `requireAuthWithOrg()` guard and filter by `orgId` in query | FIXED — added org guard at line 12, WHERE clause at line 31 |
| 2 | [code-reviewer] | `src/app/api/dashboard/activity/route.ts:35` | N+1 query: fetching user names in a loop for each activity entry | Use a single JOIN query instead of loop + individual lookups | FIXED — replaced loop with `.select("*, users(name, avatar)")` join |
| 3 | [qa-reviewer] | `src/components/dashboard/activity-feed.tsx:52` | Missing loading state — component shows blank div while data loads | Add skeleton loader matching the activity feed layout | FIXED — added `ActivityFeedSkeleton` component with 5 shimmer rows |
| 4 | [code-reviewer] | `src/app/api/dashboard/activity/route.ts:40` | Unbounded query — no `.limit()` on activity fetch, will degrade as data grows | Add server-side pagination with `page` and `limit` params (default 20, max 100) | FIXED — added pagination with cursor-based approach |
| 5 | [qa-reviewer] | `src/components/dashboard/quick-actions.tsx:18` | Quick action buttons not keyboard-accessible — no `onKeyDown` handler | Add keyboard event handlers for Enter and Space | FIXED — wrapped actions in `<button>` elements instead of `<div onClick>` |

## MEDIUM (fix if time permits)

| # | Reviewer | File | Finding | Proposed Fix | Status |
|---|----------|------|---------|-------------|--------|
| 6 | [code-reviewer] | `src/components/dashboard/stat-card.tsx:12` | Magic numbers for trend calculation thresholds (5, 10, 20) | Extract to named constants: `TREND_THRESHOLD_LOW`, `TREND_THRESHOLD_MED`, `TREND_THRESHOLD_HIGH` | DEFERRED — cosmetic, no functional impact |
| 7 | [qa-reviewer] | `src/components/dashboard/activity-feed.tsx:85` | Empty state shows generic "No data" instead of contextual message | Show "No recent activity. Create your first project to get started." with CTA button | FIXED — added contextual empty state with "Create Project" CTA |
| 8 | [security-reviewer] | `src/app/api/dashboard/activity/route.ts:15` | No rate limiting on activity endpoint | Add rate limiter (30 req/min per user) | DEFERRED — tracked as separate backlog item for next sprint |

## LOW (defer to future sprint)

| # | Reviewer | File | Finding | Proposed Fix | Status |
|---|----------|------|---------|-------------|--------|
| 9 | [seo-reviewer] | `src/app/(dashboard)/dashboard/page.tsx:1` | Missing `<title>` and meta description for dashboard page | Add metadata export: `title: "Dashboard"`, `description: "Your project overview"` | DEFERRED — internal page, low SEO impact |
| 10 | [code-reviewer] | `src/types/dashboard.ts:8` | `ActivityType` enum could use `as const` assertion for better type narrowing | Change `enum` to `const` object with `typeof` derived type | DEFERRED — cosmetic, enum works fine |

---

## Summary

- **Total findings**: 10 (0 CRITICAL, 5 HIGH, 3 MEDIUM, 2 LOW)
- **Fixed before R6**: 6 (all 5 HIGH + 1 MEDIUM)
- **Deferred**: 4 (2 MEDIUM + 2 LOW)
- **Blocking status**: All CRITICAL and HIGH findings resolved — R6 can proceed
