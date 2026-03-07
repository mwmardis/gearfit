// src/lib/actions/history.ts
"use server";

import { db } from "@/lib/db";
import { workoutSessions, sessionSets, exercises, exerciseMuscles, muscles } from "@/lib/db/schema";
import { eq, and, gte, lte, desc, asc } from "drizzle-orm";
import { requireAuth, getOptionalAuth } from "@/lib/auth-utils";

export async function getSessionsByMonth(year: number, month: number) {
  const { profileId } = await requireAuth();

  const startDate = new Date(year, month, 1).toISOString().split("T")[0];
  const endDate = new Date(year, month + 1, 0).toISOString().split("T")[0];

  return db.query.workoutSessions.findMany({
    where: and(
      eq(workoutSessions.userId, profileId),
      eq(workoutSessions.completed, true),
      gte(workoutSessions.date, startDate),
      lte(workoutSessions.date, endDate)
    ),
    with: {
      template: true,
      sessionSets: {
        with: { exercise: true },
      },
    },
    orderBy: [desc(workoutSessions.date)],
  }) ?? [];
}

export async function getHistorySession(id: string) {
  const result = await db.query.workoutSessions.findFirst({
    where: eq(workoutSessions.id, id),
    with: {
      template: true,
      sessionSets: {
        with: { exercise: true },
      },
    },
  });

  if (!result) throw new Error("Session not found");
  return result;
}

export async function getExerciseHistory(exerciseId: string, limit = 20) {
  const authUser = await getOptionalAuth();
  if (!authUser) return [];

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: { session: true },
    orderBy: (s, { desc }) => [desc(s.createdAt)],
    limit: limit * 10,
  });

  const userSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (userSets.length === 0) return [];

  const sessionMap = new Map<
    string,
    { date: string; maxWeight: number; totalVolume: number }
  >();

  for (const set of userSets) {
    const date = set.session.date;
    const weight = Number(set.weight);
    const volume = weight * set.reps;
    const existing = sessionMap.get(date);

    if (existing) {
      existing.maxWeight = Math.max(existing.maxWeight, weight);
      existing.totalVolume += volume;
    } else {
      sessionMap.set(date, { date, maxWeight: weight, totalVolume: volume });
    }
  }

  return Array.from(sessionMap.values())
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(-limit);
}

export async function getPersonalBests(exerciseId: string) {
  const authUser = await getOptionalAuth();
  if (!authUser) return null;

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: { session: true },
  });

  const userSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (userSets.length === 0) return null;

  let maxWeight = 0;
  let maxReps = 0;
  let maxVolume = 0;

  for (const set of userSets) {
    const weight = Number(set.weight);
    maxWeight = Math.max(maxWeight, weight);
    maxReps = Math.max(maxReps, set.reps);
    maxVolume = Math.max(maxVolume, weight * set.reps);
  }

  return { maxWeight, maxReps, maxVolume };
}

export async function getTrainingStreak() {
  const authUser = await getOptionalAuth();
  if (!authUser) return 0;

  const startDate = new Date();
  startDate.setDate(startDate.getDate() - 365);

  const sessionsData = await db
    .select({ date: workoutSessions.date })
    .from(workoutSessions)
    .where(
      and(
        eq(workoutSessions.userId, authUser.profileId),
        eq(workoutSessions.completed, true),
        gte(workoutSessions.date, startDate.toISOString().split("T")[0])
      )
    )
    .orderBy(desc(workoutSessions.date));

  if (sessionsData.length === 0) return 0;

  const weeks = new Set<string>();
  for (const session of sessionsData) {
    const d = new Date(session.date);
    const weekStart = new Date(d);
    weekStart.setDate(d.getDate() - d.getDay());
    weeks.add(weekStart.toISOString().split("T")[0]);
  }

  const sortedWeeks = Array.from(weeks).sort().reverse();
  let streak = 0;

  const now = new Date();
  const currentWeekStart = new Date(now);
  currentWeekStart.setDate(now.getDate() - now.getDay());
  const currentWeekKey = currentWeekStart.toISOString().split("T")[0];

  const lastWeekStart = new Date(currentWeekStart);
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);
  const lastWeekKey = lastWeekStart.toISOString().split("T")[0];

  if (!weeks.has(currentWeekKey) && !weeks.has(lastWeekKey)) return 0;

  const startIdx = weeks.has(currentWeekKey)
    ? sortedWeeks.indexOf(currentWeekKey)
    : sortedWeeks.indexOf(lastWeekKey);

  for (let i = startIdx; i < sortedWeeks.length; i++) {
    const expectedWeek = new Date(sortedWeeks[startIdx]);
    expectedWeek.setDate(expectedWeek.getDate() - (i - startIdx) * 7);
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
  const authUser = await getOptionalAuth();
  if (!authUser) return [];

  const now = new Date();
  const weekStart = new Date(now);
  weekStart.setDate(now.getDate() - now.getDay());
  weekStart.setHours(0, 0, 0, 0);

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
      new Date(s.session.date) >= weekStart
  );

  if (userSets.length === 0) return [];

  const coverage = new Map<string, number>();

  for (const set of userSets) {
    for (const em of set.exercise.exerciseMuscles) {
      if (em.role === "primary" && em.muscle) {
        const group = em.muscle.muscleGroup;
        coverage.set(group, (coverage.get(group) ?? 0) + 1);
      }
    }
  }

  return Array.from(coverage.entries())
    .map(([group, sets]) => ({ group, sets }))
    .sort((a, b) => b.sets - a.sets);
}
