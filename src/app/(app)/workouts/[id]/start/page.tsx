import { getTemplate } from "@/lib/actions/templates";
import {
  startSession,
  getLastSessionForExercise,
} from "@/lib/actions/sessions";
import { ActiveWorkoutClient } from "./client";
import { notFound } from "next/navigation";

interface StartWorkoutPageProps {
  params: Promise<{ id: string }>;
}

export default async function StartWorkoutPage({
  params,
}: StartWorkoutPageProps) {
  const { id } = await params;

  let template;
  try {
    template = await getTemplate(id);
  } catch {
    notFound();
  }

  // Create a new session
  const session = await startSession(id);

  // Fetch previous session data for each exercise
  const previousSetsMap: Record<
    string,
    { set_number: number; weight: number; reps: number; rpe: number | null }[] | null
  > = {};

  await Promise.all(
    template.template_exercises.map(
      async (te: { exercise_id: string }) => {
        previousSetsMap[te.exercise_id] =
          await getLastSessionForExercise(te.exercise_id);
      }
    )
  );

  return (
    <ActiveWorkoutClient
      sessionId={session.id}
      templateName={template.name}
      templateExercises={template.template_exercises}
      previousSetsMap={previousSetsMap}
    />
  );
}
