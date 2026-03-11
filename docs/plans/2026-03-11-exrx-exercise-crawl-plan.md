# ExRx Exercise Crawl Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Crawl ExRx.net's full exercise directory (~800-1500 exercises) into structured JSON, validate the data, then generate database migrations to expand exercises, equipment, and muscles.

**Architecture:** Three-phase pipeline: (1) crawl ExRx via parallel subagents per body region, (2) merge/validate/review, (3) generate schema migrations and update TypeScript. Data lands in `data/exrx-raw/` as JSON before touching the DB.

**Tech Stack:** WebFetch for crawling, Agent tool for parallel subagents, Supabase SQL migrations, Drizzle ORM schema, TypeScript validators.

---

## Task 1: Create Output Directory and Crawl the Directory Page

**Files:**
- Create: `data/exrx-raw/` (directory)

**Step 1: Create the output directory**

```bash
mkdir -p data/exrx-raw
```

**Step 2: Fetch the ExRx directory page**

Use `WebFetch` on `https://exrx.net/Lists/Directory` to extract all body region page URLs.

Expected output: A list of ~10-12 body region URLs like:
- `https://exrx.net/Lists/ExList/NeckWt`
- `https://exrx.net/Lists/ExList/ShouldWt`
- `https://exrx.net/Lists/ExList/ArmWt` (or separate Upper Arms/Forearms)
- `https://exrx.net/Lists/ExList/BackWt`
- `https://exrx.net/Lists/ExList/ChestWt`
- `https://exrx.net/Lists/ExList/WaistWt`
- `https://exrx.net/Lists/ExList/HipsWt`
- `https://exrx.net/Lists/ExList/ThsWt` (Thighs)
- `https://exrx.net/Lists/ExList/CalfWt`

Also look for "Other Exercises" sections (Olympic lifts, plyometrics, kettlebell).

**Step 3: Save the URL list**

Write the discovered URLs to `data/exrx-raw/body-regions.json`:

```json
[
  { "region": "Neck", "url": "https://exrx.net/Lists/ExList/NeckWt" },
  { "region": "Shoulders", "url": "https://exrx.net/Lists/ExList/ShouldWt" },
  ...
]
```

**Step 4: Commit**

```bash
git add data/exrx-raw/body-regions.json
git commit -m "chore: crawl ExRx directory page for body region URLs"
```

---

## Task 2: Dispatch Parallel Subagents to Crawl Each Body Region

**Files:**
- Create: `data/exrx-raw/region-*.json` (one per body region)

This is the core crawl task. Launch all subagents simultaneously using multiple `Agent` tool calls in a single message.

**Subagent prompt template** (customize `REGION_NAME` and `REGION_URL` for each):

```
You are crawling exercise data from ExRx.net for the REGION_NAME body region.

START URL: REGION_URL

INSTRUCTIONS:
1. Fetch the body region page using WebFetch
2. Extract all individual exercise page links from the page
3. For EACH exercise link, fetch the exercise detail page using WebFetch
4. From each exercise page, extract this data into a JSON object:
   - name: Exercise name (e.g., "Barbell Bench Press")
   - source: The URL path (e.g., "exrx.net/WeightExercises/PectoralSternal/BBBenchPress")
   - bodyRegion: "REGION_NAME"
   - targetMuscle: The "Target" muscle listed (e.g., "Pectoralis Major, Sternal")
   - synergists: Array of synergist muscles listed
   - stabilizers: Array of stabilizer muscles listed
   - equipment: Primary equipment (e.g., "Barbell", "Dumbbell", "Cable", "Lever", "Body Weight")
   - auxiliaryEquipment: Array of any secondary equipment (e.g., ["Bench"])
   - mechanics: "compound" or "isolation" (as listed on page)
   - force: "push", "pull", or "static" (as listed on page)
   - category: "strength", "stretch", "plyometric", "olympic", or "cardio" based on the exercise type
   - preparation: The preparation/setup instructions text
   - execution: The execution/movement instructions text
5. If a page fails to load, log the URL in a "failed" array and continue
6. Return your complete results as a JSON object:
   {
     "region": "REGION_NAME",
     "exercises": [...],
     "failed": ["url1", "url2"],
     "totalFound": N,
     "totalCrawled": N
   }

IMPORTANT:
- Use EXACT muscle names as they appear on ExRx (e.g., "Pectoralis Major, Sternal" not "Chest")
- Use EXACT equipment names as they appear on ExRx (e.g., "Lever (plate loaded)" not "Machine")
- If a field is not present on the page, use null
- Do NOT skip any exercises — crawl every single link on the page
- Some pages may list exercises under sub-sections by muscle — crawl all of them
```

**Step 1: Launch all subagents in parallel**

Use one message with ~10-12 `Agent` tool calls, one per body region discovered in Task 1. Each agent uses `subagent_type: "general-purpose"`.

**Step 2: Collect results**

As each subagent completes, save its JSON output to `data/exrx-raw/region-{name}.json`.

**Step 3: Commit raw crawl data**

```bash
git add data/exrx-raw/region-*.json
git commit -m "chore: crawl ExRx exercises for all body regions"
```

---

## Task 3: Merge, Deduplicate, and Extract Taxonomies

**Files:**
- Create: `data/exrx-raw/exercises.json`
- Create: `data/exrx-raw/muscles.json`
- Create: `data/exrx-raw/equipment.json`

**Step 1: Merge all region files**

Read all `data/exrx-raw/region-*.json` files. Combine all exercises into a single array. Deduplicate by exercise name (some exercises appear under multiple body regions — keep the first occurrence, note duplicates).

Write merged result to `data/exrx-raw/exercises.json`.

**Step 2: Extract muscle taxonomy**

Scan every exercise's `targetMuscle`, `synergists`, and `stabilizers` fields. Build a unique list of all muscle names encountered. For each muscle, auto-assign a `muscleGroup` based on the body region it was found under:

Mapping guide:
- Neck exercises → `muscleGroup: "neck"`
- Shoulders exercises → `muscleGroup: "shoulders"`
- Upper Arms exercises → `muscleGroup: "arms"`
- Forearms exercises → `muscleGroup: "arms"`
- Back exercises → `muscleGroup: "back"`
- Chest exercises → `muscleGroup: "chest"`
- Waist exercises → `muscleGroup: "core"`
- Hips exercises → `muscleGroup: "hips"`
- Thighs exercises → `muscleGroup: "legs"`
- Calves exercises → `muscleGroup: "legs"`

For muscles that appear across multiple regions (e.g., "Deltoid, Anterior" appears in Chest AND Shoulders), use the most specific/primary region.

Write to `data/exrx-raw/muscles.json`:
```json
[
  { "name": "Pectoralis Major, Sternal", "muscleGroup": "chest" },
  { "name": "Deltoid, Anterior", "muscleGroup": "shoulders" },
  ...
]
```

**Step 3: Extract equipment taxonomy**

Scan every exercise's `equipment` and `auxiliaryEquipment` fields. Build a unique list. Assign categories:

- "Barbell" → `barbell`
- "Dumbbell" → `dumbbell`
- "Cable" → `cable`
- "Lever (plate loaded)", "Lever (selectorized)" → `lever`
- "Sled (plate loaded)" → `sled`
- "Smith" → `smith`
- "Body Weight" → `body_weight`
- "Suspended (bodyweight)" → `suspended`
- "Band" → `band`
- "Bench", "Incline Bench" → `bench`
- "Pull-up Bar", "Dip Bar" → `bodyweight_station`
- Other → `accessory`

Write to `data/exrx-raw/equipment.json`:
```json
[
  { "name": "Barbell", "category": "barbell" },
  { "name": "Cable", "category": "cable" },
  ...
]
```

**Step 4: Commit**

```bash
git add data/exrx-raw/exercises.json data/exrx-raw/muscles.json data/exrx-raw/equipment.json
git commit -m "chore: merge and extract taxonomies from crawled data"
```

---

## Task 4: Generate Validation Report

**Files:**
- Create: `data/exrx-raw/validation-report.md`

**Step 1: Analyze the merged data and generate a report**

Read `exercises.json`, `muscles.json`, `equipment.json` and produce `validation-report.md` with:

```markdown
# ExRx Crawl Validation Report

## Summary
- Total exercises: N
- Total unique muscles: N
- Total unique equipment: N
- Failed URLs: N

## Exercises by Body Region
| Region | Count |
|--------|-------|
| Chest  | N     |
| ...    | ...   |

## Issues

### Exercises Missing Target Muscle (N)
- Exercise Name (source URL)

### Exercises Missing Equipment (N)
- Exercise Name (source URL)

### Duplicate Exercise Names (N)
- "Name" found in [Region1, Region2]

### Unmapped Muscles (N)
Muscles that couldn't be auto-assigned to a muscleGroup:
- "Muscle Name" (found in Region)

### Unmapped Equipment (N)
Equipment that couldn't be auto-categorized:
- "Equipment Name" (found in N exercises)

### Failed URLs (N)
- URL (Region)

## Equipment Taxonomy
| Name | Category | Used By N Exercises |

## Muscle Taxonomy
| Name | Group | Used as Target N / Synergist N / Stabilizer N |
```

**Step 2: Present report to user for review**

Display the summary section and ask user to review the full report. Pause here for user feedback before proceeding to migrations.

**Step 3: Commit**

```bash
git add data/exrx-raw/validation-report.md
git commit -m "chore: generate ExRx crawl validation report"
```

---

## Task 5: Generate Schema Migration — Add Exercise Columns and Update Role Enum

**Files:**
- Create: `supabase/migrations/20260311000001_expand_exercise_schema.sql`
- Modify: `src/lib/db/schema.ts:74-83` (exercises table)
- Modify: `src/lib/db/schema.ts:101-114` (exercise_muscles table)

**Step 1: Write the SQL migration**

```sql
-- Add new columns to exercises table
ALTER TABLE public.exercises
  ADD COLUMN IF NOT EXISTS mechanics text,
  ADD COLUMN IF NOT EXISTS force text,
  ADD COLUMN IF NOT EXISTS category text,
  ADD COLUMN IF NOT EXISTS body_region text,
  ADD COLUMN IF NOT EXISTS source_url text;

-- Add check constraints
ALTER TABLE public.exercises
  ADD CONSTRAINT exercises_mechanics_check CHECK (mechanics IN ('compound', 'isolation')),
  ADD CONSTRAINT exercises_force_check CHECK (force IN ('push', 'pull', 'static')),
  ADD CONSTRAINT exercises_category_check CHECK (category IN ('strength', 'stretch', 'plyometric', 'olympic', 'cardio'));

-- Update exercise_muscles role to support 'stabilizer'
-- The role column is text, so we just need to add a check constraint
-- First drop existing constraint if any, then add new one
DO $$ BEGIN
  ALTER TABLE public.exercise_muscles
    DROP CONSTRAINT IF EXISTS exercise_muscles_role_check;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

ALTER TABLE public.exercise_muscles
  ADD CONSTRAINT exercise_muscles_role_check CHECK (role IN ('primary', 'secondary', 'stabilizer'));
```

**Step 2: Update Drizzle schema**

In `src/lib/db/schema.ts`, update the `exercises` table to add the new columns:

```typescript
export const exercises = pgTable("exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  description: text("description"),
  instructions: text("instructions"),
  mechanics: text("mechanics"), // 'compound' | 'isolation'
  force: text("force"), // 'push' | 'pull' | 'static'
  category: text("category"), // 'strength' | 'stretch' | 'plyometric' | 'olympic' | 'cardio'
  bodyRegion: text("body_region"),
  sourceUrl: text("source_url"),
  isCustom: boolean("is_custom").notNull().default(false),
  createdBy: uuid("created_by").references(() => profiles.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});
```

Update the `exercise_muscles` role comment:

```typescript
role: text("role").notNull(), // 'primary' | 'secondary' | 'stabilizer'
```

**Step 3: Commit**

```bash
git add supabase/migrations/20260311000001_expand_exercise_schema.sql src/lib/db/schema.ts
git commit -m "feat: add mechanics/force/category columns and stabilizer role"
```

---

## Task 6: Generate Migration — Overhaul Equipment Table

**Files:**
- Create: `supabase/migrations/20260311000002_overhaul_equipment.sql`
- Modify: `src/lib/validators/equipment.ts`

**Step 1: Write the SQL migration**

This migration:
1. Inserts new equipment items from `data/exrx-raw/equipment.json`
2. Updates categories on existing equipment to match new taxonomy
3. Creates a mapping from old equipment names to new ones for equipment profiles

The exact SQL depends on the crawled `equipment.json` data. Generate it dynamically from that file.

Pattern:
```sql
-- Update existing equipment categories to new taxonomy
UPDATE public.equipment SET category = 'barbell' WHERE name = 'Barbell' AND is_custom = false;
UPDATE public.equipment SET category = 'barbell' WHERE name = 'EZ Curl Bar' AND is_custom = false;
UPDATE public.equipment SET category = 'dumbbell' WHERE name = 'Dumbbells' AND is_custom = false;
-- ... etc for all existing 21 items

-- Insert new equipment discovered from ExRx
INSERT INTO public.equipment (name, category, is_custom) VALUES
  ('Lever (plate loaded)', 'lever', false),
  ('Lever (selectorized)', 'lever', false),
  ('Sled (plate loaded)', 'sled', false),
  -- ... etc from equipment.json, skipping items that already exist
ON CONFLICT DO NOTHING;
```

**Step 2: Update equipment validator**

```typescript
export const VALID_CATEGORIES = [
  "barbell",
  "dumbbell",
  "cable",
  "lever",
  "sled",
  "smith",
  "body_weight",
  "suspended",
  "band",
  "bench",
  "bodyweight_station",
  "accessory",
] as const;
```

**Step 3: Commit**

```bash
git add supabase/migrations/20260311000002_overhaul_equipment.sql src/lib/validators/equipment.ts
git commit -m "feat: overhaul equipment taxonomy from ExRx data"
```

---

## Task 7: Generate Migration — Expand Muscles Table

**Files:**
- Create: `supabase/migrations/20260311000003_expand_muscles.sql`

**Step 1: Write the SQL migration**

Generated dynamically from `data/exrx-raw/muscles.json`:

```sql
-- Insert new muscles (skip existing ones via ON CONFLICT)
INSERT INTO public.muscles (name, muscle_group) VALUES
  ('Pectoralis Major, Sternal', 'chest'),
  ('Pectoralis Major, Clavicular', 'chest'),
  ('Deltoid, Anterior', 'shoulders'),
  ('Deltoid, Lateral', 'shoulders'),
  ('Deltoid, Posterior', 'shoulders'),
  ('Triceps Brachii', 'arms'),
  ('Biceps Brachii', 'arms'),
  ('Brachialis', 'arms'),
  ('Brachioradialis', 'arms'),
  -- ... all muscles from muscles.json
ON CONFLICT (name) DO UPDATE SET muscle_group = EXCLUDED.muscle_group;
```

Note: The existing 15 muscles (Chest, Triceps, Biceps, etc.) remain in the table. They now serve as coarse-grained entries alongside the new granular ones. The `muscle_group` field ties them together.

**Step 2: Commit**

```bash
git add supabase/migrations/20260311000003_expand_muscles.sql
git commit -m "feat: expand muscles table with granular ExRx anatomy"
```

---

## Task 8: Generate Migration — Seed All Crawled Exercises

**Files:**
- Create: `supabase/migrations/20260311000004_seed_exrx_exercises.sql`

**Step 1: Write the SQL migration**

Generated dynamically from `data/exrx-raw/exercises.json`. Uses the same helper function pattern as the existing seed file:

```sql
-- Helper functions
CREATE OR REPLACE FUNCTION get_equipment_id(eq_name text) RETURNS uuid AS $$
  SELECT id FROM public.equipment WHERE name = eq_name LIMIT 1;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION get_muscle_id(m_name text) RETURNS uuid AS $$
  SELECT id FROM public.muscles WHERE name = m_name LIMIT 1;
$$ LANGUAGE sql STABLE;

-- Delete existing pre-built exercises (they'll be replaced by crawled data)
DELETE FROM public.exercises WHERE is_custom = false;

-- Insert all crawled exercises
-- (generated per-exercise blocks from exercises.json)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, mechanics, force, category, body_region, source_url, is_custom)
  VALUES ('Barbell Bench Press', NULL, 'Preparation: ... Execution: ...', 'compound', 'push', 'strength', 'Chest', 'exrx.net/...', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id) VALUES
  ((SELECT id FROM ex), get_equipment_id('Barbell')),
  ((SELECT id FROM ex), get_equipment_id('Bench'));
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, get_muscle_id(m.name), m.role FROM public.exercises e,
  (VALUES
    ('Pectoralis Major, Sternal', 'primary'),
    ('Deltoid, Anterior', 'secondary'),
    ('Triceps Brachii', 'secondary'),
    ('Biceps Brachii, Short Head', 'stabilizer')
  ) AS m(name, role)
WHERE e.name = 'Barbell Bench Press';

-- ... repeat for all ~800-1500 exercises

-- Cleanup
DROP FUNCTION get_equipment_id;
DROP FUNCTION get_muscle_id;
```

This will be a very large file. Generate it programmatically from the JSON.

**Step 2: Commit**

```bash
git add supabase/migrations/20260311000004_seed_exrx_exercises.sql
git commit -m "feat: seed all ExRx crawled exercises"
```

---

## Task 9: Update TypeScript Types and Validators

**Files:**
- Modify: `src/lib/validators/muscles.ts`
- Modify: `src/lib/actions/exercises.ts` (if it references old muscle/equipment names)
- Modify: `src/lib/ai/types.ts` (if recommendation types need updating)

**Step 1: Update muscle validator**

The `normalizeMuscleNames` function in `src/lib/validators/muscles.ts` already does case-insensitive matching against DB names, so it should work with the expanded list without changes. Verify this is the case.

**Step 2: Check exercise actions**

Read `src/lib/actions/exercises.ts` and verify the `ExerciseFilters` interface and query logic work with the new columns. If `muscleGroup` filtering is used, it should still work since we kept the `muscle_group` column.

Consider adding new filter options:
```typescript
export interface ExerciseFilters {
  muscleGroup?: string;
  availableOnly?: boolean;
  search?: string;
  mechanics?: 'compound' | 'isolation';
  force?: 'push' | 'pull' | 'static';
  category?: 'strength' | 'stretch' | 'plyometric' | 'olympic' | 'cardio';
  bodyRegion?: string;
}
```

**Step 3: Check AI types**

Read `src/lib/ai/types.ts` and verify recommendation types still work. The `GeminiExerciseSuggestion` type references `primaryMuscles` and `secondaryMuscles` as string arrays — these should still work fine with the expanded muscle names.

**Step 4: Commit**

```bash
git add src/lib/validators/ src/lib/actions/exercises.ts
git commit -m "feat: update TypeScript types for expanded exercise schema"
```

---

## Task 10: Final Verification

**Step 1: Verify all files are consistent**

- `data/exrx-raw/exercises.json` matches the seed migration
- `data/exrx-raw/muscles.json` matches the muscles migration
- `data/exrx-raw/equipment.json` matches the equipment migration
- Drizzle schema matches SQL migrations
- TypeScript validators match new categories/enums

**Step 2: Run type checking**

```bash
npx tsc --noEmit
```

Fix any TypeScript errors.

**Step 3: Final commit**

```bash
git add -A
git commit -m "chore: verify ExRx data pipeline consistency"
```
