import { getProfile } from "@/lib/actions/profile";
import { auth } from "@/lib/auth";
import { ProfileForm } from "./client";

export default async function ProfilePage() {
  const session = await auth();
  const profile = await getProfile();

  return <ProfileForm profile={profile} email={session?.user?.email ?? ""} />;
}
