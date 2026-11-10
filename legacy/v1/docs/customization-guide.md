# Customization Guide

This framework separates universal process rules from project-specific configuration. This guide explains what to change and what to keep.

## What NOT to Change

These elements are the core value of the framework. Modifying them defeats the purpose:

- **8-round pipeline** — the round structure and dependencies are battle-tested
- **8 quality gates** — every gate exists because something shipped broken without it
- **Agent roles** — each agent has a specific scope that prevents overlap and ensures accountability
- **Context discipline** — summarize-don't-quote, SPRINT.md as context contract
- **Pipeline tiers** — Fast Track/Full/Spike-First sizing is essential for practical use
- **Mandatory invocation template** — agents start fresh; the template is their context
- **Definition of Ready / Done** — these checklists prevent incomplete work from progressing

## What to Customize

### 1. Project Identity

In `CLAUDE.md` and all `agents/*.md` files, replace:

```
[YOUR_PROJECT_NAME]     → e.g., "Acme Dashboard"
[YOUR_PROJECT_DESCRIPTION] → e.g., "A real-time analytics dashboard for e-commerce"
[YOUR_TECH_STACK]       → e.g., "Next.js 15, TypeScript, PostgreSQL, Prisma, Tailwind CSS"
```

### 2. File Paths

The agent roster in `CLAUDE.md` maps agents to directories. Replace with your project structure:

```
[YOUR_BACKEND_DIR]      → e.g., "src/server/", "app/api/", "backend/src/"
[YOUR_FRONTEND_DIR]     → e.g., "src/app/", "src/components/", "frontend/src/"
[YOUR_MIGRATIONS_DIR]   → e.g., "prisma/migrations/", "drizzle/migrations/", "db/migrate/"
[YOUR_TESTS_DIR]        → e.g., "src/__tests__/", "tests/", "spec/"
[YOUR_TYPES_DIR]        → e.g., "src/types/", "types/", "src/interfaces/"
```

### 3. Build & Test Commands

In the command files (`commands/*.md`) and `CLAUDE.md`:

```
[YOUR_TEST_COMMAND]     → e.g., "npm test", "pytest", "go test ./..."
[YOUR_TYPECHECK_COMMAND] → e.g., "npx tsc --noEmit", "mypy .", "go vet ./..."
[YOUR_LINT_COMMAND]     → e.g., "npx eslint .", "ruff check .", "golangci-lint run"
[YOUR_BUILD_COMMAND]    → e.g., "npm run build", "cargo build", "go build ./..."
```

### 4. Security & Compliance

In the "Non-Negotiable Rules" section of `CLAUDE.md`:

```
[YOUR_COMPLIANCE_REQUIREMENTS] → e.g., "GDPR", "CCPA", "HIPAA", "SOC 2"
[YOUR_AUTH_PATTERN]     → e.g., "NextAuth.js session checks", "JWT verification middleware"
[YOUR_DATA_ISOLATION]   → e.g., "Row-level security", "tenant_id scoping", "org-based access"
```

### 5. Localization

```
[YOUR_SUPPORTED_LANGUAGES] → e.g., "EN only", "EN/ES/PT", "EN/DE/FR/JA"
[YOUR_DATE_FORMAT]      → e.g., "MM/DD/YYYY", "DD.MM.YYYY", "YYYY-MM-DD"
```

### 6. Performance Thresholds

In the "Performance Standards" section, adjust to your requirements:

```
API response time: < 500ms P95    → adjust based on your SLOs
Page LCP: < 2.5s on mobile        → adjust for your app type
DB queries: < 200ms               → adjust for your database
```

## Removing Agents You Don't Need

Not every project needs all 17 agents. Here's a guide for common scenarios:

### Backend-only project (no UI)
Remove: `[frontend-engineer]`, `[seo-reviewer]`
Adjust: R4 is skipped; R5 runs without SEO reviewer

### No AI component
Remove: `[ai-ml-engineer]`
Adjust: R3 runs only `[backend-engineer]`

### Solo developer / small team
Remove: `[marketing-manager]`, `[content-creator]`, `[data-analyst]`
Adjust: R1 runs only `[product-manager]`; R8 runs only `[technical-writer]`

### Internal tool (no marketing)
Remove: `[marketing-manager]`, `[content-creator]`, `[seo-reviewer]`
Adjust: R1 and R8 simplified; R5 runs 3 reviewers

### Minimum viable setup (10 agents)
Keep: `[scrum-master]`, `[product-manager]`, `[solution-architect]`, `[backend-engineer]`, `[frontend-engineer]`, `[code-reviewer]`, `[security-reviewer]`, `[qa-reviewer]`, `[test-engineer]`, `[tester]`
This covers: requirements → architecture → build → review → test → done

## Adding Custom Agents

To add a new agent:

1. Create `agents/your-agent.md` following the existing format:
   - Purpose section
   - "When to Use" section
   - Full system prompt with responsibilities
   - Model assignment (Opus or Sonnet)
   - Invocation instructions

2. Add the agent to the roster table in `CLAUDE.md`

3. Specify which pipeline round the agent participates in

4. Update the scrum master's agent prompt to include the new agent

### Example: DevOps Engineer

```markdown
# DevOps Engineer Agent

**Purpose:** Manage CI/CD pipelines, infrastructure configuration, and deployment automation.

## When to Use
- When a sprint item involves CI/CD changes
- When infrastructure configuration is needed
- When deployment processes need updating

## Agent Prompt
You are a DevOps engineer for [YOUR_PROJECT_NAME]...
```

This agent would typically run in R3 (parallel with backend) or as a new R3.5 round.

## Database-Specific Patterns

The framework's multi-tenant security rules need to match your ORM/database:

### Prisma
```
- Every model with user data has `orgId` field
- Use Prisma middleware for org-scoping
- All queries use `where: { orgId: user.orgId }`
```

### Drizzle
```
- Every table with user data has `org_id` column
- Use Drizzle's `.where(eq(table.orgId, user.orgId))`
- Custom middleware for org-scope enforcement
```

### Django
```
- Every model with user data has `organization` ForeignKey
- Use custom QuerySet managers for org-scoping
- Django middleware enforces tenant context
```

### Raw SQL
```
- Every table with user data has `org_id` column
- Row-Level Security (RLS) policies on all tenant tables
- Application-level org checks as defense-in-depth
```

## Settings Configuration

Copy `.claude/settings.json.example` to your project's `.claude/settings.json` and customize:

1. **Allow list** — Pre-approve your commonly used commands (test, build, git)
2. **PreToolUse hook** — The TypeScript pre-commit check is an example; adapt for your language:
   - Python: `mypy . 2>&1` or `ruff check . 2>&1`
   - Go: `go vet ./... 2>&1`
   - Rust: `cargo check 2>&1`
3. **Additional directories** — Add directories Claude Code needs to access
