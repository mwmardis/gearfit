// src/lib/actions/exercises.ts
"use server";

import { db } from "@/lib/db";
import {
  exercises,
  exerciseEquipment,
  exerciseMuscles,
  equipmentProfiles,
  equipmentProfileItems,
} from "@/lib/db/schema";
import { eq, ilike, and } from "drizzle-orm";
import { getOptionalAuth } from "@/lib/auth-utils";

export interface ExerciseFilters {
  muscleGroup?: string;
  availableOnly?: boolean;
  search?: string;
}

export async function getExercises(filters: ExerciseFilters = {}) {
  let allExercises = await db.query.exercises.findMany({
    with: {
      exerciseEquipment: {
        with: { equipment: true },
      },
      exerciseMuscles: {
        with: { muscle: true },
      },
    },
    orderBy: (e, { asc }) => [asc(e.name)],
    ...(filters.search
      ? { where: ilike(exercises.name, `%${filters.search}%`) }
      : {}),
  });

  // Filter by muscle group
  if (filters.muscleGroup) {
    allExercises = allExercises.filter((ex) =>
      ex.exerciseMuscles.some(
        (em) => em.muscle?.muscleGroup === filters.muscleGroup && em.role === "primary"
      )
    );
  }

  // Filter by available equipment
  if (filters.availableOnly) {
    const authUser = await getOptionalAuth();
    if (authUser) {
      const activeProfile = await db.query.equipmentProfiles.findFirst({
        where: and(
          eq(equipmentProfiles.userId, authUser.profileId),
          eq(equipmentProfiles.isActive, true)
        ),
      });

      if (activeProfile) {
        const profileItems = await db
          .select({ equipmentId: equipmentProfileItems.equipmentId })
          .from(equipmentProfileItems)
          .where(eq(equipmentProfileItems.equipmentProfileId, activeProfile.id));

        const availableIds = new Set(profileItems.map((i) => i.equipmentId));

        allExercises = allExercises.filter((ex) => {
          const required = ex.exerciseEquipment.map((ee) => ee.equipment?.id);
          return required.every((id) => id && availableIds.has(id));
        });
      }
    }
  }

  return allExercises;
}

export async function getExercise(id: string) {
  const result = await db.query.exercises.findFirst({
    where: eq(exercises.id, id),
    with: {
      exerciseEquipment: {
        with: { equipment: true },
      },
      exerciseMuscles: {
        with: { muscle: true },
      },
    },
  });

  if (!result) throw new Error("Exercise not found");
  return result;
}

export async function getAvailableExercises() {
  return getExercises({ availableOnly: true });
}
