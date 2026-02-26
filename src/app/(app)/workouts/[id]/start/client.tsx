"use client";

import { useState, useEffect, useTransition, useCallback } from "react";
import { useRouter } from "next/navigation";
import { ActiveExercise } from "@/components/workout-session/active-exercise";
import { FinishWorkoutDialog } from "@/components/workout-session/finish-workout-dialog";
import { SwapExerciseDialog } from "@/components/workout-session/swap-exercise-dialog";
import { logSet, finishSession } from "@/lib/actions/sessions";
import { Timer } from "lucide-react";

interface PreviousSet {
  set_number: number;
  weight: number;
  reps: number;
  rpe: number | null;
}

interface TemplateExercise {
  id: string;
  exercise_id: string;
  target_sets: number;
  target_reps: number;
  target_weight: number | null;
  exercise: {
    id: string;
    name: string;
  } | null;
}

interface LoggedSet {
  setNumber: number;
  weight: number;
  reps: number;
}

interface AllExercise {
  id: string;
  name: string;
  exercise_muscles: {
    role: string;
    muscle: { name: string; muscle_group: string } | null;
  }[];
  exercise_equipment: {
    equipment: { name: string } | null;
  }[];
}

interface ActiveWorkoutClientProps {
  sessionId: string;
  templateName: string;
  templateExercises: TemplateExercise[];
  previousSetsMap: Record<string, PreviousSet[] | null>;
  overloadMap: Record<string, boolean>;
  allExercises: AllExercise[];
}

export function ActiveWorkoutClient({
  sessionId,
  templateName,
  templateExercises,
  previousSetsMap,
  overloadMap,
  allExercises,
}: ActiveWorkoutClientProps) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [startTime] = useState(() => Date.now());
  const [elapsed, setElapsed] = useState(0);
  const [loggedSets, setLoggedSets] = useState<
    Record<string, LoggedSet[]>
  >({});
  // Track swapped exercises: templateExerciseId -> { exerciseId, exerciseName }
  const [swaps, setSwaps] = useState<
    Record<string, { exerciseId: string; exerciseName: string }>
  >({});

  useEffect(() => {
    const interval = setInterval(() => {
      setElapsed(Math.floor((Date.now() - startTime) / 1000));
    }, 1000);
    return () => clearInterval(interval);
  }, [startTime]);

  const elapsedMinutes = Math.floor(elapsed / 60);
  const elapsedSeconds = elapsed % 60;

  const handleLogSet = useCallback(
    (exerciseId: string, setNumber: number, weight: number, reps: number) => {
      // Optimistic update
      setLoggedSets((prev) => {
        const existing = prev[exerciseId] ?? [];
        return {
          ...prev,
          [exerciseId]: [...existing, { setNumber, weight, reps }],
        };
      });

      // Persist to server
      startTransition(async () => {
        await logSet(sessionId, exerciseId, setNumber, weight, reps);
      });
    },
    [sessionId, startTransition]
  );

  function handleFinish(notes: string) {
    const durationMinutes = Math.max(1, Math.round(elapsed / 60));
    startTransition(async () => {
      await finishSession(sessionId, durationMinutes, notes || undefined);
      router.push("/workouts");
    });
  }

  const totalSetsLogged = Object.values(loggedSets).reduce(
    (sum, sets) => sum + sets.length,
    0
  );

  const exercisesWithSets = Object.keys(loggedSets).filter(
    (id) => loggedSets[id].length > 0
  ).length;

  return (
    <div className="space-y-6">
      {/* Header with timer */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">{templateName}</h1>
          <p className="text-muted-foreground">Active workout</p>
        </div>
        <div className="flex items-center gap-2 rounded-md bg-muted px-3 py-2">
          <Timer className="h-4 w-4 text-muted-foreground" />
          <span className="font-mono text-lg">
            {String(elapsedMinutes).padStart(2, "0")}:
            {String(elapsedSeconds).padStart(2, "0")}
          </span>
        </div>
      </div>

      {/* Exercise cards */}
      <div className="space-y-4">
        {templateExercises.map((te) => {
          const swap = swaps[te.id];
          const exerciseId = swap?.exerciseId ?? te.exercise_id;
          const exerciseName = swap?.exerciseName ?? te.exercise?.name ?? "Unknown Exercise";

          return (
            <ActiveExercise
              key={te.id}
              exerciseId={exerciseId}
              exerciseName={exerciseName}
              targetSets={te.target_sets}
              targetReps={te.target_reps}
              targetWeight={te.target_weight}
              previousSets={previousSetsMap[exerciseId] ?? null}
              loggedSets={loggedSets[exerciseId] ?? []}
              onLogSet={handleLogSet}
              suggestIncrease={overloadMap[exerciseId] ?? false}
              swapSlot={
                <SwapExerciseDialog
                  currentExerciseId={exerciseId}
                  currentExerciseName={exerciseName}
                  allExercises={allExercises}
                  onSwap={(newId, newName) =>
                    setSwaps((prev) => ({
                      ...prev,
                      [te.id]: { exerciseId: newId, exerciseName: newName },
                    }))
                  }
                />
              }
            />
          );
        })}
      </div>

      {/* Finish button */}
      <FinishWorkoutDialog
        exerciseCount={exercisesWithSets}
        totalSetsLogged={totalSetsLogged}
        durationMinutes={elapsedMinutes}
        onFinish={handleFinish}
        isPending={isPending}
      />
    </div>
  );
}
