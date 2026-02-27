"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function getEquipmentList() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("equipment")
    .select("*")
    .order("category")
    .order("name");

  if (error) throw error;
  return data;
}

export async function getEquipmentProfiles() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("equipment_profiles")
    .select(
      `
      *,
      equipment_profile_items (
        equipment_id,
        equipment:equipment (id, name, category)
      )
    `
    )
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}

export async function createEquipmentProfile(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const name = formData.get("name") as string;
  const equipmentIds = formData.getAll("equipment") as string[];

  const { data: profile, error } = await supabase
    .from("equipment_profiles")
    .insert({ user_id: user.id, name, is_active: false })
    .select()
    .single();

  if (error) throw new Error(error.message);

  if (equipmentIds.length > 0) {
    const items = equipmentIds.map((equipment_id) => ({
      equipment_profile_id: profile.id,
      equipment_id,
    }));
    const { error: itemsError } = await supabase
      .from("equipment_profile_items")
      .insert(items);

    if (itemsError) throw new Error(itemsError.message);
  }

  revalidatePath("/equipment");
}

export async function setActiveProfile(profileId: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("equipment_profiles")
    .update({ is_active: true })
    .eq("id", profileId);

  if (error) throw new Error(error.message);

  revalidatePath("/equipment");
}

export async function deleteEquipmentProfile(profileId: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("equipment_profiles")
    .delete()
    .eq("id", profileId);

  if (error) throw new Error(error.message);

  revalidatePath("/equipment");
}

const VALID_CATEGORIES = [
  "free_weights",
  "benches",
  "racks",
  "machines",
  "bodyweight",
  "accessories",
] as const;

export function validateCustomEquipmentInput(
  name: string,
  category: string
): { valid: boolean; error?: string } {
  if (!name || name.trim().length === 0) {
    return { valid: false, error: "Equipment name is required" };
  }
  if (name.length > 100) {
    return { valid: false, error: "Equipment name must be 100 characters or less" };
  }
  if (!VALID_CATEGORIES.includes(category as (typeof VALID_CATEGORIES)[number])) {
    return { valid: false, error: "Invalid equipment category" };
  }
  return { valid: true };
}

export async function createCustomEquipment(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const name = (formData.get("name") as string).trim();
  const category = formData.get("category") as string;

  const validation = validateCustomEquipmentInput(name, category);
  if (!validation.valid) throw new Error(validation.error);

  const { data, error } = await supabase
    .from("equipment")
    .insert({ name, category, is_custom: true, created_by: user.id })
    .select()
    .single();

  if (error) throw new Error(error.message);

  revalidatePath("/equipment");
  return data;
}
