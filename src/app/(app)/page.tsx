import { getWeeklyVolumeStatus, getWorkoutRecommendation } from "@/lib/actions/history";
import { getTemplates } from "@/lib/actions/templates";
import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { workoutSessions, workoutTemplates } from "@/lib/db/schema";
import { eq, desc, and, sql } from "drizzle-orm";
import { VolumeReport } from "@/components/dashboard/volume-report";
import { TodaysWorkout } from "@/components/dashboard/todays-workout";
import { RecentSessions } from "@/components/dashboard/recent-sessions";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { Flame } from "lucide-react";

export default async function DashboardPage() {
  const session = await auth();
  const profileId = (session?.user as { profileId?: string })?.profileId;

  const [recommendation, volumeStatus, templates, recentSessionsData] =
    await Promise.all([
      getWorkoutRecommendation(),
      getWeeklyVolumeStatus(),
      getTemplates(),
      profileId
        ? db
            .select({
              id: workoutSessions.id,
              date: workoutSessions.date,
              durationMinutes: workoutSessions.durationMinutes,
              templateName: workoutTemplates.name,
              totalSets:
                sql<number>`(select count(*) from session_sets where session_id = ${workoutSessions.id})`.as(
                  "total_sets"
                ),
            })
            .from(workoutSessions)
            .leftJoin(
              workoutTemplates,
              eq(workoutSessions.templateId, workoutTemplates.id)
            )
            .where(
              and(
                eq(workoutSessions.userId, profileId),
                eq(workoutSessions.completed, true)
              )
            )
            .orderBy(desc(workoutSessions.date))
            .limit(5)
        : Promise.resolve([]),
    ]);

  // Find the recommended template's exercises for display
  const recommendedTemplate =
    recommendation.type === "workout" && recommendation.template
      ? templates.find((t) => t.id === recommendation.template!.id)
      : null;

  const recentSessions = recentSessionsData.map((s) => ({
    id: s.id,
    date: s.date,
    durationMinutes: s.durationMinutes,
    template: s.templateName ? { name: s.templateName } : null,
    totalSets: Number(s.totalSets),
  }));

  const firstName = session?.user?.name?.split(" ")[0] ?? "there";

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

      {/* Today's workout — recommendation card */}
      <TodaysWorkout
        recommendation={recommendation}
        templateExercises={recommendedTemplate?.templateExercises}
      />

      {/* Two-column grid */}
      <div className="grid gap-6 md:grid-cols-2">
        <VolumeReport volumeStatus={volumeStatus} />
        <QuickActions />
      </div>

      {/* Recent sessions */}
      <RecentSessions sessions={recentSessions} />
    </div>
  );
}
