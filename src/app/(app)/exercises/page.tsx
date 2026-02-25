import { getExercises } from "@/lib/actions/exercises";
import { ExercisesPageClient } from "./client";

export default async function ExercisesPage() {
  const exercises = await getExercises();
  return <ExercisesPageClient initialExercises={exercises} />;
}
