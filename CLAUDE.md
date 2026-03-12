# GearFit

Workout tracking app that helps users create and execute personalized routines based on their available equipment.

## Tech Stack

- **Framework**: Next.js 16 (App Router, Server Components, Server Actions)
- **Language**: TypeScript, React 19
- **Database**: Neon PostgreSQL (serverless) via Drizzle ORM
- **Auth**: Auth.js v5 (NextAuth) with Credentials provider, JWT strategy
- **UI**: Tailwind CSS v4, shadcn/ui (Radix primitives), lucide-react icons, dark mode via next-themes
- **AI**: Google Gemini API (gemini-2.5-flash) for exercise recommendations
- **Charts**: Recharts
- **Testing**: Vitest (unit), Playwright (E2E)
- **Hosting**: Vercel

## Commands

- `npm run dev` — start dev server
- `npm run build` — production build
- `npm test` — run unit tests (vitest)
- `npm run test:watch` — vitest in watch mode
- `npm run test:e2e` — Playwright E2E tests
- `npx tsc --noEmit` — type check
- `npx drizzle-kit generate` — generate migration from schema changes
- `npx drizzle-kit push` — push schema to database

## Architecture

### Database Schema

Single schema file: `src/lib/db/schema.ts`. All tables defined with Drizzle `pgTable()`. Key tables: `profiles`, `exercises` (512+ from ExRx.net), `exercise_muscles` (primary/secondary), `equipment`, `equipment_profiles`, `workout_templates`, `template_exercises`, `workout_sessions`, `session_sets`, `muscles`, `saved_ai_suggestions`, plus Auth.js tables (`authjs_users`, `authjs_accounts`, `authjs_sessions`, `authjs_verification_tokens`).

DB connection: `src/lib/db/index.ts` — exports `db` (Drizzle instance over Neon HTTP).

### Auth

- Config: `src/lib/auth.ts` — NextAuth with DrizzleAdapter, Credentials provider
- Helpers: `src/lib/auth-utils.ts` — `requireAuth()` (throws if unauthenticated), `getOptionalAuth()` (returns null)
- Route handler: `src/app/api/auth/[...nextauth]/route.ts`
- Middleware: `middleware.ts` — protects all routes except `/login`, `/signup`, `/share/*`
- Session includes `profileId` via JWT callback

### Server Actions

All in `src/lib/actions/`. Every file starts with `"use server"`. Pattern: call `requireAuth()` or `getOptionalAuth()`, then Drizzle queries. Files: `auth.ts`, `profile.ts`, `sessions.ts`, `templates.ts`, `exercises.ts`, `history.ts`, `equipment.ts`, `sharing.ts`, `ai.ts`.

### Pages

Protected routes under `src/app/(app)/`:
- `/` — Dashboard (smart recommendations, volume tracking, recent sessions)
- `/workouts` — Template list, create/edit/clone/delete
- `/workouts/[id]` — Template detail
- `/workouts/[id]/start` — Active session (log sets, swap exercises, progressive overload hints)
- `/exercises` — Exercise library with two-level muscle filter and AI copilot
- `/exercises/[id]` — Exercise detail with progress chart
- `/history` — Calendar view with streak counter
- `/history/[id]` — Session detail
- `/equipment` — Equipment profiles (named setups, one active at a time)
- `/profile` — Settings (name, units, training goal, overload thresholds)

Public: `/login`, `/signup`, `/share/[token]`

### Key Features

- **Equipment-based filtering**: Exercises filtered by user's active equipment profile
- **Smart dashboard**: Volume tracking (7-day rolling, primary=1 set, secondary=0.5) against goal-based targets (hypertrophy/strength/endurance). Recommendation engine scores templates by staleness + volume gap coverage, with rest day detection.
- **Progressive overload**: Suggests weight increases after N consecutive sessions hitting target reps
- **AI exercise recommendations**: Gemini-powered suggestions by workout type
- **Template sharing**: Share via UUID token links

### Conventions

- Path alias: `@/` maps to `src/`
- Tests: `src/lib/utils/__tests__/*.test.ts` for utilities, `src/lib/actions/__tests__/*.test.ts` for validators, `src/components/**/__tests__/*.test.tsx` for components
- Server components fetch data, client components (`"use client"`) handle interactivity
- Form submission: `useTransition()` + server action via FormData
- Constants/config as TypeScript files (not DB tables) — e.g., `src/lib/volume-targets.ts`
- Validators: `src/lib/validators/`

## Design Docs

All in `docs/plans/`. Each feature has a design doc and implementation plan.
