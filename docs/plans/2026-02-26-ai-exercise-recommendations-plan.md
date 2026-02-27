# AI-Powered Exercise Recommendations Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Gemini-powered exercise recommendations via an AI Copilot Panel, with custom equipment input and saved suggestions.

**Architecture:** Server-side Next.js API route calls Gemini API, returns structured exercise suggestions. A reusable Sheet component (AI Copilot Panel) integrates into both the template builder and exercises page. New database tables/columns support custom equipment and saved suggestions.

**Tech Stack:** Next.js 16 API routes, `@google/generative-ai` SDK, Supabase PostgreSQL, shadcn Sheet component, Vitest

---

### Task 1: Database Migration — Equipment Table Changes

**Files:**
- Create: `supabase/migrations/20260226000001_equipment_custom_fields.sql`

**Step 1: Write the migration**

```sql
-- Add custom equipment support
ALTER TABLE equipment ADD COLUMN is_custom BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE equipment ADD COLUMN created_by UUID REFERENCES profiles(id) ON DELETE CASCADE;

-- Drop the existing unique constraint on name (custom items may duplicate across users)
ALTER TABLE equipment DROP CONSTRAINT IF EXISTS equipment_name_key;

-- Add a unique constraint scoped to non-custom equipment
CREATE UNIQUE INDEX equipment_name_unique_builtin ON equipment (name) WHERE is_custom = false;

-- Update RLS: users can see built-in equipment + their own custom equipment
DROP POLICY IF EXISTS "Equipment is readable by authenticated users" ON equipment;
CREATE POLICY "Equipment is readable by authenticated users"
  ON equipment FOR SELECT TO authenticated
  USING (is_custom = false OR created_by = auth.uid());

-- Users can insert their own custom equipment
CREATE POLICY "Users can create custom equipment"
  ON equipment FOR INSERT TO authenticated
  WITH CHECK (is_custom = true AND created_by = auth.uid());

-- Users can delete their own custom equipment
CREATE POLICY "Users can delete custom equipment"
  ON equipment FOR DELETE TO authenticated
  USING (is_custom = true AND created_by = auth.uid());
```

**Step 2: Apply migration**

Run: `npx supabase db push` (or apply via Supabase dashboard)

**Step 3: Regenerate types**

Run: `npx supabase gen types typescript --project-id <project-id> > src/lib/database.types.ts`

**Step 4: Commit**

```bash
git add supabase/migrations/20260226000001_equipment_custom_fields.sql src/lib/database.types.ts
git commit -m "feat: add custom equipment columns and RLS policies"
```

---

### Task 2: Database Migration — Saved AI Suggestions Table

**Files:**
- Create: `supabase/migrations/20260226000002_saved_ai_suggestions.sql`

**Step 1: Write the migration**

```sql
CREATE TABLE saved_ai_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_name TEXT NOT NULL,
  exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL,
  primary_muscles TEXT[] NOT NULL DEFAULT '{}',
  secondary_muscles TEXT[] NOT NULL DEFAULT '{}',
  suggested_sets INT NOT NULL DEFAULT 3,
  suggested_reps INT NOT NULL DEFAULT 10,
  description TEXT,
  instructions TEXT,
  workout_type TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE saved_ai_suggestions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own saved suggestions"
  ON saved_ai_suggestions FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own saved suggestions"
  ON saved_ai_suggestions FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own saved suggestions"
  ON saved_ai_suggestions FOR DELETE TO authenticated
  USING (user_id = auth.uid());
```

**Step 2: Apply migration**

Run: `npx supabase db push`

**Step 3: Regenerate types**

Run: `npx supabase gen types typescript --project-id <project-id> > src/lib/database.types.ts`

**Step 4: Commit**

```bash
git add supabase/migrations/20260226000002_saved_ai_suggestions.sql src/lib/database.types.ts
git commit -m "feat: add saved_ai_suggestions table with RLS"
```

---

### Task 3: Install Gemini SDK

**Step 1: Install the package**

Run: `npm install @google/generative-ai`

**Step 2: Add env variable**

Add to `.env.local`:
```
GEMINI_API_KEY=your_api_key_here
```

**Step 3: Commit**

```bash
git add package.json package-lock.json
git commit -m "chore: install @google/generative-ai SDK"
```

---

### Task 4: Custom Equipment Server Action

**Files:**
- Modify: `src/lib/actions/equipment.ts`

**Step 1: Write the failing test**

Create: `src/lib/actions/__tests__/equipment.test.ts`

```typescript
import { describe, it, expect } from "vitest";

// Test the validation logic for custom equipment (extracted as a pure function)
import { validateCustomEquipmentInput } from "../equipment";

describe("validateCustomEquipmentInput", () => {
  it("rejects empty name", () => {
    const result = validateCustomEquipmentInput("", "free_weights");
    expect(result).toEqual({ valid: false, error: "Equipment name is required" });
  });

  it("rejects name longer than 100 characters", () => {
    const result = validateCustomEquipmentInput("a".repeat(101), "free_weights");
    expect(result).toEqual({ valid: false, error: "Equipment name must be 100 characters or less" });
  });

  it("rejects invalid category", () => {
    const result = validateCustomEquipmentInput("TRX Bands", "invalid_cat");
    expect(result).toEqual({ valid: false, error: "Invalid equipment category" });
  });

  it("accepts valid input", () => {
    const result = validateCustomEquipmentInput("TRX Bands", "accessories");
    expect(result).toEqual({ valid: true });
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/actions/__tests__/equipment.test.ts`
Expected: FAIL — `validateCustomEquipmentInput` not exported

**Step 3: Add validation function and server action to equipment.ts**

Add to `src/lib/actions/equipment.ts` (after existing exports):

```typescript
const VALID_CATEGORIES = [
  "free_weights", "benches", "racks", "machines", "bodyweight", "accessories",
] as const;

export function validateCustomEquipmentInput(
  name: string,
  category: string
): { valid: boolean; error?: string } {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: "Equipment name is required" };
  }
  if (name.length > 100) {
    return { valid: false, error: "Equipment name must be 100 characters or less" };
  }
  if (!VALID_CATEGORIES.includes(category as (typeof VALID_CATEGORIES)[number])) {
    return { valid: false, error: "Invalid equipment category" };
  }
  return { valid: true };
}

export async function createCustomEquipment(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const name = (formData.get("name") as string).trim();
  const category = formData.get("category") as string;

  const validation = validateCustomEquipmentInput(name, category);
  if (!validation.valid) throw new Error(validation.error);

  const { data, error } = await supabase
    .from("equipment")
    .insert({ name, category, is_custom: true, created_by: user.id })
    .select()
    .single();

  if (error) throw new Error(error.message);

  revalidatePath("/equipment");
  return data;
}
```

**Step 4: Run test to verify it passes**

Run: `npx vitest run src/lib/actions/__tests__/equipment.test.ts`
Expected: PASS

**Step 5: Commit**

```bash
git add src/lib/actions/equipment.ts src/lib/actions/__tests__/equipment.test.ts
git commit -m "feat: add custom equipment creation with validation"
```

---

### Task 5: Custom Equipment UI in Profile Form

**Files:**
- Modify: `src/components/equipment/equipment-profile-form.tsx`

**Step 1: Add custom equipment input section**

At the top of the equipment selection area (before the category groups at line 60), add:

```tsx
// New state for custom equipment input
const [customName, setCustomName] = useState("");
const [customCategory, setCustomCategory] = useState("accessories");
const [newEquipmentIds, setNewEquipmentIds] = useState<string[]>([]);

async function handleAddCustom() {
  const formData = new FormData();
  formData.set("name", customName);
  formData.set("category", customCategory);
  startTransition(async () => {
    const newEquipment = await createCustomEquipment(formData);
    setNewEquipmentIds((prev) => [...prev, newEquipment.id]);
    setCustomName("");
  });
}
```

Add UI above the existing checkbox groups:

```tsx
<div className="space-y-2 border-b pb-4 mb-4">
  <label className="text-sm font-medium">Add Custom Equipment</label>
  <div className="flex gap-2">
    <Input
      placeholder="e.g. TRX Bands"
      value={customName}
      onChange={(e) => setCustomName(e.target.value)}
      className="flex-1"
    />
    <select
      value={customCategory}
      onChange={(e) => setCustomCategory(e.target.value)}
      className="rounded-md border px-2 text-sm"
    >
      {Object.entries(categoryLabels).map(([key, label]) => (
        <option key={key} value={key}>{label}</option>
      ))}
    </select>
    <Button
      type="button"
      size="sm"
      onClick={handleAddCustom}
      disabled={!customName.trim() || isPending}
    >
      Add
    </Button>
  </div>
</div>
```

Hidden inputs for newly created equipment (auto-selected):

```tsx
{newEquipmentIds.map((id) => (
  <input key={id} type="hidden" name="equipment" value={id} />
))}
```

**Step 2: Test manually**

Open the app, go to Equipment, create a profile, type a custom equipment name, select category, click Add. Verify it appears in the checkbox list and is auto-selected.

**Step 3: Commit**

```bash
git add src/components/equipment/equipment-profile-form.tsx
git commit -m "feat: custom equipment input in profile form"
```

---

### Task 6: Gemini API Route — Recommend Exercises

**Files:**
- Create: `src/app/api/ai/recommend-exercises/route.ts`
- Create: `src/lib/ai/gemini.ts`
- Create: `src/lib/ai/prompts.ts`
- Create: `src/lib/ai/types.ts`

**Step 1: Write the failing test for response parsing**

Create: `src/lib/ai/__tests__/gemini.test.ts`

```typescript
import { describe, it, expect } from "vitest";
import { parseGeminiResponse, type GeminiExerciseSuggestion } from "../gemini";

const validResponse: GeminiExerciseSuggestion[] = [
  {
    name: "Barbell Bench Press",
    primaryMuscles: ["Chest"],
    secondaryMuscles: ["Triceps", "Front Delts"],
    suggestedSets: 4,
    suggestedReps: 8,
    description: "A compound chest exercise",
    instructions: "Lie on bench, press barbell up",
  },
];

describe("parseGeminiResponse", () => {
  it("parses valid JSON array", () => {
    const result = parseGeminiResponse(JSON.stringify(validResponse));
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe("Barbell Bench Press");
  });

  it("handles JSON wrapped in markdown code block", () => {
    const wrapped = "```json\n" + JSON.stringify(validResponse) + "\n```";
    const result = parseGeminiResponse(wrapped);
    expect(result).toHaveLength(1);
  });

  it("throws on invalid JSON", () => {
    expect(() => parseGeminiResponse("not json")).toThrow();
  });

  it("throws on empty array", () => {
    expect(() => parseGeminiResponse("[]")).toThrow();
  });

  it("filters out items missing required fields", () => {
    const mixed = [
      validResponse[0],
      { name: "Incomplete" }, // missing primaryMuscles
    ];
    const result = parseGeminiResponse(JSON.stringify(mixed));
    expect(result).toHaveLength(1);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/ai/__tests__/gemini.test.ts`
Expected: FAIL — module not found

**Step 3: Create the types file**

Create: `src/lib/ai/types.ts`

```typescript
export interface GeminiExerciseSuggestion {
  name: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  suggestedSets: number;
  suggestedReps: number;
  description: string;
  instructions: string;
}

export interface ExerciseRecommendation extends GeminiExerciseSuggestion {
  existsInDb: boolean;
  existingExerciseId?: string;
}

export interface RecommendRequest {
  workoutType: string;
  equipment: string[];
  existingExercises?: string[];
}
```

**Step 4: Create the Gemini client and parser**

Create: `src/lib/ai/gemini.ts`

```typescript
import { GoogleGenerativeAI } from "@google/generative-ai";
import type { GeminiExerciseSuggestion } from "./types";

export type { GeminiExerciseSuggestion };

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

export function parseGeminiResponse(text: string): GeminiExerciseSuggestion[] {
  // Strip markdown code block wrapper if present
  let cleaned = text.trim();
  if (cleaned.startsWith("```")) {
    cleaned = cleaned.replace(/^```(?:json)?\n?/, "").replace(/\n?```$/, "");
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    throw new Error("Failed to parse Gemini response as JSON");
  }

  if (!Array.isArray(parsed) || parsed.length === 0) {
    throw new Error("Gemini returned empty or invalid response");
  }

  const valid = parsed.filter(
    (item: Record<string, unknown>) =>
      typeof item.name === "string" &&
      Array.isArray(item.primaryMuscles) &&
      item.primaryMuscles.length > 0
  ) as GeminiExerciseSuggestion[];

  if (valid.length === 0) {
    throw new Error("No valid exercises in Gemini response");
  }

  return valid;
}

export async function generateExerciseRecommendations(
  systemPrompt: string,
  userPrompt: string
): Promise<GeminiExerciseSuggestion[]> {
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: userPrompt }] }],
    systemInstruction: { role: "model", parts: [{ text: systemPrompt }] },
  });

  const text = result.response.text();
  return parseGeminiResponse(text);
}
```

**Step 5: Create the prompt builder**

Create: `src/lib/ai/prompts.ts`

```typescript
export function buildSystemPrompt(): string {
  return `You are a fitness exercise recommendation engine. You MUST respond with ONLY a valid JSON array of exercise objects. No additional text, explanations, or markdown.

Each exercise object must have these exact fields:
- "name": string - the exercise name
- "primaryMuscles": string[] - primary muscles targeted (use these exact names: Chest, Triceps, Biceps, Forearms, Front Delts, Side Delts, Rear Delts, Lats, Upper Back, Lower Back, Quads, Hamstrings, Glutes, Calves, Abs)
- "secondaryMuscles": string[] - secondary muscles targeted (same names as above)
- "suggestedSets": number - recommended number of sets (typically 3-5)
- "suggestedReps": number - recommended reps per set (typically 6-15)
- "description": string - one sentence describing the exercise
- "instructions": string - brief form instructions (2-3 sentences)

Return exactly 6-8 exercises. Only recommend exercises that can be performed with the available equipment listed.`;
}

export function buildUserPrompt(
  workoutType: string,
  equipment: string[],
  existingExercises: string[]
): string {
  let prompt = `Recommend exercises for a ${workoutType} workout.\n\n`;
  prompt += `Available equipment: ${equipment.length > 0 ? equipment.join(", ") : "Bodyweight only (no equipment)"}\n\n`;

  if (existingExercises.length > 0) {
    prompt += `Exclude these exercises (already in the workout): ${existingExercises.join(", ")}\n`;
  }

  return prompt;
}
```

**Step 6: Run tests to verify they pass**

Run: `npx vitest run src/lib/ai/__tests__/gemini.test.ts`
Expected: PASS

**Step 7: Create the API route**

Create: `src/app/api/ai/recommend-exercises/route.ts`

```typescript
import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { generateExerciseRecommendations } from "@/lib/ai/gemini";
import { buildSystemPrompt, buildUserPrompt } from "@/lib/ai/prompts";
import type { ExerciseRecommendation, RecommendRequest } from "@/lib/ai/types";

// Simple in-memory rate limiter
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(userId: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(userId);

  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(userId, { count: 1, resetAt: now + 60_000 });
    return true;
  }

  if (entry.count >= 10) return false;
  entry.count++;
  return true;
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    if (!checkRateLimit(user.id)) {
      return NextResponse.json(
        { error: "Too many requests. Please wait a minute." },
        { status: 429 }
      );
    }

    const body = (await request.json()) as RecommendRequest;

    if (!body.workoutType || !Array.isArray(body.equipment)) {
      return NextResponse.json(
        { error: "workoutType and equipment are required" },
        { status: 400 }
      );
    }

    const systemPrompt = buildSystemPrompt();
    const userPrompt = buildUserPrompt(
      body.workoutType,
      body.equipment,
      body.existingExercises ?? []
    );

    const suggestions = await generateExerciseRecommendations(systemPrompt, userPrompt);

    // Fuzzy match against existing exercises in DB
    const { data: dbExercises } = await supabase
      .from("exercises")
      .select("id, name")
      .or(`is_custom.eq.false,created_by.eq.${user.id}`);

    const recommendations: ExerciseRecommendation[] = suggestions.map((s) => {
      const match = dbExercises?.find(
        (e) => e.name.toLowerCase() === s.name.toLowerCase()
      );
      return {
        ...s,
        existsInDb: !!match,
        existingExerciseId: match?.id,
      };
    });

    return NextResponse.json({ recommendations });
  } catch (error) {
    console.error("AI recommendation error:", error);
    return NextResponse.json(
      { error: "Failed to generate recommendations. Please try again." },
      { status: 500 }
    );
  }
}
```

**Step 8: Commit**

```bash
git add src/lib/ai/ src/app/api/ai/
git commit -m "feat: Gemini API route for exercise recommendations"
```

---

### Task 7: Create Custom Exercise Server Action

**Files:**
- Create: `src/lib/actions/ai.ts`

**Step 1: Write the failing test for muscle name normalization**

Create: `src/lib/actions/__tests__/ai.test.ts`

```typescript
import { describe, it, expect } from "vitest";
import { normalizeMuscleNames } from "../ai";

// These are the exact muscle names in the database
const DB_MUSCLES = [
  "Chest", "Triceps", "Biceps", "Forearms",
  "Front Delts", "Side Delts", "Rear Delts",
  "Lats", "Upper Back", "Lower Back",
  "Quads", "Hamstrings", "Glutes", "Calves", "Abs",
];

describe("normalizeMuscleNames", () => {
  it("returns exact matches unchanged", () => {
    expect(normalizeMuscleNames(["Chest", "Triceps"], DB_MUSCLES))
      .toEqual(["Chest", "Triceps"]);
  });

  it("matches case-insensitively", () => {
    expect(normalizeMuscleNames(["chest", "TRICEPS"], DB_MUSCLES))
      .toEqual(["Chest", "Triceps"]);
  });

  it("drops unmatched names", () => {
    expect(normalizeMuscleNames(["Chest", "Serratus Anterior"], DB_MUSCLES))
      .toEqual(["Chest"]);
  });

  it("returns empty array for all unmatched", () => {
    expect(normalizeMuscleNames(["Rotator Cuff"], DB_MUSCLES))
      .toEqual([]);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/actions/__tests__/ai.test.ts`
Expected: FAIL

**Step 3: Implement the server action**

Create: `src/lib/actions/ai.ts`

```typescript
"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type { GeminiExerciseSuggestion } from "@/lib/ai/types";

export function normalizeMuscleNames(
  names: string[],
  dbMuscleNames: string[]
): string[] {
  return names
    .map((name) =>
      dbMuscleNames.find((db) => db.toLowerCase() === name.toLowerCase())
    )
    .filter((n): n is string => n !== undefined);
}

export async function createExerciseFromSuggestion(
  suggestion: GeminiExerciseSuggestion,
  equipmentNames: string[]
) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  // Create the exercise
  const { data: exercise, error: exerciseError } = await supabase
    .from("exercises")
    .insert({
      name: suggestion.name,
      description: suggestion.description,
      instructions: suggestion.instructions,
      is_custom: true,
      created_by: user.id,
    })
    .select()
    .single();

  if (exerciseError) throw new Error(exerciseError.message);

  // Get muscle IDs
  const { data: muscles } = await supabase.from("muscles").select("id, name");
  if (muscles) {
    const dbMuscleNames = muscles.map((m) => m.name);
    const primaryMatched = normalizeMuscleNames(suggestion.primaryMuscles, dbMuscleNames);
    const secondaryMatched = normalizeMuscleNames(suggestion.secondaryMuscles, dbMuscleNames);

    const muscleRows = [
      ...primaryMatched.map((name) => ({
        exercise_id: exercise.id,
        muscle_id: muscles.find((m) => m.name === name)!.id,
        role: "primary" as const,
      })),
      ...secondaryMatched.map((name) => ({
        exercise_id: exercise.id,
        muscle_id: muscles.find((m) => m.name === name)!.id,
        role: "secondary" as const,
      })),
    ];

    if (muscleRows.length > 0) {
      await supabase.from("exercise_muscles").insert(muscleRows);
    }
  }

  // Link to equipment
  const { data: equipment } = await supabase
    .from("equipment")
    .select("id, name")
    .or(`is_custom.eq.false,created_by.eq.${user.id}`);

  if (equipment) {
    const equipmentRows = equipmentNames
      .map((name) => equipment.find((e) => e.name.toLowerCase() === name.toLowerCase()))
      .filter((e): e is NonNullable<typeof e> => e !== undefined)
      .map((e) => ({ exercise_id: exercise.id, equipment_id: e.id }));

    if (equipmentRows.length > 0) {
      await supabase.from("exercise_equipment").insert(equipmentRows);
    }
  }

  revalidatePath("/exercises");
  return exercise;
}
```

**Step 4: Run tests to verify they pass**

Run: `npx vitest run src/lib/actions/__tests__/ai.test.ts`
Expected: PASS

**Step 5: Commit**

```bash
git add src/lib/actions/ai.ts src/lib/actions/__tests__/ai.test.ts
git commit -m "feat: server action to create exercise from AI suggestion"
```

---

### Task 8: Saved Suggestions Server Actions

**Files:**
- Modify: `src/lib/actions/ai.ts`

**Step 1: Add saved suggestion actions to ai.ts**

Append to `src/lib/actions/ai.ts`:

```typescript
export async function saveSuggestion(
  suggestion: GeminiExerciseSuggestion & {
    existingExerciseId?: string;
    workoutType: string;
  }
) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { error } = await supabase.from("saved_ai_suggestions").insert({
    user_id: user.id,
    exercise_name: suggestion.name,
    exercise_id: suggestion.existingExerciseId ?? null,
    primary_muscles: suggestion.primaryMuscles,
    secondary_muscles: suggestion.secondaryMuscles,
    suggested_sets: suggestion.suggestedSets,
    suggested_reps: suggestion.suggestedReps,
    description: suggestion.description,
    instructions: suggestion.instructions,
    workout_type: suggestion.workoutType,
  });

  if (error) throw new Error(error.message);
}

export async function getSavedSuggestions() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("saved_ai_suggestions")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) throw new Error(error.message);
  return data;
}

export async function deleteSavedSuggestion(id: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("saved_ai_suggestions")
    .delete()
    .eq("id", id);

  if (error) throw new Error(error.message);
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/ai.ts
git commit -m "feat: saved AI suggestion CRUD actions"
```

---

### Task 9: AI Copilot Panel Component

**Files:**
- Create: `src/components/ai/ai-copilot-panel.tsx`
- Create: `src/components/ai/workout-type-selector.tsx`
- Create: `src/components/ai/suggestion-card.tsx`
- Create: `src/components/ai/saved-suggestions-tab.tsx`

**Step 1: Create workout type selector**

Create: `src/components/ai/workout-type-selector.tsx`

```tsx
"use client";

import { useState } from "react";
import { Input } from "@/components/ui/input";

const WORKOUT_TYPES = [
  "Push", "Pull", "Legs", "Upper", "Lower", "Full Body", "Arms", "Core",
] as const;

interface WorkoutTypeSelectorProps {
  value: string;
  onChange: (value: string) => void;
}

export function WorkoutTypeSelector({ value, onChange }: WorkoutTypeSelectorProps) {
  const [isCustom, setIsCustom] = useState(false);

  return (
    <div className="space-y-2">
      <label className="text-sm font-medium">Workout Type</label>
      <div className="flex flex-wrap gap-2">
        {WORKOUT_TYPES.map((type) => (
          <button
            key={type}
            type="button"
            onClick={() => { setIsCustom(false); onChange(type); }}
            className={`rounded-full px-3 py-1 text-sm border transition-colors ${
              !isCustom && value === type
                ? "bg-primary text-primary-foreground border-primary"
                : "bg-muted hover:bg-muted/80 border-transparent"
            }`}
          >
            {type}
          </button>
        ))}
        <button
          type="button"
          onClick={() => { setIsCustom(true); onChange(""); }}
          className={`rounded-full px-3 py-1 text-sm border transition-colors ${
            isCustom
              ? "bg-primary text-primary-foreground border-primary"
              : "bg-muted hover:bg-muted/80 border-transparent"
          }`}
        >
          Custom
        </button>
      </div>
      {isCustom && (
        <Input
          placeholder="e.g. chest and triceps hypertrophy"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="mt-2"
        />
      )}
    </div>
  );
}
```

**Step 2: Create suggestion card**

Create: `src/components/ai/suggestion-card.tsx`

```tsx
"use client";

import { Bookmark, Plus, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import type { ExerciseRecommendation } from "@/lib/ai/types";

interface SuggestionCardProps {
  suggestion: ExerciseRecommendation;
  isAdded: boolean;
  isSaved: boolean;
  onAdd: () => void;
  onSave: () => void;
}

export function SuggestionCard({
  suggestion,
  isAdded,
  isSaved,
  onAdd,
  onSave,
}: SuggestionCardProps) {
  return (
    <div className="rounded-lg border p-3 space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div>
          <span className={suggestion.existsInDb ? "font-semibold" : "italic"}>
            {suggestion.name}
          </span>
          {!suggestion.existsInDb && (
            <Badge variant="outline" className="ml-2 text-xs">New</Badge>
          )}
        </div>
        <div className="flex gap-1 shrink-0">
          <Button
            size="icon"
            variant="ghost"
            onClick={onSave}
            className={isSaved ? "text-primary" : ""}
          >
            <Bookmark className={`h-4 w-4 ${isSaved ? "fill-current" : ""}`} />
          </Button>
          <Button
            size="sm"
            variant={isAdded ? "ghost" : "default"}
            onClick={onAdd}
            disabled={isAdded}
          >
            {isAdded ? <><Check className="h-4 w-4 mr-1" /> Added</> : <><Plus className="h-4 w-4 mr-1" /> Add</>}
          </Button>
        </div>
      </div>
      <div className="flex flex-wrap gap-1">
        {suggestion.primaryMuscles.map((m) => (
          <Badge key={m} variant="default" className="text-xs">{m}</Badge>
        ))}
        {suggestion.secondaryMuscles.map((m) => (
          <Badge key={m} variant="secondary" className="text-xs">{m}</Badge>
        ))}
      </div>
      <p className="text-xs text-muted-foreground">
        {suggestion.suggestedSets} sets x {suggestion.suggestedReps} reps
      </p>
      <p className="text-xs text-muted-foreground">{suggestion.description}</p>
    </div>
  );
}
```

**Step 3: Create saved suggestions tab**

Create: `src/components/ai/saved-suggestions-tab.tsx`

```tsx
"use client";

import { useEffect, useState, useTransition } from "react";
import { Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getSavedSuggestions, deleteSavedSuggestion } from "@/lib/actions/ai";

interface SavedSuggestion {
  id: string;
  exercise_name: string;
  primary_muscles: string[];
  secondary_muscles: string[];
  suggested_sets: number;
  suggested_reps: number;
  description: string | null;
  workout_type: string;
  exercise_id: string | null;
}

interface SavedSuggestionsTabProps {
  onAdd: (suggestion: SavedSuggestion) => void;
  addedIds: Set<string>;
}

export function SavedSuggestionsTab({ onAdd, addedIds }: SavedSuggestionsTabProps) {
  const [suggestions, setSuggestions] = useState<SavedSuggestion[]>([]);
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    getSavedSuggestions().then(setSuggestions);
  }, []);

  function handleDelete(id: string) {
    startTransition(async () => {
      await deleteSavedSuggestion(id);
      setSuggestions((prev) => prev.filter((s) => s.id !== id));
    });
  }

  if (suggestions.length === 0) {
    return (
      <p className="text-sm text-muted-foreground text-center py-8">
        No saved suggestions yet. Generate recommendations and bookmark the ones you like.
      </p>
    );
  }

  return (
    <div className="space-y-3">
      {suggestions.map((s) => (
        <div key={s.id} className="rounded-lg border p-3 space-y-2">
          <div className="flex items-start justify-between gap-2">
            <div>
              <span className="font-semibold">{s.exercise_name}</span>
              <Badge variant="outline" className="ml-2 text-xs">{s.workout_type}</Badge>
            </div>
            <div className="flex gap-1 shrink-0">
              <Button
                size="sm"
                variant="default"
                onClick={() => onAdd(s)}
                disabled={addedIds.has(s.id)}
              >
                {addedIds.has(s.id) ? "Added" : "Add"}
              </Button>
              <Button
                size="icon"
                variant="ghost"
                onClick={() => handleDelete(s.id)}
                disabled={isPending}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          </div>
          <div className="flex flex-wrap gap-1">
            {s.primary_muscles.map((m) => (
              <Badge key={m} variant="default" className="text-xs">{m}</Badge>
            ))}
            {s.secondary_muscles.map((m) => (
              <Badge key={m} variant="secondary" className="text-xs">{m}</Badge>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            {s.suggested_sets} sets x {s.suggested_reps} reps
          </p>
        </div>
      ))}
    </div>
  );
}
```

**Step 4: Create the main AI Copilot Panel**

Create: `src/components/ai/ai-copilot-panel.tsx`

```tsx
"use client";

import { useState, useTransition } from "react";
import { Sparkles, Loader2, RefreshCw } from "lucide-react";
import {
  Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { WorkoutTypeSelector } from "./workout-type-selector";
import { SuggestionCard } from "./suggestion-card";
import { SavedSuggestionsTab } from "./saved-suggestions-tab";
import { saveSuggestion, createExerciseFromSuggestion } from "@/lib/actions/ai";
import { addExerciseToTemplate } from "@/lib/actions/templates";
import type { ExerciseRecommendation } from "@/lib/ai/types";

interface AICopilotPanelProps {
  equipmentProfileName: string | null;
  equipmentNames: string[];
  // Template context (optional — if provided, "Add" inserts into template)
  templateId?: string;
  existingExerciseNames?: string[];
  nextOrderIndex?: number;
}

export function AICopilotPanel({
  equipmentProfileName,
  equipmentNames,
  templateId,
  existingExerciseNames = [],
  nextOrderIndex = 0,
}: AICopilotPanelProps) {
  const [open, setOpen] = useState(false);
  const [tab, setTab] = useState<"generate" | "saved">("generate");
  const [workoutType, setWorkoutType] = useState("");
  const [recommendations, setRecommendations] = useState<ExerciseRecommendation[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [addedIds, setAddedIds] = useState<Set<string>>(new Set());
  const [savedNames, setSavedNames] = useState<Set<string>>(new Set());
  const [isPending, startTransition] = useTransition();
  const [orderCounter, setOrderCounter] = useState(nextOrderIndex);

  async function handleGenerate() {
    setError(null);
    startTransition(async () => {
      try {
        const res = await fetch("/api/ai/recommend-exercises", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            workoutType,
            equipment: equipmentNames,
            existingExercises: existingExerciseNames,
          }),
        });

        if (!res.ok) {
          const data = await res.json();
          setError(data.error || "Failed to generate recommendations");
          return;
        }

        const data = await res.json();
        setRecommendations(data.recommendations);
        setAddedIds(new Set());
      } catch {
        setError("Failed to connect. Please try again.");
      }
    });
  }

  async function handleAdd(rec: ExerciseRecommendation) {
    startTransition(async () => {
      let exerciseId = rec.existingExerciseId;

      if (!rec.existsInDb) {
        const newExercise = await createExerciseFromSuggestion(rec, equipmentNames);
        exerciseId = newExercise.id;
      }

      if (templateId && exerciseId) {
        await addExerciseToTemplate(templateId, exerciseId, orderCounter);
        setOrderCounter((c) => c + 1);
      }

      setAddedIds((prev) => new Set(prev).add(rec.name));
    });
  }

  async function handleSave(rec: ExerciseRecommendation) {
    startTransition(async () => {
      await saveSuggestion({
        ...rec,
        existingExerciseId: rec.existingExerciseId,
        workoutType,
      });
      setSavedNames((prev) => new Set(prev).add(rec.name));
    });
  }

  async function handleAddFromSaved(saved: {
    exercise_name: string;
    exercise_id: string | null;
    primary_muscles: string[];
    secondary_muscles: string[];
    suggested_sets: number;
    suggested_reps: number;
    description: string | null;
  }) {
    startTransition(async () => {
      let exerciseId = saved.exercise_id;

      if (!exerciseId) {
        const newExercise = await createExerciseFromSuggestion(
          {
            name: saved.exercise_name,
            primaryMuscles: saved.primary_muscles,
            secondaryMuscles: saved.secondary_muscles,
            suggestedSets: saved.suggested_sets,
            suggestedReps: saved.suggested_reps,
            description: saved.description ?? "",
            instructions: "",
          },
          equipmentNames
        );
        exerciseId = newExercise.id;
      }

      if (templateId && exerciseId) {
        await addExerciseToTemplate(templateId, exerciseId, orderCounter);
        setOrderCounter((c) => c + 1);
      }

      setAddedIds((prev) => new Set(prev).add(saved.exercise_name));
    });
  }

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="outline" size="sm">
          <Sparkles className="h-4 w-4 mr-2" />
          AI Suggest
        </Button>
      </SheetTrigger>
      <SheetContent className="w-full sm:max-w-lg overflow-y-auto">
        <SheetHeader>
          <SheetTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5" />
            AI Exercise Recommendations
          </SheetTitle>
        </SheetHeader>

        {/* Tabs */}
        <div className="flex gap-2 mt-4 border-b pb-2">
          <button
            onClick={() => setTab("generate")}
            className={`text-sm font-medium pb-1 border-b-2 transition-colors ${
              tab === "generate" ? "border-primary text-primary" : "border-transparent text-muted-foreground"
            }`}
          >
            Generate
          </button>
          <button
            onClick={() => setTab("saved")}
            className={`text-sm font-medium pb-1 border-b-2 transition-colors ${
              tab === "saved" ? "border-primary text-primary" : "border-transparent text-muted-foreground"
            }`}
          >
            Saved
          </button>
        </div>

        {tab === "generate" ? (
          <div className="space-y-4 mt-4">
            <WorkoutTypeSelector value={workoutType} onChange={setWorkoutType} />

            {/* Equipment context */}
            <div className="text-sm">
              <span className="text-muted-foreground">Equipment: </span>
              {equipmentProfileName ? (
                <span className="font-medium">{equipmentProfileName}</span>
              ) : (
                <span className="text-destructive">
                  No active profile.{" "}
                  <a href="/equipment" className="underline">Set one up</a>
                </span>
              )}
            </div>

            {/* Generate button */}
            <Button
              onClick={handleGenerate}
              disabled={!workoutType || isPending}
              className="w-full"
            >
              {isPending ? (
                <><Loader2 className="h-4 w-4 mr-2 animate-spin" /> Generating...</>
              ) : (
                "Generate Recommendations"
              )}
            </Button>

            {/* Error */}
            {error && (
              <div className="rounded-lg bg-destructive/10 text-destructive text-sm p-3">
                {error}
              </div>
            )}

            {/* Results */}
            {recommendations.length > 0 && (
              <div className="space-y-3">
                {recommendations.map((rec) => (
                  <SuggestionCard
                    key={rec.name}
                    suggestion={rec}
                    isAdded={addedIds.has(rec.name)}
                    isSaved={savedNames.has(rec.name)}
                    onAdd={() => handleAdd(rec)}
                    onSave={() => handleSave(rec)}
                  />
                ))}
                <Button
                  variant="outline"
                  onClick={handleGenerate}
                  disabled={isPending}
                  className="w-full"
                >
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Regenerate
                </Button>
              </div>
            )}
          </div>
        ) : (
          <div className="mt-4">
            <SavedSuggestionsTab
              onAdd={handleAddFromSaved}
              addedIds={addedIds}
            />
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}
```

**Step 5: Commit**

```bash
git add src/components/ai/
git commit -m "feat: AI Copilot Panel components"
```

---

### Task 10: Integrate Panel into Template Builder

**Files:**
- Modify: `src/app/(app)/workouts/[id]/client.tsx` (line ~122)
- Modify: `src/app/(app)/workouts/[id]/page.tsx` (to pass equipment data)

**Step 1: Update server component to fetch equipment profile**

In `src/app/(app)/workouts/[id]/page.tsx`, add equipment profile fetching alongside the existing data:

```typescript
import { getEquipmentProfiles } from "@/lib/actions/equipment";

// Inside the component, after existing data fetching:
const profiles = await getEquipmentProfiles();
const activeProfile = profiles.find((p) => p.is_active);
const equipmentNames = activeProfile
  ? activeProfile.equipment_profile_items.map(
      (item: { equipment: { name: string } }) => item.equipment.name
    )
  : [];
```

Pass to client:

```tsx
<TemplateDetailClient
  template={template}
  allExercises={allExercises}
  equipmentProfileName={activeProfile?.name ?? null}
  equipmentNames={equipmentNames}
/>
```

**Step 2: Add AI panel to client component**

In `src/app/(app)/workouts/[id]/client.tsx`, import and place the panel near the AddExerciseDialog (around line 122):

```tsx
import { AICopilotPanel } from "@/components/ai/ai-copilot-panel";

// In the JSX, next to existing AddExerciseDialog:
<AICopilotPanel
  equipmentProfileName={equipmentProfileName}
  equipmentNames={equipmentNames}
  templateId={template.id}
  existingExerciseNames={template.template_exercises.map(
    (te) => te.exercise.name
  )}
  nextOrderIndex={template.template_exercises.length}
/>
```

**Step 3: Test manually**

Open a template, click "AI Suggest", pick a workout type, generate. Verify exercises appear and "Add" inserts them into the template.

**Step 4: Commit**

```bash
git add src/app/(app)/workouts/[id]/
git commit -m "feat: integrate AI Copilot Panel into template builder"
```

---

### Task 11: Integrate Panel into Exercises Page

**Files:**
- Modify: `src/app/(app)/exercises/page.tsx`
- Modify: `src/app/(app)/exercises/client.tsx`

**Step 1: Update server component to fetch equipment data**

In `src/app/(app)/exercises/page.tsx`, fetch the active equipment profile:

```typescript
import { getEquipmentProfiles } from "@/lib/actions/equipment";

const profiles = await getEquipmentProfiles();
const activeProfile = profiles.find((p) => p.is_active);
const equipmentNames = activeProfile
  ? activeProfile.equipment_profile_items.map(
      (item: { equipment: { name: string } }) => item.equipment.name
    )
  : [];
```

Pass to client component.

**Step 2: Add AI panel to client component toolbar**

In `src/app/(app)/exercises/client.tsx`, add the AICopilotPanel alongside the existing filter bar:

```tsx
import { AICopilotPanel } from "@/components/ai/ai-copilot-panel";

// In the toolbar area:
<AICopilotPanel
  equipmentProfileName={equipmentProfileName}
  equipmentNames={equipmentNames}
/>
```

Note: No `templateId` is passed here — the panel works in standalone mode (no "Add to template" integration, just browsing).

**Step 3: Test manually**

Open Exercises page, click "AI Suggest", generate recommendations. Verify panel works without template context.

**Step 4: Commit**

```bash
git add src/app/(app)/exercises/
git commit -m "feat: integrate AI Copilot Panel into exercises page"
```

---

### Task 12: E2E Tests

**Files:**
- Create: `tests/e2e/ai-copilot.spec.ts`

**Step 1: Write E2E tests**

```typescript
import { test, expect } from "@playwright/test";

test.describe("AI Copilot Panel", () => {
  test.beforeEach(async ({ page }) => {
    // Login flow — adjust based on existing e2e test patterns
    await page.goto("/login");
    await page.fill('[name="email"]', process.env.TEST_EMAIL!);
    await page.fill('[name="password"]', process.env.TEST_PASSWORD!);
    await page.click('button[type="submit"]');
    await page.waitForURL("**/");
  });

  test("opens panel from exercises page and generates suggestions", async ({ page }) => {
    await page.goto("/exercises");
    await page.click("text=AI Suggest");
    await expect(page.locator("text=AI Exercise Recommendations")).toBeVisible();
    await page.click("text=Push");
    await page.click("text=Generate Recommendations");
    // Wait for results (may take a few seconds for Gemini API)
    await expect(page.locator('[class*="suggestion"]').first()).toBeVisible({ timeout: 20000 });
  });

  test("opens panel from template builder", async ({ page }) => {
    await page.goto("/workouts");
    // Click first template
    await page.locator('[data-testid="template-card"]').first().click();
    await page.click("text=AI Suggest");
    await expect(page.locator("text=AI Exercise Recommendations")).toBeVisible();
  });
});
```

**Step 2: Run E2E tests**

Run: `npx playwright test tests/e2e/ai-copilot.spec.ts`

**Step 3: Commit**

```bash
git add tests/e2e/ai-copilot.spec.ts
git commit -m "test: E2E tests for AI Copilot Panel"
```

---

### Task 13: Final Verification & Cleanup

**Step 1: Run all unit tests**

Run: `npx vitest run`
Expected: All pass

**Step 2: Run lint**

Run: `npm run lint`
Expected: No errors

**Step 3: Run build**

Run: `npm run build`
Expected: Build succeeds

**Step 4: Final commit if any cleanup needed**

```bash
git add -A
git commit -m "chore: cleanup and lint fixes"
```
