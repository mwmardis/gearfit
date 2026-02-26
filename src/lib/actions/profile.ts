"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function getProfile() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  if (error) throw error;
  return data;
}

export async function updateProfile(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Not authenticated");

  const displayName = formData.get("display_name") as string;
  const preferredUnits = formData.get("preferred_units") as string;
  const overloadSessionsThreshold = Number(
    formData.get("overload_sessions_threshold")
  );
  const overloadIncrementLbs = Number(formData.get("overload_increment_lbs"));
  const overloadIncrementKg = Number(formData.get("overload_increment_kg"));

  const { error } = await supabase
    .from("profiles")
    .update({
      display_name: displayName || null,
      preferred_units: preferredUnits,
      overload_sessions_threshold: overloadSessionsThreshold,
      overload_increment_lbs: overloadIncrementLbs,
      overload_increment_kg: overloadIncrementKg,
      updated_at: new Date().toISOString(),
    })
    .eq("id", user.id);

  if (error) throw error;
  revalidatePath("/profile");
  revalidatePath("/", "layout");
}
