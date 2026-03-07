import { getExercise } from "@/lib/actions/exercises";
import { getExerciseHistory, getPersonalBests } from "@/lib/actions/history";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ExerciseProgressChart } from "@/components/exercises/exercise-progress-chart";
import { notFound } from "next/navigation";

interface ExerciseDetailPageProps {
  params: Promise<{ id: string }>;
}

export default async function ExerciseDetailPage({
  params,
}: ExerciseDetailPageProps) {
  const { id } = await params;
  let exercise;
  try {
    exercise = await getExercise(id);
  } catch {
    notFound();
  }

  const [history, personalBests] = await Promise.all([
    getExerciseHistory(id),
    getPersonalBests(id),
  ]);

  const primaryMuscles = exercise.exerciseMuscles
    .filter((em: { role: string }) => em.role === "primary")
    .map((em: { muscle: { name: string } | null }) => em.muscle?.name)
    .filter(Boolean);

  const secondaryMuscles = exercise.exerciseMuscles
    .filter((em: { role: string }) => em.role === "secondary")
    .map((em: { muscle: { name: string } | null }) => em.muscle?.name)
    .filter(Boolean);

  const equipmentNames = exercise.exerciseEquipment
    .map(
      (ee: { equipment: { name: string } | null }) => ee.equipment?.name
    )
    .filter(Boolean);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">{exercise.name}</h1>
        {exercise.description && (
          <p className="text-muted-foreground">{exercise.description}</p>
        )}
      </div>

      {exercise.instructions && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Instructions</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm">{exercise.instructions}</p>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Muscles Worked</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div>
            <p className="mb-1 text-xs font-medium text-muted-foreground">
              Primary
            </p>
            <div className="flex flex-wrap gap-1">
              {primaryMuscles.map((name: string) => (
                <Badge key={name}>{name}</Badge>
              ))}
            </div>
          </div>
          {secondaryMuscles.length > 0 && (
            <div>
              <p className="mb-1 text-xs font-medium text-muted-foreground">
                Secondary
              </p>
              <div className="flex flex-wrap gap-1">
                {secondaryMuscles.map((name: string) => (
                  <Badge key={name} variant="secondary">
                    {name}
                  </Badge>
                ))}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Required Equipment</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-1">
            {equipmentNames.map((name: string) => (
              <Badge key={name} variant="outline">
                {name}
              </Badge>
            ))}
          </div>
        </CardContent>
      </Card>

      <ExerciseProgressChart data={history} personalBests={personalBests} />
    </div>
  );
}
