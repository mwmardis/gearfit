import Link from "next/link";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

interface ExerciseCardProps {
  exercise: {
    id: string;
    name: string;
    exerciseEquipment: {
      equipment: { id: string; name: string } | null;
    }[];
    exerciseMuscles: {
      role: string;
      muscle: { id: string; name: string; muscleGroup: string } | null;
    }[];
  };
}

export function ExerciseCard({ exercise }: ExerciseCardProps) {
  const primaryMuscles = exercise.exerciseMuscles
    .filter((em) => em.role === "primary")
    .map((em) => em.muscle?.name)
    .filter(Boolean);

  const equipmentNames = exercise.exerciseEquipment
    .map((ee) => ee.equipment?.name)
    .filter(Boolean);

  return (
    <Link href={`/exercises/${exercise.id}`}>
      <Card className="h-full transition-colors hover:bg-accent/50">
        <CardHeader className="pb-2">
          <CardTitle className="text-base">{exercise.name}</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="mb-2 flex flex-wrap gap-1">
            {primaryMuscles.map((name) => (
              <Badge key={name} variant="default" className="text-xs">
                {name}
              </Badge>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            {equipmentNames.join(", ") || "No equipment"}
          </p>
        </CardContent>
      </Card>
    </Link>
  );
}
