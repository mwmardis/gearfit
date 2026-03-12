# Smart Dashboard: Volume Tracking & Workout Recommendations

## Problem

Intermediate lifters using GearFit already have templates and training history, but the app doesn't help them decide *what to train today* or whether their weekly volume is on track. The dashboard is passive — it shows what happened, not what should happen next.

## Solution

Server-computed intelligence on the dashboard: a volume analysis engine that tracks weekly sets per muscle group against evidence-based targets, and a recommendation engine that suggests which template to run today based on volume gaps, template staleness, and rotation patterns.

## Target User

Someone who already trains regularly, has templates and logged sessions, and wants the app to help optimize their programming — not a complete beginner.

## Approach

Server-side heuristics using existing data (no AI, no new infrastructure). Deterministic, fast, testable. Gemini coaching can be layered on later.

---

## Data Model Changes

### New column: `profiles.training_goal`

An enum with values: `hypertrophy`, `strength`, `endurance`. Defaults to `hypertrophy`. Editable in profile settings.

### Volume target presets (code constants)

A TypeScript config file (`src/lib/volume-targets.ts`) mapping goal to per-muscle-group set ranges:

| Goal | Most muscles | Large muscles (Back, Legs) |
|------|-------------|---------------------------|
| Hypertrophy | 10-20 sets/week | 12-22 sets/week |
| Strength | 6-12 sets/week | 8-15 sets/week |
| Endurance | 15-25 sets/week | 15-25 sets/week |

Based on published literature (Schoenfeld, Israetel). No new tables — just a config file.

No other schema changes. Volume is computed on-the-fly from existing `session_sets` + `exercise_muscles` data.

---

## Volume Analysis Engine

Location: `src/lib/volume-analysis.ts`

### How it works

1. Query the last 7 days of `session_sets` joined through `session -> template_exercises -> exercise_muscles`
2. Count working sets per muscle group: primary muscles = 1 set, secondary muscles = 0.5 sets
3. Compare against the user's goal-based presets
4. Return per-muscle status: `under` / `optimal` / `over`

### Output shape

```typescript
type MuscleVolumeStatus = {
  muscle: string
  currentSets: number
  targetMin: number
  targetMax: number
  status: 'under' | 'optimal' | 'over'
}
```

### Design decisions

- **Rolling 7-day window** (not calendar week) — avoids "Monday reset" problem, gives meaningful data any day
- **0.5 weighting for secondary muscles** — standard convention in volume literature
- **Single SQL query** with aggregation — no N+1 issues, no caching needed

---

## Workout Recommendation Engine

Location: `src/lib/workout-recommender.ts`

### Algorithm

1. Gather inputs: user's templates, volume status, last session date per template
2. Score each template on three factors:
   - **Staleness** — days since last used (staler = higher score)
   - **Volume gap coverage** — does it hit muscles in `under` status? (more coverage = higher score)
   - **Rotation fit** — respect implied split order based on recent history
3. Pick the top-scoring template
4. **Rest day detection** — if no muscle group is `under` and user trained 5+ consecutive days, suggest rest

### Output shape

```typescript
type WorkoutRecommendation = {
  type: 'workout' | 'rest'
  template?: { id: string; name: string; musclesTargeted: string[] }
  reason: string
}
```

The `reason` field makes recommendations transparent and trustworthy.

---

## Dashboard UI Changes

### Enhanced "Today's Workout" Card

- Replaces the current static card with the recommendation engine's output
- Shows: recommended template name, reason string, "Start Workout" button
- Rest day variant: encouraging message with reason
- Fallback: prompt to create a template (current behavior for users with no templates)

### Volume Report Card

- Replaces/extends the existing muscle coverage chart
- Per-muscle-group bar showing current sets vs target range
- Color-coded: red/amber (`under`), green (`optimal`), yellow/orange (`over`)
- Grouped by broad categories (Chest, Back, Shoulders, Arms, Legs, Core) with expandable detail
- Compact by default, expandable for full breakdown

### Profile Settings Addition

- New "Training Goal" dropdown: Hypertrophy / Strength / Endurance
- Added to the existing profile settings page

No new pages. The dashboard gets smarter, not bigger.

---

## Testing Strategy

### Unit tests (Vitest)

- Volume analysis: mock session data, verify set counting (primary vs secondary weighting), rolling window, status classification
- Recommendation scoring: various template/volume/history combinations, verify correct template selection and rest day detection
- Volume target presets: all goal types have complete muscle group coverage

### Integration tests

- Server actions returning volume data and recommendations with real Drizzle queries

### Manual/visual testing

- Dashboard renders correctly for: new user (no data), partial week, rest day suggestion, volume gaps

No Playwright E2E needed — read-only dashboard content with no complex interactions.
