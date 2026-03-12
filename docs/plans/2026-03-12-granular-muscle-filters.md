# Granular Muscle Group Filtering — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a two-level muscle filter: broad categories expand an animated sub-row of specific muscle groups.

**Architecture:** Pure frontend change across two files. `ExerciseFilters` gets an animated sub-row of specific muscle buttons. `ExercisesPageClient` state changes from `muscleGroup: string` to `MuscleFilter { category, specific }`. Existing `muscleGroupMap` drives both the sub-button rendering and the filter logic.

**Tech Stack:** React, shadcn/ui Button, lucide-react ChevronDown, Tailwind CSS transitions, Vitest + React Testing Library

---

### Task 1: Export `MuscleFilter` type and label overrides from `exercise-filters.tsx`

**Files:**
- Modify: `src/components/exercises/exercise-filters.tsx:1-24`

**Step 1: Add the type and label map**

Add the `MuscleFilter` interface export and a `subMuscleLabels` map right after the existing `muscleGroupMap`:

```ts
export interface MuscleFilter {
  category: string; // "Arms", "Legs", etc. or ""
  specific: string; // "Biceps", "Quadriceps", etc. or ""
}

export const subMuscleLabels: Record<string, string> = {
  Quadriceps: "Quads",
  Trapezius: "Traps",
};
```

**Step 2: Verify the app still compiles**

Run: `npx next lint`
Expected: No new errors

**Step 3: Commit**

```bash
git add src/components/exercises/exercise-filters.tsx
git commit -m "feat: add MuscleFilter type and sub-muscle label overrides"
```

---

### Task 2: Update `ExerciseFilters` props and add animated sub-row

**Files:**
- Modify: `src/components/exercises/exercise-filters.tsx:26-72`

**Step 1: Update props interface**

Replace the current `ExerciseFiltersProps`:

```ts
interface ExerciseFiltersProps {
  search: string;
  muscleFilter: MuscleFilter;
  availableOnly: boolean;
  onSearchChange: (search: string) => void;
  onMuscleFilterChange: (filter: MuscleFilter) => void;
  onAvailableOnlyChange: (available: boolean) => void;
}
```

**Step 2: Import ChevronDown**

Add to imports at top of file:

```ts
import { ChevronDown } from "lucide-react";
```

**Step 3: Add a `useRef` + `useEffect` for animated max-height**

Add to imports:

```ts
import { useRef, useEffect } from "react";
```

**Step 4: Rewrite the component body**

Replace the entire `ExerciseFilters` function with:

```tsx
export function ExerciseFilters({
  search,
  muscleFilter,
  availableOnly,
  onSearchChange,
  onMuscleFilterChange,
  onAvailableOnlyChange,
}: ExerciseFiltersProps) {
  const subRowRef = useRef<HTMLDivElement>(null);
  const activeCategory = muscleFilter.category;
  const subMuscles = activeCategory ? muscleGroupMap[activeCategory] ?? [] : [];

  useEffect(() => {
    const el = subRowRef.current;
    if (!el) return;
    if (subMuscles.length > 0) {
      el.style.maxHeight = el.scrollHeight + "px";
    } else {
      el.style.maxHeight = "0px";
    }
  }, [subMuscles]);

  function handleCategoryClick(value: string) {
    if (value === "" || value === activeCategory) {
      // "All Muscles" or toggle off active category
      onMuscleFilterChange({ category: "", specific: "" });
    } else {
      // New category selected
      onMuscleFilterChange({ category: value, specific: "" });
    }
  }

  function handleSpecificClick(value: string) {
    if (value === muscleFilter.specific) {
      // Toggle off — back to whole category
      onMuscleFilterChange({ category: activeCategory, specific: "" });
    } else {
      onMuscleFilterChange({ category: activeCategory, specific: value });
    }
  }

  return (
    <div className="flex flex-col gap-2">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <Input
          placeholder="Search exercises..."
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          className="max-w-xs"
        />
        <div className="flex flex-wrap gap-1">
          {muscleGroups.map((mg) => (
            <Button
              key={mg.value}
              variant={activeCategory === mg.value ? "default" : "outline"}
              size="sm"
              onClick={() => handleCategoryClick(mg.value)}
            >
              {mg.label}
              {mg.value && activeCategory === mg.value && (
                <ChevronDown className="size-3" />
              )}
            </Button>
          ))}
        </div>
        <Button
          variant={availableOnly ? "default" : "outline"}
          size="sm"
          onClick={() => onAvailableOnlyChange(!availableOnly)}
        >
          {availableOnly ? "Available Only" : "Show All"}
        </Button>
      </div>
      <div
        ref={subRowRef}
        className="overflow-hidden transition-all duration-200"
        style={{ maxHeight: 0 }}
      >
        <div className="flex flex-wrap gap-1 pt-1">
          {subMuscles.map((muscle) => (
            <Button
              key={muscle}
              variant={muscleFilter.specific === muscle ? "secondary" : "outline"}
              size="xs"
              onClick={() => handleSpecificClick(muscle)}
            >
              {subMuscleLabels[muscle] ?? muscle}
            </Button>
          ))}
        </div>
      </div>
    </div>
  );
}
```

**Step 5: Verify — app will NOT compile yet**

This is expected — `client.tsx` still passes the old props. Move to Task 3.

---

### Task 3: Update `client.tsx` state and filter logic

**Files:**
- Modify: `src/app/(app)/exercises/client.tsx`

**Step 1: Update imports**

Change line 4 from:

```ts
import { ExerciseFilters, muscleGroupMap } from "@/components/exercises/exercise-filters";
```

to:

```ts
import { ExerciseFilters, muscleGroupMap, type MuscleFilter } from "@/components/exercises/exercise-filters";
```

**Step 2: Replace state declaration**

Replace line 32:

```ts
const [muscleGroup, setMuscleGroup] = useState("");
```

with:

```ts
const [muscleFilter, setMuscleFilter] = useState<MuscleFilter>({ category: "", specific: "" });
```

**Step 3: Update filter logic in `useMemo`**

Replace the muscle group filter block (lines 43-53) with:

```ts
if (muscleFilter.specific) {
  result = result.filter((ex) =>
    ex.exerciseMuscles.some(
      (em) =>
        em.muscle?.muscleGroup === muscleFilter.specific &&
        em.role === "primary"
    )
  );
} else if (muscleFilter.category) {
  const dbGroups = muscleGroupMap[muscleFilter.category] ?? [muscleFilter.category];
  result = result.filter((ex) =>
    ex.exerciseMuscles.some(
      (em) =>
        em.muscle?.muscleGroup &&
        dbGroups.includes(em.muscle.muscleGroup) &&
        em.role === "primary"
    )
  );
}
```

**Step 4: Update `useMemo` dependency array**

Change:

```ts
}, [initialExercises, search, muscleGroup]);
```

to:

```ts
}, [initialExercises, search, muscleFilter]);
```

**Step 5: Update `ExerciseFilters` props in JSX**

Replace lines 65-72:

```tsx
<ExerciseFilters
  search={search}
  muscleGroup={muscleGroup}
  availableOnly={availableOnly}
  onSearchChange={setSearch}
  onMuscleGroupChange={setMuscleGroup}
  onAvailableOnlyChange={setAvailableOnly}
/>
```

with:

```tsx
<ExerciseFilters
  search={search}
  muscleFilter={muscleFilter}
  availableOnly={availableOnly}
  onSearchChange={setSearch}
  onMuscleFilterChange={setMuscleFilter}
  onAvailableOnlyChange={setAvailableOnly}
/>
```

**Step 6: Verify the app compiles and runs**

Run: `npx next lint`
Expected: No errors

**Step 7: Commit**

```bash
git add src/components/exercises/exercise-filters.tsx src/app/\(app\)/exercises/client.tsx
git commit -m "feat: two-level muscle filter with animated sub-row"
```

---

### Task 4: Write tests for filter logic

**Files:**
- Create: `src/components/exercises/__tests__/exercise-filters.test.tsx`

**Step 1: Create the test file**

```tsx
import { describe, it, expect } from "vitest";
import { muscleGroupMap, subMuscleLabels } from "../exercise-filters";
import type { MuscleFilter } from "../exercise-filters";

describe("muscleGroupMap", () => {
  it("maps every category to at least one DB muscle group", () => {
    for (const [category, groups] of Object.entries(muscleGroupMap)) {
      expect(groups.length).toBeGreaterThan(0);
    }
  });

  it("Arms includes Biceps, Triceps, and Forearms", () => {
    expect(muscleGroupMap.Arms).toEqual(["Biceps", "Triceps", "Forearms"]);
  });

  it("Legs includes all lower-body groups", () => {
    expect(muscleGroupMap.Legs).toContain("Quadriceps");
    expect(muscleGroupMap.Legs).toContain("Hamstrings");
    expect(muscleGroupMap.Legs).toContain("Glutes");
    expect(muscleGroupMap.Legs).toContain("Calves");
  });
});

describe("subMuscleLabels", () => {
  it("shortens Quadriceps to Quads", () => {
    expect(subMuscleLabels["Quadriceps"]).toBe("Quads");
  });

  it("shortens Trapezius to Traps", () => {
    expect(subMuscleLabels["Trapezius"]).toBe("Traps");
  });

  it("does not override Biceps", () => {
    expect(subMuscleLabels["Biceps"]).toBeUndefined();
  });
});

describe("MuscleFilter type", () => {
  it("can represent no filter", () => {
    const filter: MuscleFilter = { category: "", specific: "" };
    expect(filter.category).toBe("");
    expect(filter.specific).toBe("");
  });

  it("can represent category-only filter", () => {
    const filter: MuscleFilter = { category: "Arms", specific: "" };
    expect(filter.category).toBe("Arms");
  });

  it("can represent specific muscle filter", () => {
    const filter: MuscleFilter = { category: "Arms", specific: "Biceps" };
    expect(filter.specific).toBe("Biceps");
  });
});
```

**Step 2: Run the tests**

Run: `npx vitest run src/components/exercises/__tests__/exercise-filters.test.tsx`
Expected: All tests PASS

**Step 3: Commit**

```bash
git add src/components/exercises/__tests__/exercise-filters.test.tsx
git commit -m "test: add unit tests for muscle filter data and types"
```

---

### Task 5: Manual verification in browser

**Step 1: Start dev server**

Use `preview_start` with the `next-dev` configuration.

**Step 2: Navigate to `/exercises`**

**Step 3: Verify broad category filtering**

- Click "Chest" → exercises filter to chest exercises, sub-row appears with "Chest" sub-button
- Click "Arms" → sub-row swaps to "Biceps", "Triceps", "Forearms"
- Click "Legs" → sub-row shows "Quads", "Hamstrings", "Glutes", "Calves", "Adductors", "Hip Flexors", "Hip Rotators"

**Step 4: Verify sub-muscle drill-down**

- With "Arms" active, click "Biceps" → list narrows to biceps-only exercises (e.g., Barbell Curl)
- Click "Triceps" → list changes to triceps exercises
- Click "Triceps" again → de-selects, back to all arm exercises

**Step 5: Verify toggle-off behavior**

- With "Arms" active, click "Arms" again → resets to "All Muscles", sub-row collapses
- Click "All Muscles" button → always clears everything

**Step 6: Verify animation**

- Sub-row slides in/out smoothly (200ms transition)
- No layout jump or content flash

**Step 7: Verify "Back" shows Traps label**

- Click "Back" → sub-row includes "Back" and "Traps" (not "Trapezius")
