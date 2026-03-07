import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Clock } from "lucide-react";

interface SessionSummaryProps {
  session: {
    id: string;
    date: string;
    durationMinutes: number | null;
    template: { name: string } | null;
    sessionSets: {
      exerciseId: string;
      exercise: { name: string } | null;
    }[];
  };
}

export function SessionSummary({ session }: SessionSummaryProps) {
  // Get unique exercise names
  const exercises = new Map<string, string>();
  for (const set of session.sessionSets) {
    if (set.exercise && !exercises.has(set.exerciseId)) {
      exercises.set(set.exerciseId, set.exercise.name);
    }
  }

  return (
    <Link href={`/history/${session.id}`}>
      <Card className="transition-colors hover:bg-accent/50">
        <CardContent className="p-4">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-sm font-medium">
                {session.template?.name ?? "Quick Workout"}
              </p>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.from(exercises.values())
                  .slice(0, 3)
                  .map((name) => (
                    <Badge key={name} variant="secondary" className="text-xs">
                      {name}
                    </Badge>
                  ))}
                {exercises.size > 3 && (
                  <Badge variant="outline" className="text-xs">
                    +{exercises.size - 3} more
                  </Badge>
                )}
              </div>
            </div>
            {session.durationMinutes && (
              <span className="flex items-center gap-1 text-xs text-muted-foreground">
                <Clock className="h-3 w-3" />
                {session.durationMinutes}m
              </span>
            )}
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
