"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function startSession(templateId?: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("workout_sessions")
    .insert({
      user_id: user.id,
      template_id: templateId ?? null,
      date: new Date().toISOString().split("T")[0],
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function logSet(
  sessionId: string,
  exerciseId: string,
  setNumber: number,
  weight: number,
  reps: number,
  rpe?: number | null
) {
  const supabase = await createClient();

  // Check if set already exists (upsert by session + exercise + set_number)
  const { data: existing } = await supabase
    .from("session_sets")
    .select("id")
    .eq("session_id", sessionId)
    .eq("exercise_id", exerciseId)
    .eq("set_number", setNumber)
    .maybeSingle();

  if (existing) {
    const { error } = await supabase
      .from("session_sets")
      .update({ weight, reps, rpe: rpe ?? null })
      .eq("id", existing.id);
    if (error) throw error;
  } else {
    const { error } = await supabase.from("session_sets").insert({
      session_id: sessionId,
      exercise_id: exerciseId,
      set_number: setNumber,
      weight,
      reps,
      rpe: rpe ?? null,
    });
    if (error) throw error;
  }
}

export async function deleteSet(setId: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("session_sets")
    .delete()
    .eq("id", setId);
  if (error) throw error;
}

export async function finishSession(
  sessionId: string,
  durationMinutes: number,
  notes?: string
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("workout_sessions")
    .update({
      completed: true,
      duration_minutes: durationMinutes,
      notes: notes || null,
      updated_at: new Date().toISOString(),
    })
    .eq("id", sessionId);

  if (error) throw error;
  revalidatePath("/history");
  revalidatePath("/workouts");
}

export async function getLastSessionForExercise(exerciseId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Find the most recent completed session that has sets for this exercise
  const { data: sets } = await supabase
    .from("session_sets")
    .select(
      `
      set_number,
      weight,
      reps,
      rpe,
      session:workout_sessions!inner (
        id,
        date,
        completed,
        user_id
      )
    `
    )
    .eq("exercise_id", exerciseId)
    .eq("session.user_id", user.id)
    .eq("session.completed", true)
    .order("created_at", { ascending: false })
    .limit(20);

  if (!sets || sets.length === 0) return null;

  // Group by session and take the most recent one
  const sessionId = (sets[0].session as unknown as { id: string }).id;
  const lastSets = sets
    .filter(
      (s) => (s.session as unknown as { id: string }).id === sessionId
    )
    .sort((a, b) => a.set_number - b.set_number);

  return lastSets.map((s) => ({
    set_number: s.set_number,
    weight: s.weight,
    reps: s.reps,
    rpe: s.rpe,
  }));
}

export async function getSession(id: string) {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("workout_sessions")
    .select(
      `
      *,
      template:workout_templates (id, name),
      session_sets (
        id,
        exercise_id,
        set_number,
        weight,
        reps,
        rpe,
        exercise:exercises (id, name)
      )
    `
    )
    .eq("id", id)
    .single();

  if (error) throw error;
  return data;
}
