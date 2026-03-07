// src/lib/actions/equipment.ts
"use server";

import { db } from "@/lib/db";
import { equipment, equipmentProfiles, equipmentProfileItems } from "@/lib/db/schema";
import { eq, and, asc } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { validateCustomEquipmentInput } from "@/lib/validators/equipment";

export { validateCustomEquipmentInput };

export async function getEquipmentList() {
  return db
    .select()
    .from(equipment)
    .orderBy(asc(equipment.category), asc(equipment.name));
}

export async function getEquipmentProfiles() {
  const { profileId } = await requireAuth();

  const profilesData = await db.query.equipmentProfiles.findMany({
    where: eq(equipmentProfiles.userId, profileId),
    with: {
      equipmentProfileItems: {
        with: {
          equipment: true,
        },
      },
    },
    orderBy: (ep, { desc }) => [desc(ep.createdAt)],
  });

  return profilesData;
}

export async function createEquipmentProfile(formData: FormData) {
  const { profileId } = await requireAuth();

  const name = formData.get("name") as string;
  const equipmentIds = formData.getAll("equipment") as string[];

  const [profile] = await db
    .insert(equipmentProfiles)
    .values({ userId: profileId, name, isActive: false })
    .returning();

  if (equipmentIds.length > 0) {
    await db.insert(equipmentProfileItems).values(
      equipmentIds.map((equipmentId) => ({
        equipmentProfileId: profile.id,
        equipmentId,
      }))
    );
  }

  revalidatePath("/equipment");
}

export async function setActiveProfile(profileId: string) {
  await db
    .update(equipmentProfiles)
    .set({ isActive: true })
    .where(eq(equipmentProfiles.id, profileId));

  revalidatePath("/equipment");
}

export async function deleteEquipmentProfile(profileId: string) {
  await db
    .delete(equipmentProfiles)
    .where(eq(equipmentProfiles.id, profileId));

  revalidatePath("/equipment");
}

export async function createCustomEquipment(formData: FormData) {
  const { profileId } = await requireAuth();

  const rawName = formData.get("name");
  const name = typeof rawName === "string" ? rawName.trim() : "";
  const rawCategory = formData.get("category");
  const category = typeof rawCategory === "string" ? rawCategory : "";

  const validation = validateCustomEquipmentInput(name, category);
  if (!validation.valid) throw new Error(validation.error);

  const [data] = await db
    .insert(equipment)
    .values({ name, category, isCustom: true, createdBy: profileId })
    .returning();

  revalidatePath("/equipment");
  return data;
}
