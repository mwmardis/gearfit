import { getWeeklyMuscleCoverage } from "@/lib/actions/history";
import { getTemplates } from "@/lib/actions/templates";
import { createClient } from "@/lib/supabase/server";
import { MuscleCoverage } from "@/components/dashboard/muscle-coverage";
import { TodaysWorkout } from "@/components/dashboard/todays-workout";
import { RecentSessions } from "@/components/dashboard/recent-sessions";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { Flame } from "lucide-react";

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const [coverage, templates, recentSessionsData] = await Promise.all([
    getWeeklyMuscleCoverage(),
    getTemplates(),
    supabase
      .from("workout_sessions")
      .select(
        `
        id,
        date,
        duration_minutes,
        template:workout_templates (name),
        session_sets (id)
      `
      )
      .eq("user_id", user!.id)
      .eq("completed", true)
      .order("date", { ascending: false })
      .limit(5),
  ]);

  const todaysTemplate = templates.length > 0 ? templates[0] : null;

  const recentSessions = (recentSessionsData.data ?? []).map((s) => ({
    id: s.id,
    date: s.date,
    duration_minutes: s.duration_minutes,
    template: s.template as unknown as { name: string } | null,
    totalSets: (s.session_sets as unknown as { id: string }[]).length,
  }));

  const firstName = user?.user_metadata?.display_name?.split(" ")[0] ?? "there";

  return (
    <div className="stagger-children space-y-8">
      {/* Hero greeting */}
      <div className="relative">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-energy shadow-lg">
            <Flame className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="font-display text-3xl font-extrabold tracking-tight">
              Hey, <span className="gradient-text">{firstName}</span>
            </h1>
            <p className="text-sm text-muted-foreground">
              Let&apos;s crush it today
            </p>
          </div>
        </div>
      </div>

      {/* Today's workout — hero card */}
      <TodaysWorkout template={todaysTemplate} />

      {/* Two-column grid */}
      <div className="grid gap-6 md:grid-cols-2">
        <MuscleCoverage coverage={coverage} />
        <QuickActions />
      </div>

      {/* Recent sessions */}
      <RecentSessions sessions={recentSessions} />
    </div>
  );
}
