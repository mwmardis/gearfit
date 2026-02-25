"use client";

import { useTransition } from "react";
import { Button } from "@/components/ui/button";
import { TemplateExerciseList } from "@/components/workouts/template-exercise-list";
import { AddExerciseDialog } from "@/components/workouts/add-exercise-dialog";
import { cloneTemplate, deleteTemplate } from "@/lib/actions/templates";
import Link from "next/link";
import { Copy, Trash2, Play } from "lucide-react";

interface Exercise {
  id: string;
  name: string;
  exercise_muscles: {
    role: string;
    muscle: { name: string; muscle_group: string } | null;
  }[];
}

interface TemplateExercise {
  id: string;
  exercise_id: string;
  order_index: number;
  target_sets: number;
  target_reps: number;
  target_weight: number | null;
  exercise: {
    id: string;
    name: string;
    exercise_muscles: {
      role: string;
      muscle: { name: string; muscle_group: string } | null;
    }[];
  } | null;
}

interface TemplateDetailClientProps {
  template: {
    id: string;
    name: string;
    description: string | null;
    template_exercises: TemplateExercise[];
  };
  allExercises: Exercise[];
}

export function TemplateDetailClient({
  template,
  allExercises,
}: TemplateDetailClientProps) {
  const [isPending, startTransition] = useTransition();

  const existingExerciseIds = template.template_exercises.map(
    (te) => te.exercise_id
  );

  function handleClone() {
    startTransition(async () => {
      await cloneTemplate(template.id);
    });
  }

  function handleDelete() {
    if (!confirm("Delete this workout template? This cannot be undone.")) return;
    startTransition(async () => {
      await deleteTemplate(template.id);
    });
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold">{template.name}</h1>
          {template.description && (
            <p className="text-muted-foreground">{template.description}</p>
          )}
        </div>
        <div className="flex gap-2">
          <Button asChild>
            <Link href={`/workouts/${template.id}/start`}>
              <Play className="mr-2 h-4 w-4" />
              Start Workout
            </Link>
          </Button>
        </div>
      </div>

      <div className="flex gap-2">
        <AddExerciseDialog
          templateId={template.id}
          currentExerciseCount={template.template_exercises.length}
          exercises={allExercises}
          existingExerciseIds={existingExerciseIds}
        />
        <Button
          variant="outline"
          disabled={isPending}
          onClick={handleClone}
        >
          <Copy className="mr-2 h-4 w-4" />
          Clone
        </Button>
        <Button
          variant="outline"
          className="text-destructive hover:text-destructive"
          disabled={isPending}
          onClick={handleDelete}
        >
          <Trash2 className="mr-2 h-4 w-4" />
          Delete
        </Button>
      </div>

      <TemplateExerciseList
        templateId={template.id}
        exercises={template.template_exercises}
      />
    </div>
  );
}
