---
name: retro
description: Data-driven retrospective from merged PRs over a period — lead time, PR size, review rounds, AI-review findings, reverts and escaped bugs — with up to 3 concrete process changes. Use weekly, or when the user asks how delivery is going.
argument-hint: "[days, default 7]"
allowed-tools: Bash(gh pr list *) Bash(gh pr view *) Bash(gh issue list *) Bash(git log *)
---

# /sdlc:retro

Period: the last `$ARGUMENTS` days (default 7). This replaces v1's per-sprint retro (Gate 7) and velocity counts with delivery metrics.

## Collect
- Merged PRs: `gh pr list --state merged --search "merged:>=<date>" --limit 200 --json number,title,labels,additions,deletions,createdAt,mergedAt,reviews,comments`
- Reverts and hotfixes: PRs whose titles start with `revert` or `fix`, merged in the period, that reference a PR from the same period.
- Bugs reported in the period: `gh issue list --label bug --search "created:>=<date>" --state all`
- AI review outcomes: `claude-review` comments on those PRs (confirmed versus dismissed findings).

## Report
```markdown
## Delivery retro — <start> → <end>
| Metric | Value | Prev period |
|---|---|---|
| PRs merged | | |
| Median lead time (open → merge) | | |
| Median PR size (lines changed) | | |
| PRs > 400 lines | | |
| Median review rounds | | |
| Change failure rate (reverts or hotfixes ÷ merged) | | |
| Escaped bugs (bugs linked to PRs merged this period) | | |
| AI findings: confirmed / dismissed | | |

### What the data says
- <up to 3 observations, each pointing to specific PRs>

### Changes to try (max 3)
- [ ] <concrete change to a skill, agent prompt, hook, CI check or risk glob, with the file to edit>
```

If the previous period isn't available, leave that column blank. Offer to open an issue with the "Changes to try" list. Don't edit framework files without asking.
