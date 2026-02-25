"use server";

import { createClient } from "@/lib/supabase/server";

export interface ExerciseFilters {
  muscleGroup?: string;
  availableOnly?: boolean;
  search?: string;
}

export async function getExercises(filters: ExerciseFilters = {}) {
  const supabase = await createClient();

  let query = supabase.from("exercises").select(
    `
      *,
      exercise_equipment (
        equipment:equipment (id, name)
      ),
      exercise_muscles (
        role,
        muscle:muscles (id, name, muscle_group)
      )
    `
  );

  if (filters.search) {
    query = query.ilike("name", `%${filters.search}%`);
  }

  const { data: exercises, error } = await query.order("name");
  if (error) throw error;

  let filtered = exercises ?? [];

  // Filter by muscle group
  if (filters.muscleGroup) {
    filtered = filtered.filter((ex) =>
      ex.exercise_muscles.some(
        (em: { role: string; muscle: { muscle_group: string } | null }) =>
          em.muscle?.muscle_group === filters.muscleGroup && em.role === "primary"
      )
    );
  }

  // Filter by available equipment
  if (filters.availableOnly) {
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (user) {
      const { data: activeProfile } = await supabase
        .from("equipment_profiles")
        .select("id")
        .eq("user_id", user.id)
        .eq("is_active", true)
        .single();

      if (activeProfile) {
        const { data: profileItems } = await supabase
          .from("equipment_profile_items")
          .select("equipment_id")
          .eq("equipment_profile_id", activeProfile.id);

        const availableIds = new Set(
          (profileItems ?? []).map((i) => i.equipment_id)
        );

        filtered = filtered.filter((ex) => {
          const required = ex.exercise_equipment.map(
            (ee: { equipment: { id: string } | null }) => ee.equipment?.id
          );
          return required.every(
            (id: string | undefined) => id && availableIds.has(id)
          );
        });
      }
    }
  }

  return filtered;
}

export async function getExercise(id: string) {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("exercises")
    .select(
      `
      *,
      exercise_equipment (
        equipment:equipment (id, name, category)
      ),
      exercise_muscles (
        role,
        muscle:muscles (id, name, muscle_group)
      )
    `
    )
    .eq("id", id)
    .single();

  if (error) throw error;
  return data;
}

export async function getAvailableExercises() {
  return getExercises({ availableOnly: true });
}
