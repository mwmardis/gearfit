// src/lib/actions/sharing.ts
"use server";

import { db } from "@/lib/db";
import { workoutTemplates, templateExercises } from "@/lib/db/schema";
import { eq, and } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function toggleShareTemplate(templateId: string) {
  const [template] = await db
    .select({ isShared: workoutTemplates.isShared, shareToken: workoutTemplates.shareToken })
    .from(workoutTemplates)
    .where(eq(workoutTemplates.id, templateId))
    .limit(1);

  if (!template) throw new Error("Template not found");

  if (template.isShared) {
    await db
      .update(workoutTemplates)
      .set({ isShared: false })
      .where(eq(workoutTemplates.id, templateId));

    revalidatePath(`/workouts/${templateId}`);
    return { shared: false, shareUrl: null };
  } else {
    const shareToken =
      template.shareToken ?? crypto.randomUUID().replace(/-/g, "").slice(0, 16);

    await db
      .update(workoutTemplates)
      .set({ isShared: true, shareToken })
      .where(eq(workoutTemplates.id, templateId));

    revalidatePath(`/workouts/${templateId}`);
    return { shared: true, shareToken };
  }
}

export async function getSharedTemplate(shareToken: string) {
  const result = await db.query.workoutTemplates.findFirst({
    where: and(
      eq(workoutTemplates.shareToken, shareToken),
      eq(workoutTemplates.isShared, true)
    ),
    with: {
      templateExercises: {
        with: {
          exercise: {
            with: {
              exerciseMuscles: {
                with: { muscle: true },
              },
            },
          },
        },
        orderBy: (te, { asc }) => [asc(te.orderIndex)],
      },
    },
  });

  if (!result) throw new Error("Shared template not found");
  return result;
}

export async function importSharedTemplate(shareToken: string) {
  const { profileId } = await requireAuth();
  const shared = await getSharedTemplate(shareToken);

  const [newTemplate] = await db
    .insert(workoutTemplates)
    .values({
      name: shared.name,
      description: shared.description,
      userId: profileId,
    })
    .returning();

  if (shared.templateExercises.length > 0) {
    const exercisesToInsert = shared.templateExercises
      .filter((te) => te.exercise)
      .map((te) => ({
        templateId: newTemplate.id,
        exerciseId: te.exerciseId,
        orderIndex: te.orderIndex,
        targetSets: te.targetSets,
        targetReps: te.targetReps,
        targetWeight: te.targetWeight,
      }));

    if (exercisesToInsert.length > 0) {
      await db.insert(templateExercises).values(exercisesToInsert);
    }
  }

  redirect(`/workouts/${newTemplate.id}`);
}
