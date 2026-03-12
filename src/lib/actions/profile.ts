// src/lib/actions/profile.ts
"use server";

import { db } from "@/lib/db";
import { profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";

export async function getProfile() {
  const { profileId } = await requireAuth();

  const [profile] = await db
    .select()
    .from(profiles)
    .where(eq(profiles.id, profileId))
    .limit(1);

  if (!profile) throw new Error("Profile not found");
  return profile;
}

export async function updateProfile(formData: FormData) {
  const { profileId } = await requireAuth();

  const displayName = formData.get("display_name") as string;
  const preferredUnits = formData.get("preferred_units") as string;
  const overloadSessionsThreshold = Number(formData.get("overload_sessions_threshold"));
  const overloadIncrementLbs = Number(formData.get("overload_increment_lbs"));
  const overloadIncrementKg = Number(formData.get("overload_increment_kg"));
  const trainingGoal = formData.get("training_goal") as string;

  await db
    .update(profiles)
    .set({
      displayName: displayName || null,
      preferredUnits,
      trainingGoal: trainingGoal || "hypertrophy",
      overloadSessionsThreshold,
      overloadIncrementLbs: String(overloadIncrementLbs),
      overloadIncrementKg: String(overloadIncrementKg),
      updatedAt: new Date(),
    })
    .where(eq(profiles.id, profileId));

  revalidatePath("/profile");
  revalidatePath("/", "layout");
}
