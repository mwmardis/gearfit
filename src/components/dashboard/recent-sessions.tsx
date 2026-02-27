import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Clock, ChevronRight, Activity } from "lucide-react";

interface RecentSession {
  id: string;
  date: string;
  duration_minutes: number | null;
  template: { name: string } | null;
  totalSets: number;
}

interface RecentSessionsProps {
  sessions: RecentSession[];
}

export function RecentSessions({ sessions }: RecentSessionsProps) {
  if (sessions.length === 0) {
    return (
      <Card className="card-hover">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-chart-5/15">
              <Activity className="h-3.5 w-3.5 text-chart-5" />
            </div>
            <CardTitle className="font-display text-sm font-bold">
              Recent Workouts
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            No workouts logged yet. Start your first workout!
          </p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="card-hover">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-chart-5/15">
              <Activity className="h-3.5 w-3.5 text-chart-5" />
            </div>
            <CardTitle className="font-display text-sm font-bold">
              Recent Workouts
            </CardTitle>
          </div>
          <Link
            href="/history"
            className="group flex items-center gap-1 text-xs font-medium text-muted-foreground transition-colors hover:text-primary"
          >
            View all
            <ChevronRight className="h-3 w-3 transition-transform group-hover:translate-x-0.5" />
          </Link>
        </div>
      </CardHeader>
      <CardContent className="space-y-2">
        {sessions.map((session, i) => (
          <Link
            key={session.id}
            href={`/history/${session.id}`}
            className="group flex items-center justify-between rounded-xl border border-border/50 p-3 transition-all duration-200 hover:border-primary/20 hover:bg-primary/5"
            style={{ animationDelay: `${i * 80}ms` }}
          >
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-muted/80 font-mono text-xs font-bold text-muted-foreground">
                {new Date(session.date + "T12:00:00").toLocaleDateString(
                  "en-US",
                  { day: "numeric" }
                )}
              </div>
              <div>
                <p className="text-sm font-semibold transition-colors group-hover:text-primary">
                  {session.template?.name ?? "Quick Workout"}
                </p>
                <p className="text-xs text-muted-foreground">
                  {new Date(session.date + "T12:00:00").toLocaleDateString(
                    "en-US",
                    { month: "short", day: "numeric" }
                  )}
                  {" · "}
                  {session.totalSets} sets
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {session.duration_minutes && (
                <span className="flex items-center gap-1 rounded-lg bg-muted/50 px-2 py-1 text-xs font-medium text-muted-foreground">
                  <Clock className="h-3 w-3" />
                  {session.duration_minutes}m
                </span>
              )}
              <ChevronRight className="h-4 w-4 text-muted-foreground/50 transition-transform group-hover:translate-x-0.5 group-hover:text-primary" />
            </div>
          </Link>
        ))}
      </CardContent>
    </Card>
  );
}
