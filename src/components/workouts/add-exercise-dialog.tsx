"use client";

import { useState, useTransition, useMemo } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Plus } from "lucide-react";
import { addExerciseToTemplate } from "@/lib/actions/templates";

interface Exercise {
  id: string;
  name: string;
  exercise_muscles: {
    role: string;
    muscle: { name: string; muscle_group: string } | null;
  }[];
}

interface AddExerciseDialogProps {
  templateId: string;
  currentExerciseCount: number;
  exercises: Exercise[];
  existingExerciseIds: string[];
}

export function AddExerciseDialog({
  templateId,
  currentExerciseCount,
  exercises,
  existingExerciseIds,
}: AddExerciseDialogProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [isPending, startTransition] = useTransition();

  const filtered = useMemo(() => {
    const available = exercises.filter(
      (ex) => !existingExerciseIds.includes(ex.id)
    );
    if (!search) return available;
    const lower = search.toLowerCase();
    return available.filter((ex) => ex.name.toLowerCase().includes(lower));
  }, [exercises, existingExerciseIds, search]);

  function handleAdd(exerciseId: string) {
    startTransition(async () => {
      await addExerciseToTemplate(
        templateId,
        exerciseId,
        currentExerciseCount
      );
      setOpen(false);
      setSearch("");
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Plus className="mr-2 h-4 w-4" />
          Add Exercise
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[80vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>Add Exercise</DialogTitle>
        </DialogHeader>
        <Input
          placeholder="Search exercises..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <div className="flex-1 overflow-y-auto space-y-1 min-h-0">
          {filtered.map((exercise) => {
            const primaryMuscles = exercise.exercise_muscles
              .filter((em) => em.role === "primary")
              .map((em) => em.muscle?.name)
              .filter(Boolean);

            return (
              <button
                key={exercise.id}
                className="w-full rounded-md border p-3 text-left transition-colors hover:bg-accent/50 disabled:opacity-50"
                disabled={isPending}
                onClick={() => handleAdd(exercise.id)}
              >
                <p className="text-sm font-medium">{exercise.name}</p>
                <div className="mt-1 flex flex-wrap gap-1">
                  {primaryMuscles.map((name) => (
                    <Badge
                      key={name}
                      variant="secondary"
                      className="text-xs"
                    >
                      {name}
                    </Badge>
                  ))}
                </div>
              </button>
            );
          })}
          {filtered.length === 0 && (
            <p className="text-center text-sm text-muted-foreground py-4">
              No exercises found.
            </p>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
