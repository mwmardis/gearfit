import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { Sidebar } from "@/components/nav/sidebar";
import { MobileNav } from "@/components/nav/mobile-nav";

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  return (
    <div className="flex min-h-screen bg-mesh-light dark:bg-mesh-dark">
      <Sidebar user={user} profile={profile} />
      <main className="flex-1 pb-20 md:pb-0">
        <div className="container mx-auto max-w-4xl p-4 md:p-8">
          {children}
        </div>
      </main>
      <MobileNav />
    </div>
  );
}
