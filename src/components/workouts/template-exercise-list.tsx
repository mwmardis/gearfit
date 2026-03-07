"use client";

import { useTransition } from "react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  ArrowUp,
  ArrowDown,
  Trash2,
} from "lucide-react";
import {
  removeExerciseFromTemplate,
  reorderTemplateExercises,
  updateTemplateExercise,
} from "@/lib/actions/templates";
import { Input } from "@/components/ui/input";

interface TemplateExercise {
  id: string;
  exerciseId: string;
  orderIndex: number;
  targetSets: number;
  targetReps: number;
  targetWeight: string | null;
  exercise: {
    id: string;
    name: string;
    exerciseMuscles: {
      role: string;
      muscle: { name: string; muscleGroup: string } | null;
    }[];
  } | null;
}

interface TemplateExerciseListProps {
  templateId: string;
  exercises: TemplateExercise[];
}

export function TemplateExerciseList({
  templateId,
  exercises,
}: TemplateExerciseListProps) {
  const [isPending, startTransition] = useTransition();

  function handleMove(index: number, direction: "up" | "down") {
    const newOrder = [...exercises];
    const swapIndex = direction === "up" ? index - 1 : index + 1;
    [newOrder[index], newOrder[swapIndex]] = [
      newOrder[swapIndex],
      newOrder[index],
    ];

    startTransition(async () => {
      await reorderTemplateExercises(
        templateId,
        newOrder.map((e) => e.id)
      );
    });
  }

  function handleRemove(templateExerciseId: string) {
    startTransition(async () => {
      await removeExerciseFromTemplate(templateExerciseId, templateId);
    });
  }

  function handleUpdateField(
    id: string,
    field: "target_sets" | "target_reps" | "target_weight",
    value: string
  ) {
    const numValue = parseInt(value, 10);
    if (isNaN(numValue) || numValue < 0) return;

    startTransition(async () => {
      await updateTemplateExercise(id, templateId, {
        [field]: field === "target_weight" && numValue === 0 ? null : numValue,
      });
    });
  }

  if (exercises.length === 0) {
    return (
      <p className="text-center text-sm text-muted-foreground py-8">
        No exercises added yet. Click &quot;Add Exercise&quot; to get started.
      </p>
    );
  }

  return (
    <div className="space-y-2">
      {exercises.map((te, index) => {
        const primaryMuscles = (te.exercise?.exerciseMuscles ?? [])
          .filter((em) => em.role === "primary")
          .map((em) => em.muscle?.name)
          .filter(Boolean);

        return (
          <div
            key={te.id}
            className="flex items-start gap-3 rounded-md border p-3"
          >
            {/* Reorder buttons */}
            <div className="flex flex-col gap-1 pt-1">
              <Button
                variant="ghost"
                size="icon"
                className="h-6 w-6"
                disabled={index === 0 || isPending}
                onClick={() => handleMove(index, "up")}
              >
                <ArrowUp className="h-3 w-3" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="h-6 w-6"
                disabled={index === exercises.length - 1 || isPending}
                onClick={() => handleMove(index, "down")}
              >
                <ArrowDown className="h-3 w-3" />
              </Button>
            </div>

            {/* Exercise info */}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium">
                {te.exercise?.name ?? "Unknown Exercise"}
              </p>
              <div className="mt-1 flex flex-wrap gap-1">
                {primaryMuscles.map((name) => (
                  <Badge key={name} variant="secondary" className="text-xs">
                    {name}
                  </Badge>
                ))}
              </div>

              {/* Target inputs */}
              <div className="mt-2 flex items-center gap-2 text-xs">
                <div className="flex items-center gap-1">
                  <label className="text-muted-foreground">Sets:</label>
                  <Input
                    type="number"
                    min={1}
                    defaultValue={te.targetSets}
                    className="h-7 w-14 text-xs"
                    onBlur={(e) =>
                      handleUpdateField(te.id, "target_sets", e.target.value)
                    }
                  />
                </div>
                <div className="flex items-center gap-1">
                  <label className="text-muted-foreground">Reps:</label>
                  <Input
                    type="number"
                    min={1}
                    defaultValue={te.targetReps}
                    className="h-7 w-14 text-xs"
                    onBlur={(e) =>
                      handleUpdateField(te.id, "target_reps", e.target.value)
                    }
                  />
                </div>
                <div className="flex items-center gap-1">
                  <label className="text-muted-foreground">Weight:</label>
                  <Input
                    type="number"
                    min={0}
                    defaultValue={te.targetWeight ?? ""}
                    placeholder="—"
                    className="h-7 w-16 text-xs"
                    onBlur={(e) =>
                      handleUpdateField(te.id, "target_weight", e.target.value)
                    }
                  />
                </div>
              </div>
            </div>

            {/* Remove button */}
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 text-destructive hover:text-destructive"
              disabled={isPending}
              onClick={() => handleRemove(te.id)}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        );
      })}
    </div>
  );
}
