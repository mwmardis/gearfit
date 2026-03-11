# ExRx.net Exercise Crawl Design

**Date:** 2026-03-11
**Goal:** Crawl ExRx.net's full exercise directory (~800-1500 exercises) to massively expand the exercise, equipment, and muscle databases.

## Decisions

- **Scope:** Full catalog — every exercise from every body region
- **Data richness:** Expand schema with mechanics, force, category fields
- **Muscles:** Two-tier system — current 15 become `muscleGroup` categories, add ~50-80 granular muscles underneath
- **Equipment:** Full overhaul aligned to ExRx taxonomy, recategorized
- **Muscle roles:** primary, secondary, stabilizer (new third role)
- **Data quality:** Crawl to JSON with validation report before generating migrations
- **Crawl strategy:** Subagent-per-body-region with WebFetch

## Crawl Architecture

### Phase 1 — Directory Discovery

Fetch `https://exrx.net/Lists/Directory` and extract all body region URLs:
- Neck, Shoulders, Upper Arms, Forearms, Back, Chest, Waist, Hips, Thighs, Calves
- Plus "Other Exercises" (olympic lifts, plyometrics, kettlebell)

### Phase 2 — Parallel Body Region Crawl

Dispatch ~10-12 subagents simultaneously, one per body region. Each subagent:
1. Fetches its body region page (e.g., `/Lists/ExList/ChestWt`)
2. Identifies all exercise links on the page
3. For each exercise, fetches the detail page via WebFetch
4. Extracts structured data into a JSON object
5. Returns its full JSON array back to the orchestrator

### Phase 3 — Merge & Validate

Orchestrator collects all subagent results, merges into a single dataset, and runs validation.

### Output Files

- `data/exrx-raw/exercises.json` — full crawled dataset
- `data/exrx-raw/equipment.json` — discovered equipment taxonomy
- `data/exrx-raw/muscles.json` — discovered muscle taxonomy
- `data/exrx-raw/validation-report.md` — issues flagged for review

## Data Schema Per Exercise

```json
{
  "name": "Barbell Bench Press",
  "source": "exrx.net/WeightExercises/PectoralSternal/BBBenchPress",
  "bodyRegion": "Chest",
  "targetMuscle": "Pectoralis Major, Sternal",
  "synergists": ["Pectoralis Major, Clavicular", "Deltoid, Anterior", "Triceps Brachii"],
  "stabilizers": ["Biceps Brachii, Short Head"],
  "equipment": "Barbell",
  "auxiliaryEquipment": ["Flat Bench"],
  "mechanics": "compound",
  "force": "push",
  "category": "strength",
  "preparation": "Lie supine on bench...",
  "execution": "Lower weight to chest..."
}
```

### Mapping to Schema

| Crawled Field | DB Destination |
|---|---|
| `targetMuscle` | `exercise_muscles` with role=`primary` |
| `synergists` | `exercise_muscles` with role=`secondary` |
| `stabilizers` | `exercise_muscles` with role=`stabilizer` |
| `preparation` + `execution` | `exercises.instructions` |
| `equipment` + `auxiliaryEquipment` | `exercise_equipment` junction |
| `mechanics`, `force`, `category` | New columns on `exercises` |
| `bodyRegion` | New `body_region` column on `exercises` |
| `source` | New `source_url` column on `exercises` |

## Schema Changes

### `exercises` table — new columns
- `mechanics` — enum: `compound`, `isolation` (nullable)
- `force` — enum: `push`, `pull`, `static` (nullable)
- `category` — enum: `strength`, `stretch`, `plyometric`, `olympic`, `cardio` (nullable)
- `body_region` — text (nullable)
- `source_url` — text (nullable)

### `muscles` table — expansion
- Add ~50-80 muscles with granular names from ExRx
- Each muscle keeps `muscle_group` pointing to a high-level group
- Current 15 muscle names become the group labels
- Example: `{ name: "Pectoralis Major, Sternal", muscleGroup: "chest" }`

### `exercise_muscles` table
- Expand `role` enum: `primary | secondary | stabilizer`

### `equipment` table — overhaul
- Replace existing 21 pre-built items with ExRx-aligned taxonomy
- New categories: `barbell`, `dumbbell`, `cable`, `lever`, `sled`, `body_weight`, `suspended`, `band`, `accessory`, etc.
- User custom equipment (`is_custom = true`) remains untouched
- Old-to-new mapping migration for equipment profiles

## Subagent Design

Each body-region subagent:
- Handles ONE body region end-to-end
- Uses `WebFetch` to retrieve pages
- Logs failed URLs and continues (no blocking)
- Returns JSON array + list of failed URLs

All ~10-12 subagents launch simultaneously via parallel `Agent` tool calls. No shared state between subagents.

Large regions (150+ exercises) may be split into sub-regions if needed.

## Post-Crawl Pipeline

1. **Merge** — Combine all region JSONs, deduplicate by name
2. **Extract Taxonomies** — Build complete `muscles.json` and `equipment.json` from exercise data
3. **Validation Report** — Flag missing data, duplicates, unmapped muscles/equipment, failed URLs
4. **User Review** — Manual review of JSON files and validation report
5. **Generate Migrations** — SQL migrations for schema changes, new seed data, equipment remapping
6. **Update TypeScript** — Validators, enums, UI code referencing old categories/roles
