// src/lib/actions/sessions.ts
"use server";

import { db } from "@/lib/db";
import { workoutSessions, sessionSets, workoutTemplates, exercises } from "@/lib/db/schema";
import { eq, and } from "drizzle-orm";
import { requireAuth, getOptionalAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";

export async function startSession(templateId?: string) {
  const { profileId } = await requireAuth();

  const [data] = await db
    .insert(workoutSessions)
    .values({
      userId: profileId,
      templateId: templateId ?? null,
      date: new Date().toISOString().split("T")[0],
    })
    .returning();

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
  // Check if set already exists
  const [existing] = await db
    .select({ id: sessionSets.id })
    .from(sessionSets)
    .where(
      and(
        eq(sessionSets.sessionId, sessionId),
        eq(sessionSets.exerciseId, exerciseId),
        eq(sessionSets.setNumber, setNumber)
      )
    )
    .limit(1);

  if (existing) {
    await db
      .update(sessionSets)
      .set({ weight: String(weight), reps, rpe: rpe != null ? String(rpe) : null })
      .where(eq(sessionSets.id, existing.id));
  } else {
    await db.insert(sessionSets).values({
      sessionId,
      exerciseId,
      setNumber,
      weight: String(weight),
      reps,
      rpe: rpe != null ? String(rpe) : null,
    });
  }
}

export async function deleteSet(setId: string) {
  await db.delete(sessionSets).where(eq(sessionSets.id, setId));
}

export async function finishSession(
  sessionId: string,
  durationMinutes: number,
  notes?: string
) {
  await db
    .update(workoutSessions)
    .set({
      completed: true,
      durationMinutes,
      notes: notes || null,
      updatedAt: new Date(),
    })
    .where(eq(workoutSessions.id, sessionId));

  revalidatePath("/history");
  revalidatePath("/workouts");
}

export async function getLastSessionForExercise(exerciseId: string) {
  const authUser = await getOptionalAuth();
  if (!authUser) return null;

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: {
      session: true,
    },
    orderBy: (s, { desc }) => [desc(s.createdAt)],
    limit: 20,
  });

  const completedSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (completedSets.length === 0) return null;

  const sessionId = completedSets[0].session.id;
  const lastSets = completedSets
    .filter((s) => s.session.id === sessionId)
    .sort((a, b) => a.setNumber - b.setNumber);

  return lastSets.map((s) => ({
    set_number: s.setNumber,
    weight: Number(s.weight),
    reps: s.reps,
    rpe: s.rpe ? Number(s.rpe) : null,
  }));
}

export async function getSession(id: string) {
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
