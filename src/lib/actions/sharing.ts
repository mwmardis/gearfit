"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function toggleShareTemplate(templateId: string) {
  const supabase = await createClient();

  // Fetch current state
  const { data: template, error: fetchError } = await supabase
    .from("workout_templates")
    .select("is_shared, share_token")
    .eq("id", templateId)
    .single();

  if (fetchError) throw fetchError;

  if (template.is_shared) {
    // Unshare
    const { error } = await supabase
      .from("workout_templates")
      .update({ is_shared: false })
      .eq("id", templateId);
    if (error) throw error;
    revalidatePath(`/workouts/${templateId}`);
    return { shared: false, shareUrl: null };
  } else {
    // Share — generate token if needed
    const shareToken =
      template.share_token ?? crypto.randomUUID().replace(/-/g, "").slice(0, 16);

    const { error } = await supabase
      .from("workout_templates")
      .update({ is_shared: true, share_token: shareToken })
      .eq("id", templateId);
    if (error) throw error;
    revalidatePath(`/workouts/${templateId}`);
    return { shared: true, shareToken };
  }
}

export async function getSharedTemplate(shareToken: string) {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("workout_templates")
    .select(
      `
      id,
      name,
      description,
      share_token,
      is_shared,
      user_id,
      template_exercises (
        id,
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
    .eq("share_token", shareToken)
    .eq("is_shared", true)
    .single();

  if (error) throw error;

  // Sort exercises by order
  data.template_exercises.sort(
    (a: { order_index: number }, b: { order_index: number }) =>
      a.order_index - b.order_index
  );

  return data;
}

export async function importSharedTemplate(shareToken: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  // Fetch shared template
  const shared = await getSharedTemplate(shareToken);

  // Create new template
  const { data: newTemplate, error: createError } = await supabase
    .from("workout_templates")
    .insert({
      name: shared.name,
      description: shared.description,
      user_id: user.id,
    })
    .select()
    .single();

  if (createError) throw createError;

  // Copy exercises
  if (shared.template_exercises.length > 0) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const exercises = (shared.template_exercises as any[]).map(
      (te: {
        exercise: { id: string } | null;
        order_index: number;
        target_sets: number;
        target_reps: number;
        target_weight: number | null;
      }) => ({
        template_id: newTemplate.id,
        exercise_id: te.exercise?.id ?? "",
        order_index: te.order_index,
        target_sets: te.target_sets,
        target_reps: te.target_reps,
        target_weight: te.target_weight,
      })
    );

    const { error: exercisesError } = await supabase
      .from("template_exercises")
      .insert(exercises.filter((e: { exercise_id: string }) => e.exercise_id));

    if (exercisesError) throw exercisesError;
  }

  redirect(`/workouts/${newTemplate.id}`);
}
