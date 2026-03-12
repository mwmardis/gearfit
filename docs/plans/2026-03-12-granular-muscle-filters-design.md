# Granular Muscle Group Filtering

**Date:** 2026-03-12
**Status:** Approved

## Problem

The exercise filter bar has 6 broad categories (Chest, Back, Shoulders, Arms, Legs, Core) but users want to filter by specific muscles (e.g., Biceps vs Triceps). The DB already stores 17 distinct muscle groups — we just need to expose them in the UI.

## Design

### Interaction Model

Two-level hierarchy with single-select:

- Clicking a broad category filters to all muscles in that group and reveals a sub-row of specific muscles
- Clicking a specific muscle narrows the filter to just that group
- Clicking the active category again resets to "All Muscles"
- Clicking a different category swaps the sub-row
- "All Muscles" always clears everything

### State Shape

Replace `muscleGroup: string` with:

```ts
interface MuscleFilter {
  category: string;  // "Arms", "Legs", etc. or ""
  specific: string;  // "Biceps", "Quadriceps", etc. or ""
}
```

Filter precedence: `specific` > `category` > show all.

### UI Layout

Two rows in `ExerciseFilters`:

- **Row 1:** Search input + broad category buttons (unchanged layout) + available toggle
- **Row 2 (conditional):** Specific muscle buttons for the active category

Row 2 behavior:
- `overflow-hidden` container with `transition-all duration-200` on `max-height`
- Slides in when a category is selected, slides out when cleared
- Sub-buttons use `size="xs"` and `variant="outline"` (active: `variant="secondary"`)
- Active broad category gets a `ChevronDown` icon from lucide-react

### Label Overrides

Most sub-buttons use the DB `muscle_group` value directly. Two are shortened:

- Quadriceps → Quads
- Trapezius → Traps

### Data Source

The existing `muscleGroupMap` in `exercise-filters.tsx` already maps categories to DB values. It will also serve as the data source for which sub-buttons to render. No DB or schema changes needed.

### Files Changed

1. `src/components/exercises/exercise-filters.tsx` — sub-row, animation, chevron, label overrides
2. `src/app/(app)/exercises/client.tsx` — state shape, filter logic, prop changes

## Decisions

- Two-level hierarchy over flat list (keeps broad categories as useful starting point)
- Inline sub-row over dropdown (better discoverability, works on mobile)
- Animated with `transition-all` for polish
- Single-select for simplicity (one sub-muscle at a time)
- No DB changes (pure frontend)
