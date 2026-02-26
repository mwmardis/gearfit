"use server";

import { createClient } from "@/lib/supabase/server";

export async function getSessionsByMonth(year: number, month: number) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  // month is 0-indexed (0 = January)
  const startDate = new Date(year, month, 1).toISOString().split("T")[0];
  const endDate = new Date(year, month + 1, 0).toISOString().split("T")[0];

  const { data, error } = await supabase
    .from("workout_sessions")
    .select(
      `
      id,
      date,
      completed,
      duration_minutes,
      notes,
      template:workout_templates (id, name),
      session_sets (
        exercise_id,
        exercise:exercises (name)
      )
    `
    )
    .eq("user_id", user.id)
    .eq("completed", true)
    .gte("date", startDate)
    .lte("date", endDate)
    .order("date", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function getHistorySession(id: string) {
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

export async function getExerciseHistory(exerciseId: string, limit = 20) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase
    .from("session_sets")
    .select(
      `
      weight,
      reps,
      set_number,
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
    .limit(limit * 10);

  if (error) throw error;
  if (!data || data.length === 0) return [];

  // Group by session date, compute max weight per session
  const sessionMap = new Map<
    string,
    { date: string; maxWeight: number; totalVolume: number }
  >();

  for (const set of data) {
    const session = set.session as unknown as { date: string };
    const date = session.date;
    const existing = sessionMap.get(date);
    const volume = set.weight * set.reps;

    if (existing) {
      existing.maxWeight = Math.max(existing.maxWeight, set.weight);
      existing.totalVolume += volume;
    } else {
      sessionMap.set(date, { date, maxWeight: set.weight, totalVolume: volume });
    }
  }

  return Array.from(sessionMap.values())
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(-limit);
}

export async function getPersonalBests(exerciseId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data, error } = await supabase
    .from("session_sets")
    .select(
      `
      weight,
      reps,
      session:workout_sessions!inner (
        user_id,
        completed
      )
    `
    )
    .eq("exercise_id", exerciseId)
    .eq("session.user_id", user.id)
    .eq("session.completed", true);

  if (error) throw error;
  if (!data || data.length === 0) return null;

  let maxWeight = 0;
  let maxReps = 0;
  let maxVolume = 0;

  for (const set of data) {
    maxWeight = Math.max(maxWeight, set.weight);
    maxReps = Math.max(maxReps, set.reps);
    maxVolume = Math.max(maxVolume, set.weight * set.reps);
  }

  return { maxWeight, maxReps, maxVolume };
}

export async function getTrainingStreak() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  // Get all completed session dates in the last 52 weeks
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - 365);

  const { data, error } = await supabase
    .from("workout_sessions")
    .select("date")
    .eq("user_id", user.id)
    .eq("completed", true)
    .gte("date", startDate.toISOString().split("T")[0])
    .order("date", { ascending: false });

  if (error) throw error;
  if (!data || data.length === 0) return 0;

  // Group by ISO week and count consecutive weeks
  const weeks = new Set<string>();
  for (const session of data) {
    const d = new Date(session.date);
    const weekStart = new Date(d);
    weekStart.setDate(d.getDate() - d.getDay());
    weeks.add(weekStart.toISOString().split("T")[0]);
  }

  const sortedWeeks = Array.from(weeks).sort().reverse();
  let streak = 0;

  // Check if current week has a session
  const now = new Date();
  const currentWeekStart = new Date(now);
  currentWeekStart.setDate(now.getDate() - now.getDay());
  const currentWeekKey = currentWeekStart.toISOString().split("T")[0];

  // Also check last week (in case we're early in the week)
  const lastWeekStart = new Date(currentWeekStart);
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);
  const lastWeekKey = lastWeekStart.toISOString().split("T")[0];

  if (!weeks.has(currentWeekKey) && !weeks.has(lastWeekKey)) return 0;

  const startIdx = weeks.has(currentWeekKey)
    ? sortedWeeks.indexOf(currentWeekKey)
    : sortedWeeks.indexOf(lastWeekKey);

  for (let i = startIdx; i < sortedWeeks.length; i++) {
    const expectedWeek = new Date(
      i === startIdx ? sortedWeeks[startIdx] : sortedWeeks[startIdx]
    );
    expectedWeek.setDate(
      expectedWeek.getDate() - (i - startIdx) * 7
    );
    const expectedKey = expectedWeek.toISOString().split("T")[0];

    if (sortedWeeks[i] === expectedKey) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

export async function getWeeklyMuscleCoverage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  // Get sessions from this week (Sunday to Saturday)
  const now = new Date();
  const weekStart = new Date(now);
  weekStart.setDate(now.getDate() - now.getDay());
  weekStart.setHours(0, 0, 0, 0);

  const { data: sets, error } = await supabase
    .from("session_sets")
    .select(
      `
      exercise_id,
      exercise:exercises!inner (
        exercise_muscles (
          role,
          muscle:muscles (name, muscle_group)
        )
      ),
      session:workout_sessions!inner (
        user_id,
        completed,
        date
      )
    `
    )
    .eq("session.user_id", user.id)
    .eq("session.completed", true)
    .gte("session.date", weekStart.toISOString().split("T")[0]);

  if (error) throw error;
  if (!sets || sets.length === 0) return [];

  // Count sets per muscle group
  const coverage = new Map<string, number>();

  for (const set of sets) {
    const exercise = set.exercise as unknown as {
      exercise_muscles: {
        role: string;
        muscle: { name: string; muscle_group: string } | null;
      }[];
    };
    for (const em of exercise.exercise_muscles) {
      if (em.role === "primary" && em.muscle) {
        const group = em.muscle.muscle_group;
        coverage.set(group, (coverage.get(group) ?? 0) + 1);
      }
    }
  }

  return Array.from(coverage.entries())
    .map(([group, sets]) => ({ group, sets }))
    .sort((a, b) => b.sets - a.sets);
}
