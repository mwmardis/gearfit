import Link from "next/link";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Play, Plus, Zap, Coffee } from "lucide-react";
import { type WorkoutRecommendation } from "@/lib/workout-recommender";

interface TodaysWorkoutProps {
  recommendation: WorkoutRecommendation;
  templateExercises?: {
    id: string;
    exercise: { name: string } | null;
  }[];
}

export function TodaysWorkout({
  recommendation,
  templateExercises,
}: TodaysWorkoutProps) {
  if (recommendation.type === "rest") {
    return (
      <Card className="card-hover relative overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-blue-400 via-indigo-400 to-purple-400" />
        <CardContent className="flex flex-col items-center gap-4 py-10 text-center">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-100 dark:bg-blue-900/30">
            <Coffee className="h-6 w-6 text-blue-600 dark:text-blue-400" />
          </div>
          <div>
            <p className="font-display text-base font-bold">Rest Day</p>
            <p className="mt-1 max-w-sm text-sm text-muted-foreground">
              {recommendation.reason}
            </p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!recommendation.template) {
    return (
      <Card className="card-hover overflow-hidden border-dashed">
        <CardContent className="flex flex-col items-center gap-4 py-10 text-center">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-muted">
            <Plus className="h-6 w-6 text-muted-foreground" />
          </div>
          <div>
            <p className="font-display text-base font-bold">
              No workout template yet
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              Create your first workout to get started
            </p>
          </div>
          <Button asChild className="btn-glow bg-gradient-energy text-white">
            <Link href="/workouts/new">
              <Plus className="mr-2 h-4 w-4" />
              Create Workout
            </Link>
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="card-hover group relative overflow-hidden">
      <div className="absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-primary via-chart-2 to-chart-3" />

      <CardContent className="pt-6">
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-gradient-energy shadow-lg transition-transform duration-300 group-hover:scale-105">
              <Zap className="h-5 w-5 text-white" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-wider text-primary">
                Recommended Workout
              </p>
              <p className="mt-0.5 font-display text-lg font-bold">
                {recommendation.template.name}
              </p>
              <p className="mt-1 text-xs text-muted-foreground">
                {recommendation.reason}
              </p>
              {templateExercises && templateExercises.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {templateExercises.slice(0, 5).map((te) => (
                    <Badge
                      key={te.id}
                      variant="secondary"
                      className="rounded-lg text-xs font-medium"
                    >
                      {te.exercise?.name ?? "Unknown"}
                    </Badge>
                  ))}
                  {templateExercises.length > 5 && (
                    <Badge variant="outline" className="rounded-lg text-xs">
                      +{templateExercises.length - 5} more
                    </Badge>
                  )}
                </div>
              )}
            </div>
          </div>

          <Button
            asChild
            className="btn-glow shrink-0 bg-gradient-energy text-white shadow-lg"
          >
            <Link href={`/workouts/${recommendation.template.id}/start`}>
              <Play className="mr-1.5 h-4 w-4" />
              Start
            </Link>
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
