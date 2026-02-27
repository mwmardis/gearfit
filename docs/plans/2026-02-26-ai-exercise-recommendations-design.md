# AI-Powered Exercise Recommendations — Design

**Date**: 2026-02-26
**Status**: Approved

## Overview

Add Gemini-powered exercise recommendations to GearFit. Users can input custom equipment, select a workout type (predefined or free-text), and receive AI-generated exercise suggestions based on their available gear. Suggestions can be added directly to workout templates or saved for later.

## Approach: AI Copilot Panel

A slide-out drawer that appears alongside the template builder and exercise browser. Integrated into existing workflows with zero context switching.

## 1. Custom Equipment Input

**Enhancement to existing equipment profile form.** Add a free-text input at the top of the equipment selection form.

- User types equipment name not in catalog → "Add [name]" button appears
- On click: new row in `equipment` table with `is_custom = true`, `created_by = user_id`
- Item auto-selected into current profile
- Category assigned via dropdown selection

**Database change**: Add `is_custom BOOLEAN DEFAULT false` and `created_by UUID REFERENCES profiles(id)` columns to `equipment` table. Custom equipment visible only to the creating user.

## 2. AI Copilot Panel — UI & Interaction

**Component**: Shadcn `Sheet` (slide-out drawer from right).

**Triggers**:
- Template builder: "AI Suggest" button in template exercise list area
- Exercises page: "AI Suggest" button in exercise browser toolbar

**Panel contents** (top to bottom):
1. **Tabs**: "Generate" | "Saved"
2. **Workout type selector** — Quick-pick chips (Push, Pull, Legs, Upper, Lower, Full Body, Arms, Core) + free-text input for custom descriptions
3. **Equipment context** — Active equipment profile name (read-only, link to change)
4. **"Generate" button** — Fires Gemini request, shows loading skeleton
5. **Results list** — Each suggestion shows:
   - Exercise name (bold if exists in DB, italicized + "New" badge if AI-suggested)
   - Target muscles (primary/secondary tags)
   - Recommended sets/reps/weight range
   - "Add" button + bookmark/save icon
6. **"Regenerate" button**

**Behavior**:
- Template builder context: "Add" inserts exercise into template being edited
- Standalone context: "Add" creates a new template draft with selected exercises
- New exercises: clicking "Add" first creates custom exercise (with muscle mappings), then adds to template

## 3. Gemini API Integration

**API Route**: `POST /api/ai/recommend-exercises`

**Request payload**:
```json
{
  "workoutType": "string",
  "equipment": ["string"],
  "existingExercises": ["string"]
}
```

**Server-side flow**:
1. Validate auth
2. Build structured prompt with workout type, equipment list, exercises to exclude
3. Call Gemini API (`gemini-2.0-flash`)
4. Parse structured JSON response
5. Fuzzy-match suggestions against existing DB exercises
6. Return results with `existsInDb` flag

**SDK**: `@google/generative-ai` (official Google AI SDK)

**Prompt strategy**: System prompt instructs Gemini to return JSON array of 6-8 exercises, each with: `name`, `primaryMuscles[]`, `secondaryMuscles[]`, `suggestedSets`, `suggestedReps`, `description`, `instructions`. Equipment list included to constrain recommendations.

**Error handling**: 15s timeout, user-friendly error with retry button. Rate limit ~10 req/min/user via in-memory counter.

**Environment variable**: `GEMINI_API_KEY` in `.env.local`

## 4. Data Flow & Custom Exercise Creation

When user clicks "Add" on a suggestion not in the DB:

1. Client sends exercise data to `POST /api/ai/create-exercise`
2. Server creates `exercises` row (`is_custom = true`, `created_by = user_id`)
3. Server creates `exercise_muscles` rows (primary/secondary mappings, normalized against `muscles` table)
4. Server creates `exercise_equipment` rows linking to relevant equipment
5. Returns new exercise ID
6. Client adds exercise to template

**Muscle matching**: Normalize Gemini muscle names against `muscles` table. Skip unmatched mappings rather than creating bad data.

## 5. Saved AI Suggestions

**Database**: New `saved_ai_suggestions` table:
- `id` UUID primary key
- `user_id` UUID references profiles(id)
- `exercise_name` text
- `exercise_id` UUID nullable (references exercises, if matched existing)
- `primary_muscles` text[]
- `secondary_muscles` text[]
- `suggested_sets` int
- `suggested_reps` int
- `description` text
- `instructions` text
- `workout_type` text
- `created_at` timestamptz

**UI**: "Saved" tab in copilot panel shows bookmarked suggestions with "Add" buttons. Remove via click/swipe.

**Behavior**: Saving is instant (persists suggestion data, no AI call). Custom exercise creation happens at "Add" time, not save time.

**RLS**: Users can only see their own saved suggestions.

## 6. Testing

**Unit tests** (Vitest):
- Muscle name normalization/matching
- Request payload validation
- Gemini response parsing (mock API, test well-formed and malformed responses)

**E2E tests** (Playwright):
- Open AI panel from template builder, generate suggestions, add to template
- Open AI panel from exercises page, generate suggestions
- Add custom equipment item, verify it appears in profile
- Save a suggestion, verify it appears in Saved tab

**Edge cases**:
- Close name match (e.g., "Bench Press" vs "Barbell Bench Press") — fuzzy match, prefer existing DB exercise
- No active equipment profile — show message with link to equipment page
- Empty equipment profile — recommend bodyweight exercises
- Gemini API down/slow — 15s timeout, error with retry
- Duplicate in template — "Add" button shows "Already added" (disabled)

## Out of Scope

- Caching Gemini responses
- Streaming Gemini responses
- AI-powered exercise swap (existing deterministic swap is sufficient)
