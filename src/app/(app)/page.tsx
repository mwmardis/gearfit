import { getWeeklyMuscleCoverage } from "@/lib/actions/history";
import { getTemplates } from "@/lib/actions/templates";
import { createClient } from "@/lib/supabase/server";
import { MuscleCoverage } from "@/components/dashboard/muscle-coverage";
import { TodaysWorkout } from "@/components/dashboard/todays-workout";
import { RecentSessions } from "@/components/dashboard/recent-sessions";
import { QuickActions } from "@/components/dashboard/quick-actions";

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const [coverage, templates, recentSessionsData] = await Promise.all([
    getWeeklyMuscleCoverage(),
    getTemplates(),
    // Fetch last 5 completed sessions
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

  // Most recently updated template for "today's workout"
  const todaysTemplate = templates.length > 0 ? templates[0] : null;

  // Format recent sessions
  const recentSessions = (recentSessionsData.data ?? []).map((s) => ({
    id: s.id,
    date: s.date,
    duration_minutes: s.duration_minutes,
    template: s.template as unknown as { name: string } | null,
    totalSets: (s.session_sets as unknown as { id: string }[]).length,
  }));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Welcome to GearFit</p>
      </div>

      <TodaysWorkout template={todaysTemplate} />

      <div className="grid gap-4 md:grid-cols-2">
        <MuscleCoverage coverage={coverage} />
        <QuickActions />
      </div>

      <RecentSessions sessions={recentSessions} />
    </div>
  );
}
