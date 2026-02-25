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

  if (error) return { error: error.message };

  if (equipmentIds.length > 0) {
    const items = equipmentIds.map((equipment_id) => ({
      equipment_profile_id: profile.id,
      equipment_id,
    }));
    const { error: itemsError } = await supabase
      .from("equipment_profile_items")
      .insert(items);

    if (itemsError) return { error: itemsError.message };
  }

  revalidatePath("/equipment");
  return { success: true };
}

export async function setActiveProfile(profileId: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("equipment_profiles")
    .update({ is_active: true })
    .eq("id", profileId);

  if (error) return { error: error.message };

  revalidatePath("/equipment");
  return { success: true };
}

export async function deleteEquipmentProfile(profileId: string) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("equipment_profiles")
    .delete()
    .eq("id", profileId);

  if (error) return { error: error.message };

  revalidatePath("/equipment");
  return { success: true };
}
