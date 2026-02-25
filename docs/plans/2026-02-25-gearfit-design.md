# GearFit Design Document

**Date:** 2026-02-25
**Status:** Approved

## Overview

GearFit is a workout tracking web app that filters exercises based on your available equipment. It supports custom workout splits, progress tracking, and sharing workouts with friends.

## Target Users

Small group (personal + friends). Basic accounts required.

## Tech Stack

- **Frontend/Backend:** Next.js (App Router, Server Actions, React Server Components)
- **Database:** Supabase Postgres with Row Level Security
- **Auth:** Supabase Auth (email/password + magic links)
- **Styling:** Tailwind CSS + shadcn/ui
- **Deployment:** Vercel (hosting) + Supabase Cloud (database/auth)

## Architecture

Monolithic Next.js application. All business logic lives in Server Actions and server-side utilities. Supabase handles auth and data persistence. No separate API server.

## Data Model

### Tables

**profiles** — Extends Supabase auth.users with display name, avatar, preferred units (lbs/kg), progressive overload settings.

**equipment** — Master list of equipment types (barbell, dumbbells, cable machine, pull-up bar, resistance bands, bench, squat rack, etc.).

**equipment_profiles** — Named equipment setups per user (e.g., "Home Gym", "Planet Fitness"). One marked active at a time.

**equipment_profile_items** — Junction table: equipment_profile_id -> equipment_id.

**muscles** — Enumeration of muscle groups: chest, triceps, biceps, front delts, side delts, rear delts, lats, upper back, lower back, quads, hamstrings, glutes, calves, abs, forearms.

**exercises** — Pre-built and user-created exercises.
- name, description, instructions
- is_custom (boolean), created_by (user ID, null for pre-built)

**exercise_equipment** — Junction table: exercise_id -> equipment_id (required equipment).

**exercise_muscles** — Junction table: exercise_id -> muscle_id + role (primary/secondary).

**workout_templates** — Saved workout splits/routines.
- name, description, owner user ID
- is_shared (boolean), share_token (UUID for sharing)

**template_exercises** — Ordered exercises within a template.
- template_id, exercise_id, order_index
- target_sets, target_reps, target_weight (optional)

**workout_sessions** — Completed workout instances.
- user_id, date, duration_minutes
- template_id (optional reference to the template used)
- notes (optional)

**session_sets** — Individual logged sets.
- session_id, exercise_id, set_number
- weight, reps, rpe (optional)

### Key Relationships

- Equipment profile -> equipment (many-to-many via equipment_profile_items)
- Exercise -> equipment (many-to-many via exercise_equipment)
- Exercise -> muscles (many-to-many via exercise_muscles, with primary/secondary role)
- Workout template -> exercises (ordered, via template_exercises)
- Workout session -> sets (via session_sets)

## Features

### Equipment Filtering (Core)

Users create named equipment profiles representing their available gear at different locations. One profile is active at a time. The exercise library filters to show only exercises whose required equipment is a subset of the active profile's equipment.

### Exercise Library

Ships with a curated database of common exercises tagged by equipment and muscle group. Users can add custom exercises. Each exercise includes name, description, instructions, required equipment, and primary/secondary muscles.

### Workout Templates & Splits

Users create, edit, clone, and delete workout templates (e.g., "Chest & Triceps", "Pull Day"). Templates contain an ordered list of exercises with target sets, reps, and optional target weight.

### Exercise Swap Suggestions

When an exercise requires unavailable equipment, the app suggests alternatives by:
1. Finding exercises targeting the same primary muscle group(s)
2. Filtering to only those requiring equipment in the active profile
3. Ranking by secondary muscle overlap with the original exercise

### Progress Tracking (Weight & Reps)

During an active workout session, users log sets (weight + reps) for each exercise. Previous session data is displayed for reference. All data persists in session_sets.

### Progressive Overload Hints

After logging, the app checks recent history per exercise. If target reps were hit across all sets for 3 consecutive sessions, it suggests a weight increase (default: +5 lbs / +2.5 kg, configurable in user profile).

### Muscle Group Coverage View

Weekly summary showing which muscle groups have been trained and their relative volume (total sets). Highlights undertrained groups based on a balanced default.

### Workout History Calendar

Month-view calendar with indicators on training days. Click a day to expand the session summary. Includes a streak counter for consecutive training weeks.

### Sharing Workouts

Templates can be shared via link (using share_token UUID). Recipients can import the template into their own library as an independent copy they can modify.

## Pages

| Route | Purpose |
|-------|---------|
| `/` | Dashboard: today's workout, recent sessions, muscle coverage, quick actions |
| `/workouts` | Workout templates list |
| `/workouts/[id]` | Template view/edit |
| `/workouts/[id]/start` | Active workout session |
| `/history` | Calendar view of past sessions |
| `/history/[id]` | Single session detail |
| `/exercises` | Exercise library with filters |
| `/exercises/[id]` | Exercise detail + history chart + personal bests |
| `/equipment` | Equipment profiles management |
| `/profile` | User settings (name, units, overload thresholds) |
| `/login`, `/signup` | Auth pages |

## UI Approach

- Mobile-first responsive design (primary use at the gym)
- Tailwind CSS for styling
- shadcn/ui component library (Radix primitives + Tailwind)
- Dark mode support
- Optimistic UI updates for set logging

### Active Workout Flow

1. Pick a template or start blank
2. See exercise list with target sets/reps
3. Log each set (weight + reps), with last session's numbers for reference
4. Progressive overload hints shown when applicable
5. Swap exercises if equipment is unavailable
6. Finish workout: session saved, calendar updated

## Auth & Security

- Supabase Auth with email/password and magic link options
- JWT-based sessions integrated with Next.js middleware for protected routes
- Row Level Security on all tables:
  - Users read/write only their own data
  - Pre-built exercises readable by all
  - Custom exercises readable only by creator
  - Shared templates accessible via share token (read-only until imported)

## Error Handling

- Server Actions return typed result objects (`{ data } | { error }`)
- Client-side toast notifications for success/failure
- Optimistic UI for set logging (instant feel, server reconciliation)

## Deployment

- Vercel free tier for Next.js hosting
- Supabase Cloud free tier (500MB database, 50K MAU)
- Environment variables: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
