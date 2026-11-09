# Model Routing: Opus vs Sonnet

Running 17 agents on the most expensive model wastes tokens without improving quality. This document explains the reasoning behind the Opus/Sonnet split.

## The Principle

**Use Opus where errors cascade or are irreversible. Use Sonnet where output follows patterns and is reviewed by Opus agents.**

## Opus Agents (7)

| Agent | Why Opus |
|-------|----------|
| `[scrum-master]` | Orchestration errors cascade to all 15+ agents. Enforces 8 gates, 3 tiers, parallelization decisions. A wrong routing decision wastes an entire round. |
| `[solution-architect]` | Foundational decisions (DB schema, API contracts) are expensive to reverse. Bookends the pipeline at R2 + R7. |
| `[security-reviewer]` | Auth/data isolation/compliance review quality is non-negotiable. Asymmetric risk: a missed vulnerability costs far more than saved tokens. |
| `[backend-engineer]` | Security-sensitive code (auth guards, data isolation, multi-tenant queries). Highest correctness bar. |
| `[ai-ml-engineer]` | Most complex code (LLM orchestration, RAG pipelines, validation chains). Architectural novelty where patterns don't exist yet. |
| `[frontend-engineer]` | Largest code output. Complex state management, role-aware UI, responsive design. |
| `[test-engineer]` | Test quality determines what bugs ship. Multi-tenant isolation tests, edge cases, data factories. |

## Sonnet Agents (10)

| Agent | Why Sonnet Is Sufficient |
|-------|------------------------|
| `[code-reviewer]` | Checklist-driven pattern recognition. Opus `[security-reviewer]` provides overlapping coverage on critical patterns. |
| `[qa-reviewer]` | Checklist-driven (type safety, error handling, accessibility). Three other R5 reviewers overlap. |
| `[product-manager]` | Structured output (user stories, acceptance criteria, backlog tables). `[solution-architect]` validates in R2. |
| `[data-analyst]` | Highly structured output (event schemas, KPI tables). PM reviews before handoff. |
| `[marketing-manager]` | Structured strategic output with pre-defined frameworks. User reviews all plans. |
| `[seo-reviewer]` | Most checklist-driven agent. SEO findings are typically LOW-MEDIUM severity. |
| `[tester]` | Follows test scripts with structured PASS/FAIL output. User is the ultimate UX judge. |
| `[content-creator]` | Marketing copy follows brand voice guidelines. `[marketing-manager]` reviews all content. |
| `[technical-writer]` | Structured documentation following templates. User reviews all output. |
| `[release-manager]` | Checklist-driven release process. User approves every destructive action (merge, tag, push). |

## The Opus Trident Safety Net

Every piece of Sonnet-generated code or documentation passes through at least one Opus agent before it ships:

1. **`[scrum-master]`** — Process quality (every gate, every handoff)
2. **`[solution-architect]`** — Architecture quality (R2 design + R7 close verification)
3. **`[security-reviewer]`** — Security quality (R5 validation of all code)

This means Sonnet agents are never the last line of defense. Their output is always reviewed by an Opus agent that catches structural, architectural, or security issues.

## Cost Impact

Rough estimates based on real usage:

- **All Opus**: ~$X per sprint (baseline)
- **Opus/Sonnet split**: ~60% of baseline (40% savings)
- **Projected Haiku addition**: ~45% of baseline (55% savings)

The savings come primarily from the 4 R5 reviewers (launched in parallel, high token consumption) and R1 agents (structured output that doesn't need Opus reasoning).

## Future: Haiku Evaluation

After observing Sonnet quality across 2-3 sprints, consider downgrading these agents to Haiku:

1. `[seo-reviewer]` — most checklist-driven, lowest severity findings
2. `[data-analyst]` — highly structured, PM reviews all output
3. `[content-creator]` — start with internal content only
4. `[technical-writer]` — template-driven, user reviews everything
5. `[release-manager]` — checklist-driven, user approves every step

**Do NOT evaluate Haiku for:** scrum-master, solution-architect, security-reviewer, backend-engineer, ai-ml-engineer, frontend-engineer, test-engineer, code-reviewer, qa-reviewer.

## How to Override

In `CLAUDE.md`, the model assignments are specified in the "Agent Model Assignments" section. To change an agent's model, update the table. The scrum master reads this table when generating agent invocation prompts and includes the `model` parameter in every Agent tool call.
