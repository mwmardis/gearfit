import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Clock } from "lucide-react";

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
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Recent Workouts</CardTitle>
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
    <Card>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base">Recent Workouts</CardTitle>
          <Link
            href="/history"
            className="text-xs text-muted-foreground hover:underline"
          >
            View all
          </Link>
        </div>
      </CardHeader>
      <CardContent className="space-y-2">
        {sessions.map((session) => (
          <Link
            key={session.id}
            href={`/history/${session.id}`}
            className="flex items-center justify-between rounded-md border p-2 transition-colors hover:bg-accent/50"
          >
            <div>
              <p className="text-sm font-medium">
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
            {session.duration_minutes && (
              <span className="flex items-center gap-1 text-xs text-muted-foreground">
                <Clock className="h-3 w-3" />
                {session.duration_minutes}m
              </span>
            )}
          </Link>
        ))}
      </CardContent>
    </Card>
  );
}
