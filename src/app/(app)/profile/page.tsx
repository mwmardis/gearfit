import { getProfile } from "@/lib/actions/profile";
import { createClient } from "@/lib/supabase/server";
import { ProfileForm } from "./client";

export default async function ProfilePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const profile = await getProfile();

  return <ProfileForm profile={profile} email={user!.email ?? ""} />;
}
