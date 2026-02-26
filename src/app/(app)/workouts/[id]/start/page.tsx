import { getTemplate } from "@/lib/actions/templates";
import {
  startSession,
  getLastSessionForExercise,
} from "@/lib/actions/sessions";
import { getExerciseHistory } from "@/lib/actions/history";
import { shouldSuggestIncrease } from "@/lib/utils/progressive-overload";
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

  // Fetch previous session data and overload hints for each exercise
  const previousSetsMap: Record<
    string,
    { set_number: number; weight: number; reps: number; rpe: number | null }[] | null
  > = {};
  const overloadMap: Record<string, boolean> = {};

  await Promise.all(
    template.template_exercises.map(
      async (te: { exercise_id: string; target_reps: number }) => {
        const [previousSets, history] = await Promise.all([
          getLastSessionForExercise(te.exercise_id),
          getExerciseHistory(te.exercise_id, 3),
        ]);

        previousSetsMap[te.exercise_id] = previousSets;

        // Check progressive overload: did the user hit target reps in the last 3 sessions?
        if (history.length >= 3) {
          const recentSessions = history.slice(-3).reverse().map((h) => ({
            sets: [{ reps: Math.round(h.totalVolume / (h.maxWeight || 1)), targetReps: te.target_reps }],
          }));
          overloadMap[te.exercise_id] = shouldSuggestIncrease(recentSessions, 3);
        }
      }
    )
  );

  return (
    <ActiveWorkoutClient
      sessionId={session.id}
      templateName={template.name}
      templateExercises={template.template_exercises}
      previousSetsMap={previousSetsMap}
      overloadMap={overloadMap}
    />
  );
}
