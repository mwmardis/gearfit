"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type { GeminiExerciseSuggestion } from "@/lib/ai/types";

import { normalizeMuscleNames } from "@/lib/validators/muscles";

export async function createExerciseFromSuggestion(
  suggestion: GeminiExerciseSuggestion,
  equipmentNames: string[]
) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
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
    const primaryMatched = normalizeMuscleNames(
      suggestion.primaryMuscles,
      dbMuscleNames
    );
    const secondaryMatched = normalizeMuscleNames(
      suggestion.secondaryMuscles,
      dbMuscleNames
    );

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
      .map((name) =>
        equipment.find((e) => e.name.toLowerCase() === name.toLowerCase())
      )
      .filter((e): e is NonNullable<typeof e> => e !== undefined)
      .map((e) => ({ exercise_id: exercise.id, equipment_id: e.id }));

    if (equipmentRows.length > 0) {
      await supabase.from("exercise_equipment").insert(equipmentRows);
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
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
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
  const {
    data: { user },
  } = await supabase.auth.getUser();
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
