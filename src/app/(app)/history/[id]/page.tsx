import { getHistorySession } from "@/lib/actions/history";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { notFound } from "next/navigation";
import { Clock, Calendar } from "lucide-react";
import Link from "next/link";

interface SessionDetailPageProps {
  params: Promise<{ id: string }>;
}

export default async function SessionDetailPage({
  params,
}: SessionDetailPageProps) {
  const { id } = await params;

  let session;
  try {
    session = await getHistorySession(id);
  } catch {
    notFound();
  }

  // Group sets by exercise
  const exerciseGroups = new Map<
    string,
    {
      name: string;
      exerciseId: string;
      sets: { set_number: number; weight: number; reps: number; rpe: number | null }[];
    }
  >();

  for (const set of session.session_sets) {
    const exerciseId = set.exercise_id;
    const exerciseName =
      (set.exercise as { name: string } | null)?.name ?? "Unknown";

    if (!exerciseGroups.has(exerciseId)) {
      exerciseGroups.set(exerciseId, {
        name: exerciseName,
        exerciseId,
        sets: [],
      });
    }
    exerciseGroups.get(exerciseId)!.sets.push({
      set_number: set.set_number,
      weight: set.weight,
      reps: set.reps,
      rpe: set.rpe,
    });
  }

  // Sort sets within each group
  for (const group of exerciseGroups.values()) {
    group.sets.sort((a, b) => a.set_number - b.set_number);
  }

  const dateStr = new Date(session.date + "T12:00:00").toLocaleDateString(
    "en-US",
    {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    }
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">
          {(session.template as { name: string } | null)?.name ??
            "Quick Workout"}
        </h1>
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1">
            <Calendar className="h-4 w-4" />
            {dateStr}
          </span>
          {session.duration_minutes && (
            <span className="flex items-center gap-1">
              <Clock className="h-4 w-4" />
              {session.duration_minutes} min
            </span>
          )}
        </div>
      </div>

      {session.notes && (
        <Card>
          <CardContent className="p-4">
            <p className="text-sm">{session.notes}</p>
          </CardContent>
        </Card>
      )}

      <div className="space-y-4">
        {Array.from(exerciseGroups.values()).map((group) => (
          <Card key={group.exerciseId}>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">
                <Link
                  href={`/exercises/${group.exerciseId}`}
                  className="hover:underline"
                >
                  {group.name}
                </Link>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-1">
                {group.sets.map((set) => (
                  <div
                    key={set.set_number}
                    className="flex items-center gap-2 text-sm"
                  >
                    <Badge variant="outline" className="w-7 justify-center text-xs">
                      {set.set_number}
                    </Badge>
                    <span>
                      {set.weight} lbs × {set.reps} reps
                    </span>
                    {set.rpe && (
                      <span className="text-xs text-muted-foreground">
                        RPE {set.rpe}
                      </span>
                    )}
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
