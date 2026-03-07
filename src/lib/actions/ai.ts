// src/lib/actions/ai.ts
"use server";

import { db } from "@/lib/db";
import {
  exercises,
  muscles,
  exerciseMuscles,
  equipment,
  exerciseEquipment,
  savedAiSuggestions,
} from "@/lib/db/schema";
import { eq, or } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import type { GeminiExerciseSuggestion } from "@/lib/ai/types";
import { normalizeMuscleNames } from "@/lib/validators/muscles";

export async function createExerciseFromSuggestion(
  suggestion: GeminiExerciseSuggestion,
  equipmentNames: string[]
) {
  const { profileId } = await requireAuth();

  const [exercise] = await db
    .insert(exercises)
    .values({
      name: suggestion.name,
      description: suggestion.description,
      instructions: suggestion.instructions,
      isCustom: true,
      createdBy: profileId,
    })
    .returning();

  // Get muscle IDs
  const allMuscles = await db.select().from(muscles);
  if (allMuscles.length > 0) {
    const dbMuscleNames = allMuscles.map((m) => m.name);
    const primaryMatched = normalizeMuscleNames(suggestion.primaryMuscles, dbMuscleNames);
    const secondaryMatched = normalizeMuscleNames(suggestion.secondaryMuscles, dbMuscleNames);

    const muscleRows = [
      ...primaryMatched.map((name) => ({
        exerciseId: exercise.id,
        muscleId: allMuscles.find((m) => m.name === name)!.id,
        role: "primary" as const,
      })),
      ...secondaryMatched.map((name) => ({
        exerciseId: exercise.id,
        muscleId: allMuscles.find((m) => m.name === name)!.id,
        role: "secondary" as const,
      })),
    ];

    if (muscleRows.length > 0) {
      await db.insert(exerciseMuscles).values(muscleRows);
    }
  }

  // Link to equipment
  const allEquipment = await db
    .select()
    .from(equipment)
    .where(or(eq(equipment.isCustom, false), eq(equipment.createdBy, profileId)));

  if (allEquipment.length > 0) {
    const equipmentRows = equipmentNames
      .map((name) =>
        allEquipment.find((e) => e.name.toLowerCase() === name.toLowerCase())
      )
      .filter((e): e is NonNullable<typeof e> => e !== undefined)
      .map((e) => ({ exerciseId: exercise.id, equipmentId: e.id }));

    if (equipmentRows.length > 0) {
      await db.insert(exerciseEquipment).values(equipmentRows);
    }
  }

  revalidatePath("/exercises");
  return exercise;
}

export async function saveSuggestion(
  suggestion: GeminiExerciseSuggestion & {
    existingExerciseId?: string;
    workoutType: string;
  }
) {
  const { profileId } = await requireAuth();

  await db.insert(savedAiSuggestions).values({
    userId: profileId,
    exerciseName: suggestion.name,
    exerciseId: suggestion.existingExerciseId ?? null,
    primaryMuscles: suggestion.primaryMuscles,
    secondaryMuscles: suggestion.secondaryMuscles,
    suggestedSets: suggestion.suggestedSets,
    suggestedReps: suggestion.suggestedReps,
    description: suggestion.description,
    instructions: suggestion.instructions,
    workoutType: suggestion.workoutType,
  });
}

export async function getSavedSuggestions() {
  const { profileId } = await requireAuth();

  return db
    .select()
    .from(savedAiSuggestions)
    .where(eq(savedAiSuggestions.userId, profileId))
    .orderBy(savedAiSuggestions.createdAt);
}

export async function deleteSavedSuggestion(id: string) {
  await db.delete(savedAiSuggestions).where(eq(savedAiSuggestions.id, id));
}
