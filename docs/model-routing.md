# Model routing

The principle carries over from v1: **use the strongest model where errors cascade or are irreversible; use a cheaper one where output is checklist-shaped and independently checked.** In v2 the model is set in each agent's frontmatter (`model:` and `effort:`), so there's no table for an orchestrator to read and pass along.

| Agent | Model | Effort | Why |
|---|---|---|---|
| planner | opus | high | Schema, API and slicing decisions are the most expensive to reverse |
| implementer | opus | high | Security-sensitive, multi-layer code |
| test-engineer | opus | default | Test quality decides what ships; isolation and role edge cases are subtle |
| security-reviewer | opus | high | A missed vulnerability costs far more than the tokens |
| code-reviewer | sonnet | high | Pattern-shaped review; findings are verified by the orchestrator afterwards |
| verifier | sonnet | default | Follows AC step by step and records evidence |

Aliases (`opus`, `sonnet`, `haiku`) track the latest model in each family, so the plugin doesn't need edits when models update.

## Spend by risk, not just by role

- `risk:low` PRs run only the Sonnet code-reviewer.
- `risk:standard` and `risk:high` add the Opus security reviewer.
- If you need to cut cost further, the first candidate is `verifier` → `haiku` for API-only verification. Don't downgrade the security reviewer or the implementer.

## Overriding

Copy an agent file into your project's `.claude/agents/` and change the frontmatter. A project agent takes precedence over a plugin agent with the same name.
