import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { redirect } from "next/navigation";
import { Sidebar } from "@/components/nav/sidebar";
import { MobileNav } from "@/components/nav/mobile-nav";

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth();

  if (!session?.user) redirect("/login");

  const profileId = (session.user as { profileId?: string }).profileId;

  const [profile = null] = profileId
    ? await db.select().from(profiles).where(eq(profiles.id, profileId)).limit(1)
    : [null];

  return (
    <div className="flex min-h-screen bg-mesh">
      <Sidebar user={session.user} profile={profile} />
      <main className="flex-1 pb-20 md:pb-0">
        <div className="container mx-auto max-w-4xl p-4 md:p-8">
          {children}
        </div>
      </main>
      <MobileNav />
    </div>
  );
}
