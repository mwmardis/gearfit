"use client";

import { useState, useMemo } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowLeftRight } from "lucide-react";
import { rankSwapSuggestions } from "@/lib/utils/exercise-swap";

interface Exercise {
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

interface SwapExerciseDialogProps {
  currentExerciseId: string;
  currentExerciseName: string;
  allExercises: Exercise[];
  onSwap: (newExerciseId: string, newExerciseName: string) => void;
}

export function SwapExerciseDialog({
  currentExerciseId,
  currentExerciseName,
  allExercises,
  onSwap,
}: SwapExerciseDialogProps) {
  const [open, setOpen] = useState(false);

  const rankedSuggestions = useMemo(() => {
    const current = allExercises.find((e) => e.id === currentExerciseId);
    if (!current) return [];

    const primaryMuscles = current.exercise_muscles
      .filter((em) => em.role === "primary")
      .map((em) => em.muscle?.name ?? "")
      .filter(Boolean);

    const secondaryMuscles = current.exercise_muscles
      .filter((em) => em.role === "secondary")
      .map((em) => em.muscle?.name ?? "")
      .filter(Boolean);

    // Only consider exercises with the same primary muscles
    const candidates = allExercises
      .filter((e) => {
        if (e.id === currentExerciseId) return false;
        const ePrimary = e.exercise_muscles
          .filter((em) => em.role === "primary")
          .map((em) => em.muscle?.name ?? "")
          .filter(Boolean);
        return primaryMuscles.some((m) => ePrimary.includes(m));
      })
      .map((e) => ({
        id: e.id,
        name: e.name,
        primaryMuscles: e.exercise_muscles
          .filter((em) => em.role === "primary")
          .map((em) => em.muscle?.name ?? "")
          .filter(Boolean),
        secondaryMuscles: e.exercise_muscles
          .filter((em) => em.role === "secondary")
          .map((em) => em.muscle?.name ?? "")
          .filter(Boolean),
        equipment: e.exercise_equipment
          .map((ee) => ee.equipment?.name)
          .filter(Boolean) as string[],
      }));

    const ranked = rankSwapSuggestions(
      { primaryMuscles, secondaryMuscles },
      candidates
    );

    // Re-attach name and equipment info
    return ranked.map((r) => {
      const full = candidates.find((c) => c.id === r.id)!;
      return {
        id: r.id,
        name: full.name,
        primaryMuscles: full.primaryMuscles,
        secondaryMuscles: full.secondaryMuscles,
        equipment: full.equipment,
        matchPercent:
          secondaryMuscles.length > 0
            ? Math.round(
                (r.secondaryMuscles.filter((m) =>
                  secondaryMuscles.includes(m)
                ).length /
                  secondaryMuscles.length) *
                  100
              )
            : 100,
      };
    });
  }, [allExercises, currentExerciseId]);

  function handleSwap(exerciseId: string, exerciseName: string) {
    onSwap(exerciseId, exerciseName);
    setOpen(false);
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="ghost" size="sm" className="text-xs">
          <ArrowLeftRight className="mr-1 h-3 w-3" />
          Swap
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>Swap {currentExerciseName}</DialogTitle>
        </DialogHeader>
        <p className="text-xs text-muted-foreground">
          Alternatives ranked by muscle overlap
        </p>
        <div className="flex-1 overflow-y-auto space-y-1 min-h-0">
          {rankedSuggestions.map((suggestion) => (
            <button
              key={suggestion.id}
              className="w-full rounded-md border p-3 text-left transition-colors hover:bg-accent/50"
              onClick={() => handleSwap(suggestion.id, suggestion.name)}
            >
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium">{suggestion.name}</p>
                <Badge variant="outline" className="text-xs">
                  {suggestion.matchPercent}% match
                </Badge>
              </div>
              <div className="mt-1 flex flex-wrap gap-1">
                {suggestion.primaryMuscles.map((m) => (
                  <Badge key={m} variant="secondary" className="text-xs">
                    {m}
                  </Badge>
                ))}
              </div>
              {suggestion.equipment.length > 0 && (
                <p className="mt-1 text-xs text-muted-foreground">
                  Needs: {suggestion.equipment.join(", ")}
                </p>
              )}
            </button>
          ))}
          {rankedSuggestions.length === 0 && (
            <p className="text-center text-sm text-muted-foreground py-4">
              No alternative exercises found.
            </p>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
