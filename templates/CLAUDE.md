# [PROJECT_NAME]

[One line: what this product is and who uses it.]

## Stack
- [Framework, language, database, auth library, hosting]
- Package manager: [npm | pnpm | bun | uv]

## Commands
- Check everything: `[npm run typecheck && npm run lint && npm test]`
- Dev server: `[npm run dev]` → [http://localhost:3000]
- E2E: `[npx playwright test]`
- Migrations (local only): `[supabase db reset | alembic upgrade head]`

## Layout
- `[src/app/api/]`: API routes. Copy the pattern in `[src/app/api/projects/route.ts]`.
- `[src/components/]`: UI. Copy `[src/components/projects/ProjectList.tsx]` for list views (skeleton, empty, error states).
- `[supabase/migrations/]`: migrations, expand/contract only.
- `[tests/]`: unit and integration tests. `[e2e/]`: Playwright with Page Objects.

## Rules that aren't obvious from the code
- Every query is scoped by `org_id` from the server session. Never trust a client-supplied org ID.
- [Auth: use `getUser()` from `@/lib/auth/server`, never decode tokens yourself.]
- [AI calls go through `@/lib/ai/client`, which sets the no-training headers.]
- [Anything else a new engineer gets wrong in week one.]

## How we ship
One issue → one or more small PRs. Use `/sdlc:ship <issue>`, or the individual steps `/sdlc:plan`, `/sdlc:build`, `/sdlc:review` and `/sdlc:verify`. CI and CODEOWNERS are the gates. Humans approve, merge and apply migrations.
