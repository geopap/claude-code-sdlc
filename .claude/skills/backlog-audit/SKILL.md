---
name: backlog-audit
description: Use BEFORE filing any new backlog item (B-number) or proposing new infrastructure (connectors, integrations, CSV import, GA4, Klaviyo, etc.). Audits BACKLOG.md and BACKLOG_BOARD.md for existing IDs, and searches the codebase for already-shipped infrastructure to prevent duplicate tickets and rebuild-of-existing-features.
---

# Backlog Audit (Pre-Filing)

Run this BEFORE filing any new backlog item or proposing a "missing" piece of infrastructure. Acting before checking has caused repeated rework — collisions with already-taken B-numbers, missed existing connectors, hotfixes for problems already solved.

## When to fire

- User says "file a ticket / B-XXX / new backlog item / add to backlog"
- User says "we need to build X" where X is a connector, integration, importer, or analytics hookup
- Any agent (especially [product-manager]) is about to write a new line into BACKLOG.md

## Audit steps

1. **B-number collision check**
   - `grep -E '^B-[0-9]+' BACKLOG.md` — list all taken IDs
   - `grep -E '^B-[0-9]+' BACKLOG_BOARD.md` — confirm board agrees
   - Confirm the proposed ID is NOT in either file before filing

2. **Duplicate-feature check**
   - `grep -in '<feature-keyword>' BACKLOG.md` — search current backlog
   - `grep -rn '<feature-keyword>' SPRINT_ARCHIVE.md` — search closed work
   - If a similar item exists, link to it instead of filing a new one

3. **Existing-infrastructure check (codebase)**
   - For connectors/integrations: search the codebase for the service name, SDK import, env-var prefix, or scheduler registration
     - Example: before filing "add Klaviyo connector", run `grep -rln -i 'klaviyo' .` and check for SDK imports, route registrations, scheduler entries
   - For data flows: check `[YOUR_BACKEND_DIR]/`, `[YOUR_MIGRATIONS_DIR]/`, scheduler/router/config files
   - If the infrastructure exists under a different name, surface it — do NOT file a build ticket

4. **Estimate sanity check**
   - Use Claude-cadence timing (hours/sessions, not human weeks) for any effort estimate

## Output format

Report findings as:

```
B-number proposed: B-XXX
- Collision: [none | TAKEN by B-XXX "<title>"]
- Similar existing items: [list with B-numbers, or "none"]
- Existing infrastructure found: [list of files/symbols, or "none"]
- Recommendation: [FILE / EXTEND existing B-XXX / SKIP — already shipped]
```

Wait for user approval before filing. Never silently add a line to BACKLOG.md.
