import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Play } from "lucide-react";

interface TodaysWorkoutProps {
  template: {
    id: string;
    name: string;
    template_exercises: {
      id: string;
      exercise: { name: string } | null;
    }[];
  } | null;
}

export function TodaysWorkout({ template }: TodaysWorkoutProps) {
  if (!template) {
    return (
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Today&apos;s Workout</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground mb-3">
            No recent workout template. Create one to get started!
          </p>
          <Button asChild size="sm">
            <Link href="/workouts/new">Create Workout</Link>
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base">Today&apos;s Workout</CardTitle>
          <Button asChild size="sm">
            <Link href={`/workouts/${template.id}/start`}>
              <Play className="mr-1 h-3 w-3" />
              Start
            </Link>
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-sm font-medium mb-2">{template.name}</p>
        <div className="flex flex-wrap gap-1">
          {template.template_exercises.slice(0, 5).map((te) => (
            <Badge key={te.id} variant="secondary" className="text-xs">
              {te.exercise?.name ?? "Unknown"}
            </Badge>
          ))}
          {template.template_exercises.length > 5 && (
            <Badge variant="outline" className="text-xs">
              +{template.template_exercises.length - 5} more
            </Badge>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
