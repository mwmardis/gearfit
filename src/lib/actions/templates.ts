// src/lib/actions/templates.ts
"use server";

import { db } from "@/lib/db";
import { workoutTemplates, templateExercises } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function getTemplates() {
  const { profileId } = await requireAuth();

  return db.query.workoutTemplates.findMany({
    where: eq(workoutTemplates.userId, profileId),
    with: {
      templateExercises: {
        with: { exercise: true },
      },
    },
    orderBy: (t, { desc }) => [desc(t.updatedAt)],
  }) ?? [];
}

export async function getTemplate(id: string) {
  const result = await db.query.workoutTemplates.findFirst({
    where: eq(workoutTemplates.id, id),
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

  if (!result) throw new Error("Template not found");
  return result;
}

export async function createTemplate(formData: FormData) {
  const { profileId } = await requireAuth();
  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  const [data] = await db
    .insert(workoutTemplates)
    .values({ name, description, userId: profileId })
    .returning();

  redirect(`/workouts/${data.id}`);
}

export async function updateTemplate(id: string, formData: FormData) {
  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  await db
    .update(workoutTemplates)
    .set({ name, description, updatedAt: new Date() })
    .where(eq(workoutTemplates.id, id));

  revalidatePath(`/workouts/${id}`);
  revalidatePath("/workouts");
}

export async function addExerciseToTemplate(
  templateId: string,
  exerciseId: string,
  orderIndex: number
) {
  await db.insert(templateExercises).values({
    templateId,
    exerciseId,
    orderIndex,
  });

  await db
    .update(workoutTemplates)
    .set({ updatedAt: new Date() })
    .where(eq(workoutTemplates.id, templateId));

  revalidatePath(`/workouts/${templateId}`);
}

export async function removeExerciseFromTemplate(
  templateExerciseId: string,
  templateId: string
) {
  await db
    .delete(templateExercises)
    .where(eq(templateExercises.id, templateExerciseId));

  revalidatePath(`/workouts/${templateId}`);
}

export async function reorderTemplateExercises(
  templateId: string,
  exerciseIds: string[]
) {
  await Promise.all(
    exerciseIds.map((id, index) =>
      db
        .update(templateExercises)
        .set({ orderIndex: index })
        .where(eq(templateExercises.id, id))
    )
  );

  revalidatePath(`/workouts/${templateId}`);
}

export async function updateTemplateExercise(
  id: string,
  templateId: string,
  data: { target_sets?: number; target_reps?: number; target_weight?: number | null }
) {
  await db
    .update(templateExercises)
    .set({
      ...(data.target_sets !== undefined && { targetSets: data.target_sets }),
      ...(data.target_reps !== undefined && { targetReps: data.target_reps }),
      ...(data.target_weight !== undefined && { targetWeight: data.target_weight ? String(data.target_weight) : null }),
    })
    .where(eq(templateExercises.id, id));

  revalidatePath(`/workouts/${templateId}`);
}

export async function cloneTemplate(id: string) {
  const { profileId } = await requireAuth();

  const original = await db.query.workoutTemplates.findFirst({
    where: eq(workoutTemplates.id, id),
    with: { templateExercises: true },
  });

  if (!original) throw new Error("Template not found");

  const [newTemplate] = await db
    .insert(workoutTemplates)
    .values({
      name: `${original.name} (Copy)`,
      description: original.description,
      userId: profileId,
    })
    .returning();

  if (original.templateExercises.length > 0) {
    await db.insert(templateExercises).values(
      original.templateExercises.map((te) => ({
        templateId: newTemplate.id,
        exerciseId: te.exerciseId,
        orderIndex: te.orderIndex,
        targetSets: te.targetSets,
        targetReps: te.targetReps,
        targetWeight: te.targetWeight,
      }))
    );
  }

  revalidatePath("/workouts");
  redirect(`/workouts/${newTemplate.id}`);
}

export async function deleteTemplate(id: string) {
  await db.delete(workoutTemplates).where(eq(workoutTemplates.id, id));

  revalidatePath("/workouts");
  redirect("/workouts");
}
