import { auth } from "@/lib/auth";

/**
 * Get the authenticated user's profile ID, or throw.
 * Replaces: const supabase = await createClient();
 *           const { data: { user } } = await supabase.auth.getUser();
 */
export async function requireAuth(): Promise<{ userId: string; profileId: string }> {
  const session = await auth();
  if (!session?.user?.profileId) {
    throw new Error("Not authenticated");
  }
  return {
    userId: session.user.id,
    profileId: session.user.profileId,
  };
}

/**
 * Get the authenticated user if logged in, or null.
 */
export async function getOptionalAuth(): Promise<{ userId: string; profileId: string } | null> {
  const session = await auth();
  if (!session?.user?.profileId) return null;
  return {
    userId: session.user.id,
    profileId: session.user.profileId,
  };
}
