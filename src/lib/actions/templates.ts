"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function getTemplates() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("workout_templates")
    .select(
      `
      *,
      template_exercises (
        id,
        exercise_id,
        order_index,
        target_sets,
        target_reps,
        target_weight,
        exercise:exercises (id, name)
      )
    `
    )
    .eq("user_id", user.id)
    .order("updated_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function getTemplate(id: string) {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("workout_templates")
    .select(
      `
      *,
      template_exercises (
        id,
        exercise_id,
        order_index,
        target_sets,
        target_reps,
        target_weight,
        exercise:exercises (
          id,
          name,
          exercise_muscles (
            role,
            muscle:muscles (name, muscle_group)
          )
        )
      )
    `
    )
    .eq("id", id)
    .single();

  if (error) throw error;

  // Sort template exercises by order_index
  data.template_exercises.sort(
    (
      a: { order_index: number },
      b: { order_index: number }
    ) => a.order_index - b.order_index
  );

  return data;
}

export async function createTemplate(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  const { data, error } = await supabase
    .from("workout_templates")
    .insert({ name, description, user_id: user.id })
    .select()
    .single();

  if (error) throw error;
  redirect(`/workouts/${data.id}`);
}

export async function updateTemplate(id: string, formData: FormData) {
  const supabase = await createClient();
  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  const { error } = await supabase
    .from("workout_templates")
    .update({ name, description, updated_at: new Date().toISOString() })
    .eq("id", id);

  if (error) throw error;
  revalidatePath(`/workouts/${id}`);
  revalidatePath("/workouts");
}

export async function addExerciseToTemplate(
  templateId: string,
  exerciseId: string,
  orderIndex: number
) {
  const supabase = await createClient();

  const { error } = await supabase.from("template_exercises").insert({
    template_id: templateId,
    exercise_id: exerciseId,
    order_index: orderIndex,
  });

  if (error) throw error;

  // Touch the template's updated_at
  await supabase
    .from("workout_templates")
    .update({ updated_at: new Date().toISOString() })
    .eq("id", templateId);

  revalidatePath(`/workouts/${templateId}`);
}

export async function removeExerciseFromTemplate(
  templateExerciseId: string,
  templateId: string
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("template_exercises")
    .delete()
    .eq("id", templateExerciseId);

  if (error) throw error;
  revalidatePath(`/workouts/${templateId}`);
}

export async function reorderTemplateExercises(
  templateId: string,
  exerciseIds: string[]
) {
  const supabase = await createClient();

  // Update each exercise's order_index
  const updates = exerciseIds.map((id, index) =>
    supabase
      .from("template_exercises")
      .update({ order_index: index })
      .eq("id", id)
  );

  await Promise.all(updates);
  revalidatePath(`/workouts/${templateId}`);
}

export async function updateTemplateExercise(
  id: string,
  templateId: string,
  data: { target_sets?: number; target_reps?: number; target_weight?: number | null }
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("template_exercises")
    .update(data)
    .eq("id", id);

  if (error) throw error;
  revalidatePath(`/workouts/${templateId}`);
}

export async function cloneTemplate(id: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  // Fetch original template with exercises
  const { data: original, error: fetchError } = await supabase
    .from("workout_templates")
    .select(
      `
      *,
      template_exercises (
        exercise_id,
        order_index,
        target_sets,
        target_reps,
        target_weight
      )
    `
    )
    .eq("id", id)
    .single();

  if (fetchError) throw fetchError;

  // Create new template
  const { data: newTemplate, error: createError } = await supabase
    .from("workout_templates")
    .insert({
      name: `${original.name} (Copy)`,
      description: original.description,
      user_id: user.id,
    })
    .select()
    .single();

  if (createError) throw createError;

  // Copy exercises
  if (original.template_exercises.length > 0) {
    const exercises = original.template_exercises.map(
      (te: {
        exercise_id: string;
        order_index: number;
        target_sets: number;
        target_reps: number;
        target_weight: number | null;
      }) => ({
        template_id: newTemplate.id,
        exercise_id: te.exercise_id,
        order_index: te.order_index,
        target_sets: te.target_sets,
        target_reps: te.target_reps,
        target_weight: te.target_weight,
      })
    );

    const { error: exercisesError } = await supabase
      .from("template_exercises")
      .insert(exercises);

    if (exercisesError) throw exercisesError;
  }

  revalidatePath("/workouts");
  redirect(`/workouts/${newTemplate.id}`);
}

export async function deleteTemplate(id: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("workout_templates")
    .delete()
    .eq("id", id);

  if (error) throw error;
  revalidatePath("/workouts");
  redirect("/workouts");
}
