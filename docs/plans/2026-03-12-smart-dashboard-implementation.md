# Smart Dashboard Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add server-computed volume tracking and workout recommendations to the dashboard, so users know what to train today and whether their weekly volume is on track.

**Architecture:** A volume analysis utility computes weekly sets per muscle group from existing session data, compares against goal-based presets. A recommendation engine scores templates by staleness, volume gap coverage, and rotation fit. Both feed into enhanced dashboard components.

**Tech Stack:** Next.js 16 Server Components, Drizzle ORM (Neon), Vitest, Tailwind CSS, shadcn/ui

---

### Task 1: Add `trainingGoal` column to profiles schema

**Files:**
- Modify: `src/lib/db/schema.ts:17-27`

**Step 1: Add the column to the schema**

In `src/lib/db/schema.ts`, add the `trainingGoal` column to the `profiles` table:

```typescript
export const profiles = pgTable("profiles", {
  id: uuid("id").primaryKey(),
  displayName: text("display_name"),
  avatarUrl: text("avatar_url"),
  preferredUnits: text("preferred_units").notNull().default("lbs"),
  trainingGoal: text("training_goal").notNull().default("hypertrophy"),
  overloadSessionsThreshold: integer("overload_sessions_threshold").notNull().default(3),
  overloadIncrementLbs: numeric("overload_increment_lbs").notNull().default("5"),
  overloadIncrementKg: numeric("overload_increment_kg").notNull().default("2.5"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});
```

**Step 2: Generate and apply migration**

Run: `npx drizzle-kit generate`

Then apply via Drizzle push or migration:

Run: `npx drizzle-kit push`

Expected: Column `training_goal` added to `profiles` table with default `"hypertrophy"`.

**Step 3: Commit**

```bash
git add src/lib/db/schema.ts drizzle/
git commit -m "feat: add training_goal column to profiles schema"
```

---

### Task 2: Create volume target presets

**Files:**
- Create: `src/lib/volume-targets.ts`
- Create: `src/lib/utils/__tests__/volume-targets.test.ts`

**Step 1: Write the failing test**

Create `src/lib/utils/__tests__/volume-targets.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import {
  getVolumeTargets,
  type TrainingGoal,
  MUSCLE_GROUPS,
} from "@/lib/volume-targets";

describe("getVolumeTargets", () => {
  it("returns targets for every muscle group for hypertrophy", () => {
    const targets = getVolumeTargets("hypertrophy");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
      expect(targets[muscle].min).toBeGreaterThan(0);
      expect(targets[muscle].max).toBeGreaterThan(targets[muscle].min);
    }
  });

  it("returns targets for every muscle group for strength", () => {
    const targets = getVolumeTargets("strength");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
    }
  });

  it("returns targets for every muscle group for endurance", () => {
    const targets = getVolumeTargets("endurance");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
    }
  });

  it("strength targets are lower than hypertrophy targets", () => {
    const strength = getVolumeTargets("strength");
    const hypertrophy = getVolumeTargets("hypertrophy");
    // Check a representative muscle
    expect(strength["chest"].min).toBeLessThan(hypertrophy["chest"].min);
  });

  it("endurance targets are higher than hypertrophy targets", () => {
    const endurance = getVolumeTargets("endurance");
    const hypertrophy = getVolumeTargets("hypertrophy");
    expect(endurance["chest"].min).toBeGreaterThan(hypertrophy["chest"].min);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/utils/__tests__/volume-targets.test.ts`

Expected: FAIL — module `@/lib/volume-targets` not found.

**Step 3: Write the implementation**

Create `src/lib/volume-targets.ts`:

```typescript
export const TRAINING_GOALS = ["hypertrophy", "strength", "endurance"] as const;
export type TrainingGoal = (typeof TRAINING_GOALS)[number];

// Broad muscle groups matching the muscles table's muscle_group column
export const MUSCLE_GROUPS = [
  "chest",
  "back",
  "shoulders",
  "arms",
  "legs",
  "core",
] as const;
export type MuscleGroup = (typeof MUSCLE_GROUPS)[number];

export type VolumeTarget = { min: number; max: number };
export type VolumeTargetMap = Record<MuscleGroup, VolumeTarget>;

// Evidence-based weekly set ranges per muscle group per goal
// Sources: Schoenfeld et al., Israetel's RP recommendations
const VOLUME_PRESETS: Record<TrainingGoal, VolumeTargetMap> = {
  hypertrophy: {
    chest: { min: 10, max: 20 },
    back: { min: 12, max: 22 },
    shoulders: { min: 10, max: 20 },
    arms: { min: 10, max: 20 },
    legs: { min: 12, max: 22 },
    core: { min: 8, max: 16 },
  },
  strength: {
    chest: { min: 6, max: 12 },
    back: { min: 8, max: 15 },
    shoulders: { min: 6, max: 12 },
    arms: { min: 6, max: 12 },
    legs: { min: 8, max: 15 },
    core: { min: 4, max: 10 },
  },
  endurance: {
    chest: { min: 15, max: 25 },
    back: { min: 15, max: 25 },
    shoulders: { min: 15, max: 25 },
    arms: { min: 15, max: 25 },
    legs: { min: 15, max: 25 },
    core: { min: 12, max: 20 },
  },
};

export function getVolumeTargets(goal: TrainingGoal): VolumeTargetMap {
  return VOLUME_PRESETS[goal];
}
```

**Step 4: Run test to verify it passes**

Run: `npx vitest run src/lib/utils/__tests__/volume-targets.test.ts`

Expected: All 5 tests PASS.

**Step 5: Commit**

```bash
git add src/lib/volume-targets.ts src/lib/utils/__tests__/volume-targets.test.ts
git commit -m "feat: add volume target presets for training goals"
```

---

### Task 3: Create volume analysis engine

**Files:**
- Create: `src/lib/volume-analysis.ts`
- Create: `src/lib/utils/__tests__/volume-analysis.test.ts`

**Step 1: Write the failing test**

Create `src/lib/utils/__tests__/volume-analysis.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import {
  computeVolumeStatus,
  type SessionSetWithMuscles,
  type MuscleVolumeStatus,
} from "@/lib/volume-analysis";
import { type VolumeTargetMap } from "@/lib/volume-targets";

const mockTargets: VolumeTargetMap = {
  chest: { min: 10, max: 20 },
  back: { min: 12, max: 22 },
  shoulders: { min: 10, max: 20 },
  arms: { min: 10, max: 20 },
  legs: { min: 12, max: 22 },
  core: { min: 8, max: 16 },
};

function makeSets(
  muscles: { group: string; role: "primary" | "secondary" }[],
  count: number
): SessionSetWithMuscles[] {
  return Array.from({ length: count }, () => ({
    muscles: muscles.map((m) => ({ muscleGroup: m.group, role: m.role })),
  }));
}

describe("computeVolumeStatus", () => {
  it("returns under status when no sets logged", () => {
    const result = computeVolumeStatus([], mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest).toBeDefined();
    expect(chest!.currentSets).toBe(0);
    expect(chest!.status).toBe("under");
  });

  it("counts primary muscles as 1 set each", () => {
    const sets = makeSets([{ group: "chest", role: "primary" }], 12);
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest!.currentSets).toBe(12);
    expect(chest!.status).toBe("optimal");
  });

  it("counts secondary muscles as 0.5 sets each", () => {
    const sets = makeSets([{ group: "arms", role: "secondary" }], 10);
    const result = computeVolumeStatus(sets, mockTargets);
    const arms = result.find((r) => r.muscleGroup === "arms");
    expect(arms!.currentSets).toBe(5);
    expect(arms!.status).toBe("under");
  });

  it("returns over status when exceeding max", () => {
    const sets = makeSets([{ group: "core", role: "primary" }], 20);
    const result = computeVolumeStatus(sets, mockTargets);
    const core = result.find((r) => r.muscleGroup === "core");
    expect(core!.currentSets).toBe(20);
    expect(core!.status).toBe("over");
  });

  it("returns optimal status when within range", () => {
    const sets = makeSets([{ group: "chest", role: "primary" }], 15);
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest!.status).toBe("optimal");
  });

  it("handles mixed primary and secondary muscles per set", () => {
    const sets = makeSets(
      [
        { group: "chest", role: "primary" },
        { group: "arms", role: "secondary" },
      ],
      20
    );
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    const arms = result.find((r) => r.muscleGroup === "arms");
    expect(chest!.currentSets).toBe(20);
    expect(arms!.currentSets).toBe(10);
  });

  it("returns a status for every muscle group in targets", () => {
    const result = computeVolumeStatus([], mockTargets);
    expect(result).toHaveLength(6);
    const groups = result.map((r) => r.muscleGroup);
    expect(groups).toContain("chest");
    expect(groups).toContain("back");
    expect(groups).toContain("legs");
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/utils/__tests__/volume-analysis.test.ts`

Expected: FAIL — module `@/lib/volume-analysis` not found.

**Step 3: Write the implementation**

Create `src/lib/volume-analysis.ts`:

```typescript
import { type VolumeTargetMap } from "@/lib/volume-targets";
import { type MuscleGroup, MUSCLE_GROUPS } from "@/lib/volume-targets";

export type SessionSetWithMuscles = {
  muscles: { muscleGroup: string; role: "primary" | "secondary" }[];
};

export type MuscleVolumeStatus = {
  muscleGroup: MuscleGroup;
  currentSets: number;
  targetMin: number;
  targetMax: number;
  status: "under" | "optimal" | "over";
};

export function computeVolumeStatus(
  sets: SessionSetWithMuscles[],
  targets: VolumeTargetMap
): MuscleVolumeStatus[] {
  const volumeMap = new Map<string, number>();

  for (const set of sets) {
    for (const muscle of set.muscles) {
      const weight = muscle.role === "primary" ? 1 : 0.5;
      const current = volumeMap.get(muscle.muscleGroup) ?? 0;
      volumeMap.set(muscle.muscleGroup, current + weight);
    }
  }

  return MUSCLE_GROUPS.map((group) => {
    const currentSets = volumeMap.get(group) ?? 0;
    const target = targets[group];
    let status: "under" | "optimal" | "over";

    if (currentSets < target.min) {
      status = "under";
    } else if (currentSets > target.max) {
      status = "over";
    } else {
      status = "optimal";
    }

    return {
      muscleGroup: group,
      currentSets,
      targetMin: target.min,
      targetMax: target.max,
      status,
    };
  });
}
```

**Step 4: Run test to verify it passes**

Run: `npx vitest run src/lib/utils/__tests__/volume-analysis.test.ts`

Expected: All 7 tests PASS.

**Step 5: Commit**

```bash
git add src/lib/volume-analysis.ts src/lib/utils/__tests__/volume-analysis.test.ts
git commit -m "feat: add volume analysis engine with primary/secondary weighting"
```

---

### Task 4: Create server action for weekly volume data

**Files:**
- Modify: `src/lib/actions/history.ts` (add `getWeeklyVolumeStatus` function)

**Step 1: Add the server action**

Add to `src/lib/actions/history.ts`:

```typescript
import { getVolumeTargets, type TrainingGoal } from "@/lib/volume-targets";
import { computeVolumeStatus, type MuscleVolumeStatus } from "@/lib/volume-analysis";

export async function getWeeklyVolumeStatus(): Promise<MuscleVolumeStatus[]> {
  const authUser = await getOptionalAuth();
  if (!authUser) return [];

  // Get user's training goal
  const [profile] = await db
    .select({ trainingGoal: profiles.trainingGoal })
    .from(profiles)
    .where(eq(profiles.id, authUser.profileId))
    .limit(1);

  const goal = (profile?.trainingGoal ?? "hypertrophy") as TrainingGoal;
  const targets = getVolumeTargets(goal);

  // Rolling 7-day window
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  const cutoff = sevenDaysAgo.toISOString().split("T")[0];

  // Query session sets with muscle data
  const sets = await db.query.sessionSets.findMany({
    with: {
      exercise: {
        with: {
          exerciseMuscles: {
            with: { muscle: true },
          },
        },
      },
      session: true,
    },
  });

  const userSets = sets.filter(
    (s) =>
      s.session.userId === authUser.profileId &&
      s.session.completed &&
      s.session.date >= cutoff
  );

  const setsWithMuscles = userSets.map((s) => ({
    muscles: s.exercise.exerciseMuscles.map((em) => ({
      muscleGroup: em.muscle?.muscleGroup ?? "",
      role: em.role as "primary" | "secondary",
    })),
  }));

  return computeVolumeStatus(setsWithMuscles, targets);
}
```

Note: This also requires importing `profiles` from the schema. Add to the existing import:

```typescript
import { workoutSessions, sessionSets, exercises, exerciseMuscles, muscles, profiles } from "@/lib/db/schema";
```

**Step 2: Verify the build compiles**

Run: `npx next build` (or `npx tsc --noEmit` for faster type check)

Expected: No type errors.

**Step 3: Commit**

```bash
git add src/lib/actions/history.ts
git commit -m "feat: add getWeeklyVolumeStatus server action"
```

---

### Task 5: Create workout recommendation engine

**Files:**
- Create: `src/lib/workout-recommender.ts`
- Create: `src/lib/utils/__tests__/workout-recommender.test.ts`

**Step 1: Write the failing test**

Create `src/lib/utils/__tests__/workout-recommender.test.ts`:

```typescript
import { describe, it, expect } from "vitest";
import {
  scoreTemplates,
  type TemplateForScoring,
  type MuscleVolumeInput,
} from "@/lib/workout-recommender";

function makeTemplate(
  overrides: Partial<TemplateForScoring> & { id: string }
): TemplateForScoring {
  return {
    name: `Template ${overrides.id}`,
    muscleGroups: [],
    lastUsedDate: null,
    ...overrides,
  };
}

describe("scoreTemplates", () => {
  it("ranks staler templates higher", () => {
    const templates = [
      makeTemplate({ id: "a", lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", lastUsedDate: "2026-03-08" }),
    ];
    const volume: MuscleVolumeInput[] = [];
    const result = scoreTemplates(templates, volume, "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("ranks templates covering under-trained muscles higher", () => {
    const templates = [
      makeTemplate({ id: "a", muscleGroups: ["chest"] }),
      makeTemplate({ id: "b", muscleGroups: ["back"] }),
    ];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
      { muscleGroup: "back", status: "under" },
    ];
    const result = scoreTemplates(templates, volume, "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("gives never-used templates the highest staleness score", () => {
    const templates = [
      makeTemplate({ id: "a", lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", lastUsedDate: null }),
    ];
    const result = scoreTemplates(templates, [], "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("returns empty array for no templates", () => {
    const result = scoreTemplates([], [], "2026-03-12");
    expect(result).toEqual([]);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npx vitest run src/lib/utils/__tests__/workout-recommender.test.ts`

Expected: FAIL — module not found.

**Step 3: Write the implementation**

Create `src/lib/workout-recommender.ts`:

```typescript
export type TemplateForScoring = {
  id: string;
  name: string;
  muscleGroups: string[];
  lastUsedDate: string | null; // ISO date string or null if never used
};

export type MuscleVolumeInput = {
  muscleGroup: string;
  status: "under" | "optimal" | "over";
};

export type ScoredTemplate = {
  templateId: string;
  templateName: string;
  score: number;
  reason: string;
};

export type WorkoutRecommendation = {
  type: "workout" | "rest";
  template?: { id: string; name: string; muscleGroups: string[] };
  reason: string;
};

export function scoreTemplates(
  templates: TemplateForScoring[],
  volumeStatus: MuscleVolumeInput[],
  today: string
): ScoredTemplate[] {
  if (templates.length === 0) return [];

  const underTrainedGroups = new Set(
    volumeStatus.filter((v) => v.status === "under").map((v) => v.muscleGroup)
  );

  const todayMs = new Date(today).getTime();

  return templates.map((t) => {
    // Staleness score: days since last use, max 7 for never-used
    let stalenessScore: number;
    if (t.lastUsedDate === null) {
      stalenessScore = 7;
    } else {
      const daysSince = Math.max(
        0,
        (todayMs - new Date(t.lastUsedDate).getTime()) / (1000 * 60 * 60 * 24)
      );
      stalenessScore = Math.min(daysSince, 7);
    }

    // Volume gap score: count of under-trained muscles this template hits
    const gapScore = t.muscleGroups.filter((g) =>
      underTrainedGroups.has(g)
    ).length;

    const score = stalenessScore + gapScore * 2;

    // Build reason string
    const reasons: string[] = [];
    const underHit = t.muscleGroups.filter((g) => underTrainedGroups.has(g));
    if (underHit.length > 0) {
      reasons.push(
        `targets under-trained muscles: ${underHit.join(", ")}`
      );
    }
    if (t.lastUsedDate === null) {
      reasons.push("never used before");
    } else if (stalenessScore >= 3) {
      reasons.push(`not used in ${Math.round(stalenessScore)} days`);
    }

    return {
      templateId: t.id,
      templateName: t.name,
      score,
      reason:
        reasons.length > 0
          ? reasons.join(" and ")
          : "next in your rotation",
    };
  }).sort((a, b) => b.score - a.score);
}

export function getRecommendation(
  templates: TemplateForScoring[],
  volumeStatus: MuscleVolumeInput[],
  consecutiveTrainingDays: number,
  today: string
): WorkoutRecommendation {
  // Rest day detection
  const allOptimalOrOver = volumeStatus.length > 0 &&
    volumeStatus.every((v) => v.status !== "under");

  if (allOptimalOrOver && consecutiveTrainingDays >= 5) {
    return {
      type: "rest",
      reason: `You've trained ${consecutiveTrainingDays} days straight and all muscle groups are on track. Take a rest day!`,
    };
  }

  if (templates.length === 0) {
    return {
      type: "workout",
      reason: "Create your first workout template to get personalized recommendations.",
    };
  }

  const scored = scoreTemplates(templates, volumeStatus, today);
  const top = scored[0];
  const template = templates.find((t) => t.id === top.templateId)!;

  return {
    type: "workout",
    template: {
      id: template.id,
      name: template.name,
      muscleGroups: template.muscleGroups,
    },
    reason: top.reason.charAt(0).toUpperCase() + top.reason.slice(1),
  };
}
```

**Step 4: Run test to verify it passes**

Run: `npx vitest run src/lib/utils/__tests__/workout-recommender.test.ts`

Expected: All 4 tests PASS.

**Step 5: Add tests for getRecommendation**

Add to the same test file:

```typescript
import { getRecommendation } from "@/lib/workout-recommender";

describe("getRecommendation", () => {
  it("suggests rest when all muscles optimal and trained 5+ days", () => {
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
      { muscleGroup: "back", status: "optimal" },
    ];
    const result = getRecommendation([], volume, 6, "2026-03-12");
    expect(result.type).toBe("rest");
    expect(result.reason).toContain("rest day");
  });

  it("suggests workout even when all optimal if trained fewer than 5 days", () => {
    const templates = [makeTemplate({ id: "a", muscleGroups: ["chest"] })];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
    ];
    const result = getRecommendation(templates, volume, 3, "2026-03-12");
    expect(result.type).toBe("workout");
  });

  it("picks the highest-scored template", () => {
    const templates = [
      makeTemplate({ id: "a", muscleGroups: ["chest"], lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", muscleGroups: ["back"], lastUsedDate: "2026-03-05" }),
    ];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "back", status: "under" },
    ];
    const result = getRecommendation(templates, volume, 2, "2026-03-12");
    expect(result.type).toBe("workout");
    expect(result.template!.id).toBe("b");
  });
});
```

**Step 6: Run all tests**

Run: `npx vitest run src/lib/utils/__tests__/workout-recommender.test.ts`

Expected: All 7 tests PASS.

**Step 7: Commit**

```bash
git add src/lib/workout-recommender.ts src/lib/utils/__tests__/workout-recommender.test.ts
git commit -m "feat: add workout recommendation engine with scoring and rest detection"
```

---

### Task 6: Create server action for workout recommendation

**Files:**
- Modify: `src/lib/actions/history.ts` (add `getWorkoutRecommendation` and `getConsecutiveTrainingDays`)

**Step 1: Add helper for consecutive training days**

Add to `src/lib/actions/history.ts`:

```typescript
import { getRecommendation, type TemplateForScoring } from "@/lib/workout-recommender";
import { type MuscleVolumeStatus } from "@/lib/volume-analysis";

export async function getConsecutiveTrainingDays(): Promise<number> {
  const authUser = await getOptionalAuth();
  if (!authUser) return 0;

  const recentSessions = await db
    .select({ date: workoutSessions.date })
    .from(workoutSessions)
    .where(
      and(
        eq(workoutSessions.userId, authUser.profileId),
        eq(workoutSessions.completed, true)
      )
    )
    .orderBy(desc(workoutSessions.date))
    .limit(30);

  if (recentSessions.length === 0) return 0;

  const dates = [...new Set(recentSessions.map((s) => s.date))].sort().reverse();
  const today = new Date().toISOString().split("T")[0];

  let streak = 0;
  let expected = new Date(today);

  // If most recent session isn't today or yesterday, streak is 0
  const mostRecent = dates[0];
  const diffFromToday = Math.round(
    (new Date(today).getTime() - new Date(mostRecent).getTime()) / (1000 * 60 * 60 * 24)
  );
  if (diffFromToday > 1) return 0;

  // Start from most recent date
  expected = new Date(mostRecent);
  for (const dateStr of dates) {
    const expectedStr = expected.toISOString().split("T")[0];
    if (dateStr === expectedStr) {
      streak++;
      expected.setDate(expected.getDate() - 1);
    } else {
      break;
    }
  }

  return streak;
}
```

**Step 2: Add the recommendation server action**

Add to `src/lib/actions/history.ts`:

```typescript
import { getTemplates } from "@/lib/actions/templates";
import { type WorkoutRecommendation } from "@/lib/workout-recommender";

export async function getWorkoutRecommendation(): Promise<WorkoutRecommendation> {
  const authUser = await getOptionalAuth();
  if (!authUser) {
    return { type: "workout", reason: "Sign in to get personalized recommendations." };
  }

  const [volumeStatus, templates, consecutiveDays] = await Promise.all([
    getWeeklyVolumeStatus(),
    getTemplates(),
    getConsecutiveTrainingDays(),
  ]);

  const today = new Date().toISOString().split("T")[0];

  // Get last-used dates per template from sessions
  const recentSessions = await db
    .select({
      templateId: workoutSessions.templateId,
      date: workoutSessions.date,
    })
    .from(workoutSessions)
    .where(
      and(
        eq(workoutSessions.userId, authUser.profileId),
        eq(workoutSessions.completed, true)
      )
    )
    .orderBy(desc(workoutSessions.date));

  const lastUsedMap = new Map<string, string>();
  for (const s of recentSessions) {
    if (s.templateId && !lastUsedMap.has(s.templateId)) {
      lastUsedMap.set(s.templateId, s.date);
    }
  }

  // Build template scoring input
  const templatesForScoring: TemplateForScoring[] = templates.map((t) => {
    const muscleGroups = new Set<string>();
    for (const te of t.templateExercises) {
      if (te.exercise) {
        // We need exercise muscles — fetch from the template's exercise relations
        // Since getTemplates doesn't include muscles, we derive from volume data
      }
    }

    return {
      id: t.id,
      name: t.name,
      muscleGroups: [], // Will be populated in step below
      lastUsedDate: lastUsedMap.get(t.id) ?? null,
    };
  });

  // Fetch muscle groups per template's exercises
  for (const tfs of templatesForScoring) {
    const template = templates.find((t) => t.id === tfs.id)!;
    const exerciseIds = template.templateExercises
      .map((te) => te.exerciseId)
      .filter(Boolean);

    if (exerciseIds.length > 0) {
      const muscleRows = await db
        .select({
          muscleGroup: muscles.muscleGroup,
        })
        .from(exerciseMuscles)
        .innerJoin(muscles, eq(exerciseMuscles.muscleId, muscles.id))
        .where(
          and(
            sql`${exerciseMuscles.exerciseId} IN (${sql.join(
              exerciseIds.map((id) => sql`${id}`),
              sql`, `
            )})`,
            eq(exerciseMuscles.role, "primary")
          )
        );

      tfs.muscleGroups = [...new Set(muscleRows.map((r) => r.muscleGroup))];
    }
  }

  const volumeInput = volumeStatus.map((v) => ({
    muscleGroup: v.muscleGroup,
    status: v.status,
  }));

  return getRecommendation(templatesForScoring, volumeInput, consecutiveDays, today);
}
```

Note: Also add `sql` to the import from `drizzle-orm` if not already present, and import `muscles, exerciseMuscles` in the schema import.

**Step 3: Verify the build compiles**

Run: `npx tsc --noEmit`

Expected: No type errors.

**Step 4: Commit**

```bash
git add src/lib/actions/history.ts
git commit -m "feat: add workout recommendation and consecutive training days server actions"
```

---

### Task 7: Add training goal to profile settings UI

**Files:**
- Modify: `src/app/(app)/profile/client.tsx`
- Modify: `src/lib/actions/profile.ts`

**Step 1: Add training goal to the updateProfile action**

In `src/lib/actions/profile.ts`, add `trainingGoal` to the update:

```typescript
export async function updateProfile(formData: FormData) {
  const { profileId } = await requireAuth();

  const displayName = formData.get("display_name") as string;
  const preferredUnits = formData.get("preferred_units") as string;
  const trainingGoal = formData.get("training_goal") as string;
  const overloadSessionsThreshold = Number(formData.get("overload_sessions_threshold"));
  const overloadIncrementLbs = Number(formData.get("overload_increment_lbs"));
  const overloadIncrementKg = Number(formData.get("overload_increment_kg"));

  await db
    .update(profiles)
    .set({
      displayName: displayName || null,
      preferredUnits,
      trainingGoal: trainingGoal || "hypertrophy",
      overloadSessionsThreshold,
      overloadIncrementLbs: String(overloadIncrementLbs),
      overloadIncrementKg: String(overloadIncrementKg),
      updatedAt: new Date(),
    })
    .where(eq(profiles.id, profileId));

  revalidatePath("/profile");
  revalidatePath("/", "layout");
}
```

**Step 2: Add training goal selector to the profile form**

In `src/app/(app)/profile/client.tsx`, add a `trainingGoal` state and UI section.

Add state:
```typescript
const [trainingGoal, setTrainingGoal] = useState(profile.trainingGoal ?? "hypertrophy");
```

Add a new Card between the Preferences card and Progressive Overload card:

```tsx
<Card>
  <CardHeader className="pb-2">
    <CardTitle className="text-base">Training Goal</CardTitle>
  </CardHeader>
  <CardContent className="space-y-4">
    <div className="space-y-2">
      <Label>Goal</Label>
      <div className="flex gap-2">
        <input type="hidden" name="training_goal" value={trainingGoal} />
        {(["hypertrophy", "strength", "endurance"] as const).map((goal) => (
          <Button
            key={goal}
            type="button"
            variant={trainingGoal === goal ? "default" : "outline"}
            size="sm"
            onClick={() => setTrainingGoal(goal)}
          >
            {goal.charAt(0).toUpperCase() + goal.slice(1)}
          </Button>
        ))}
      </div>
      <p className="text-xs text-muted-foreground">
        Adjusts your weekly volume targets for the dashboard.
      </p>
    </div>
  </CardContent>
</Card>
```

**Step 3: Verify the page renders**

Run: `npm run dev` and navigate to `/profile`. Verify the Training Goal selector appears and saves correctly.

**Step 4: Commit**

```bash
git add src/app/(app)/profile/client.tsx src/lib/actions/profile.ts
git commit -m "feat: add training goal selector to profile settings"
```

---

### Task 8: Create VolumeReportCard dashboard component

**Files:**
- Create: `src/components/dashboard/volume-report.tsx`

**Step 1: Create the component**

Create `src/components/dashboard/volume-report.tsx`:

```tsx
"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BarChart3 } from "lucide-react";
import { type MuscleVolumeStatus } from "@/lib/volume-analysis";

interface VolumeReportProps {
  volumeStatus: MuscleVolumeStatus[];
}

const statusConfig = {
  under: {
    bar: "from-rose-400 to-rose-500",
    text: "text-rose-500 dark:text-rose-400",
    dot: "bg-rose-500",
    label: "Under",
  },
  optimal: {
    bar: "from-emerald-400 to-emerald-500",
    text: "text-emerald-600 dark:text-emerald-400",
    dot: "bg-emerald-500",
    label: "Optimal",
  },
  over: {
    bar: "from-amber-400 to-amber-500",
    text: "text-amber-600 dark:text-amber-400",
    dot: "bg-amber-500",
    label: "Over",
  },
};

export function VolumeReport({ volumeStatus }: VolumeReportProps) {
  const maxSets = Math.max(
    1,
    ...volumeStatus.map((v) => Math.max(v.currentSets, v.targetMax))
  );

  return (
    <Card className="card-hover overflow-hidden">
      <CardHeader className="pb-3">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-primary/15">
            <BarChart3 className="h-3.5 w-3.5 text-primary" />
          </div>
          <div>
            <CardTitle className="font-display text-sm font-bold">
              Weekly Volume
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Sets vs target range (7-day rolling)
            </p>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-3">
        {volumeStatus.map((v, i) => {
          const config = statusConfig[v.status];
          const currentPercent = Math.max(3, (v.currentSets / maxSets) * 100);
          const minPercent = (v.targetMin / maxSets) * 100;
          const maxPercent = (v.targetMax / maxSets) * 100;

          return (
            <div key={v.muscleGroup} className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold capitalize">
                  {v.muscleGroup}
                </span>
                <span className={`font-mono font-medium ${config.text}`}>
                  {v.currentSets} / {v.targetMin}-{v.targetMax}
                </span>
              </div>
              <div className="relative h-2.5 rounded-full bg-muted/80 overflow-hidden">
                {/* Target range indicator */}
                <div
                  className="absolute top-0 h-full bg-muted-foreground/10 rounded-full"
                  style={{
                    left: `${minPercent}%`,
                    width: `${maxPercent - minPercent}%`,
                  }}
                />
                {/* Current volume bar */}
                <div
                  className={`h-full rounded-full bg-gradient-to-r ${config.bar} animate-bar-fill relative z-10`}
                  style={{
                    width: `${currentPercent}%`,
                    animationDelay: `${i * 100 + 200}ms`,
                  }}
                />
              </div>
            </div>
          );
        })}

        {/* Legend */}
        <div className="flex flex-wrap gap-3 pt-3 text-xs text-muted-foreground">
          {(Object.keys(statusConfig) as Array<keyof typeof statusConfig>).map(
            (key) => (
              <span key={key} className="flex items-center gap-1.5">
                <span
                  className={`h-2 w-2 rounded-full ${statusConfig[key].dot}`}
                />
                {statusConfig[key].label}
              </span>
            )
          )}
        </div>
      </CardContent>
    </Card>
  );
}
```

**Step 2: Verify it compiles**

Run: `npx tsc --noEmit`

Expected: No type errors.

**Step 3: Commit**

```bash
git add src/components/dashboard/volume-report.tsx
git commit -m "feat: add VolumeReport dashboard component"
```

---

### Task 9: Update TodaysWorkout component for recommendations

**Files:**
- Modify: `src/components/dashboard/todays-workout.tsx`

**Step 1: Update the component interface and rendering**

Replace the content of `src/components/dashboard/todays-workout.tsx`:

```tsx
import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Play, Plus, Zap, Coffee } from "lucide-react";
import { type WorkoutRecommendation } from "@/lib/workout-recommender";

interface TodaysWorkoutProps {
  recommendation: WorkoutRecommendation;
  templateExercises?: {
    id: string;
    exercise: { name: string } | null;
  }[];
}

export function TodaysWorkout({
  recommendation,
  templateExercises,
}: TodaysWorkoutProps) {
  if (recommendation.type === "rest") {
    return (
      <Card className="card-hover overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-blue-400 via-indigo-400 to-purple-400" />
        <CardContent className="flex flex-col items-center gap-4 py-10 text-center">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-100 dark:bg-blue-900/30">
            <Coffee className="h-6 w-6 text-blue-600 dark:text-blue-400" />
          </div>
          <div>
            <p className="font-display text-base font-bold">Rest Day</p>
            <p className="mt-1 max-w-sm text-sm text-muted-foreground">
              {recommendation.reason}
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!recommendation.template) {
    return (
      <Card className="card-hover overflow-hidden border-dashed">
        <CardContent className="flex flex-col items-center gap-4 py-10 text-center">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-muted">
            <Plus className="h-6 w-6 text-muted-foreground" />
          </div>
          <div>
            <p className="font-display text-base font-bold">
              No workout template yet
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              Create your first workout to get started
            </p>
          </div>
          <Button asChild className="btn-glow bg-gradient-energy text-white">
            <Link href="/workouts/new">
              <Plus className="mr-2 h-4 w-4" />
              Create Workout
            </Link>
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="card-hover group relative overflow-hidden">
      <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-primary via-chart-2 to-chart-3" />

      <CardContent className="pt-6">
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-gradient-energy shadow-lg transition-transform duration-300 group-hover:scale-105">
              <Zap className="h-5 w-5 text-white" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-wider text-primary">
                Recommended Workout
              </p>
              <p className="mt-0.5 font-display text-lg font-bold">
                {recommendation.template.name}
              </p>
              <p className="mt-1 text-xs text-muted-foreground">
                {recommendation.reason}
              </p>
              {templateExercises && templateExercises.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {templateExercises.slice(0, 5).map((te) => (
                    <Badge
                      key={te.id}
                      variant="secondary"
                      className="rounded-lg text-xs font-medium"
                    >
                      {te.exercise?.name ?? "Unknown"}
                    </Badge>
                  ))}
                  {templateExercises.length > 5 && (
                    <Badge variant="outline" className="rounded-lg text-xs">
                      +{templateExercises.length - 5} more
                    </Badge>
                  )}
                </div>
              )}
            </div>
          </div>

          <Button
            asChild
            className="btn-glow shrink-0 bg-gradient-energy text-white shadow-lg"
          >
            <Link href={`/workouts/${recommendation.template.id}/start`}>
              <Play className="mr-1.5 h-4 w-4" />
              Start
            </Link>
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
```

**Step 2: Verify it compiles**

Run: `npx tsc --noEmit`

Expected: No type errors.

**Step 3: Commit**

```bash
git add src/components/dashboard/todays-workout.tsx
git commit -m "feat: update TodaysWorkout to use recommendation engine with rest day support"
```

---

### Task 10: Wire everything into the dashboard page

**Files:**
- Modify: `src/app/(app)/page.tsx`

**Step 1: Update the dashboard to use new data sources**

Replace `src/app/(app)/page.tsx`:

```tsx
import { getWeeklyVolumeStatus, getWorkoutRecommendation } from "@/lib/actions/history";
import { getTemplates } from "@/lib/actions/templates";
import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { workoutSessions, workoutTemplates } from "@/lib/db/schema";
import { eq, desc, and, sql } from "drizzle-orm";
import { VolumeReport } from "@/components/dashboard/volume-report";
import { TodaysWorkout } from "@/components/dashboard/todays-workout";
import { RecentSessions } from "@/components/dashboard/recent-sessions";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { Flame } from "lucide-react";

export default async function DashboardPage() {
  const session = await auth();
  const profileId = (session?.user as { profileId?: string })?.profileId;

  const [recommendation, volumeStatus, templates, recentSessionsData] =
    await Promise.all([
      getWorkoutRecommendation(),
      getWeeklyVolumeStatus(),
      getTemplates(),
      profileId
        ? db
            .select({
              id: workoutSessions.id,
              date: workoutSessions.date,
              durationMinutes: workoutSessions.durationMinutes,
              templateName: workoutTemplates.name,
              totalSets:
                sql<number>`(select count(*) from session_sets where session_id = ${workoutSessions.id})`.as(
                  "total_sets"
                ),
            })
            .from(workoutSessions)
            .leftJoin(
              workoutTemplates,
              eq(workoutSessions.templateId, workoutTemplates.id)
            )
            .where(
              and(
                eq(workoutSessions.userId, profileId),
                eq(workoutSessions.completed, true)
              )
            )
            .orderBy(desc(workoutSessions.date))
            .limit(5)
        : Promise.resolve([]),
    ]);

  // Find the recommended template's exercises for display
  const recommendedTemplate =
    recommendation.type === "workout" && recommendation.template
      ? templates.find((t) => t.id === recommendation.template!.id)
      : null;

  const recentSessions = recentSessionsData.map((s) => ({
    id: s.id,
    date: s.date,
    durationMinutes: s.durationMinutes,
    template: s.templateName ? { name: s.templateName } : null,
    totalSets: Number(s.totalSets),
  }));

  const firstName = session?.user?.name?.split(" ")[0] ?? "there";

  return (
    <div className="stagger-children space-y-8">
      {/* Hero greeting */}
      <div className="relative">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-energy shadow-lg">
            <Flame className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="font-display text-3xl font-extrabold tracking-tight">
              Hey, <span className="gradient-text">{firstName}</span>
            </h1>
            <p className="text-sm text-muted-foreground">
              Let&apos;s crush it today
            </p>
          </div>
        </div>
      </div>

      {/* Today's workout — recommendation card */}
      <TodaysWorkout
        recommendation={recommendation}
        templateExercises={recommendedTemplate?.templateExercises}
      />

      {/* Two-column grid */}
      <div className="grid gap-6 md:grid-cols-2">
        <VolumeReport volumeStatus={volumeStatus} />
        <QuickActions />
      </div>

      {/* Recent sessions */}
      <RecentSessions sessions={recentSessions} />
    </div>
  );
}
```

**Step 2: Verify the build**

Run: `npm run build`

Expected: Build succeeds with no errors.

**Step 3: Manual testing**

Run: `npm run dev` and verify:
- Dashboard shows recommendation card (with reason text)
- Volume report shows bars with target ranges
- Rest day card appears when appropriate
- New user with no templates sees "Create Workout" prompt
- Profile settings Training Goal selector saves and affects volume targets

**Step 4: Commit**

```bash
git add src/app/(app)/page.tsx
git commit -m "feat: wire volume tracking and recommendations into dashboard"
```

---

### Task 11: Run full test suite and fix any issues

**Step 1: Run all tests**

Run: `npx vitest run`

Expected: All tests pass (existing + new).

**Step 2: Run type check**

Run: `npx tsc --noEmit`

Expected: No type errors.

**Step 3: Run build**

Run: `npm run build`

Expected: Build succeeds.

**Step 4: Fix any failures**

If any tests fail, investigate and fix. Common issues:
- Import path mismatches
- Type mismatches between Drizzle schema and new code
- Missing `"use server"` directives

**Step 5: Final commit**

```bash
git add -A
git commit -m "fix: resolve any remaining issues from smart dashboard integration"
```

Only commit this if there were actual fixes needed.
