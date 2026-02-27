"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import { TemplateExerciseList } from "@/components/workouts/template-exercise-list";
import { AddExerciseDialog } from "@/components/workouts/add-exercise-dialog";
import { cloneTemplate, deleteTemplate } from "@/lib/actions/templates";
import { toggleShareTemplate } from "@/lib/actions/sharing";
import Link from "next/link";
import { Copy, Trash2, Play, Share2, Check } from "lucide-react";
import { AICopilotPanel } from "@/components/ai/ai-copilot-panel";

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
    is_shared: boolean;
    share_token: string | null;
    template_exercises: TemplateExercise[];
  };
  allExercises: Exercise[];
  equipmentProfileName: string | null;
  equipmentNames: string[];
}

export function TemplateDetailClient({
  template,
  allExercises,
  equipmentProfileName,
  equipmentNames,
}: TemplateDetailClientProps) {
  const [isPending, startTransition] = useTransition();
  const [isShared, setIsShared] = useState(template.is_shared);
  const [shareToken, setShareToken] = useState(template.share_token);
  const [copied, setCopied] = useState(false);

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

  function handleShare() {
    startTransition(async () => {
      const result = await toggleShareTemplate(template.id);
      setIsShared(result.shared);
      if (result.shareToken) {
        setShareToken(result.shareToken);
        const url = `${window.location.origin}/share/${result.shareToken}`;
        await navigator.clipboard.writeText(url);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
      }
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

      <AICopilotPanel
        equipmentProfileName={equipmentProfileName}
        equipmentNames={equipmentNames}
        templateId={template.id}
        existingExerciseNames={template.template_exercises.map(
          (te: { exercise: { name: string } }) => te.exercise.name
        )}
        nextOrderIndex={template.template_exercises.length}
      />

      <div className="flex gap-2">
        <AddExerciseDialog
          templateId={template.id}
          currentExerciseCount={template.template_exercises.length}
          exercises={allExercises}
          existingExerciseIds={existingExerciseIds}
        />
        <Button
          variant={isShared ? "default" : "outline"}
          disabled={isPending}
          onClick={handleShare}
        >
          {copied ? (
            <Check className="mr-2 h-4 w-4" />
          ) : (
            <Share2 className="mr-2 h-4 w-4" />
          )}
          {copied ? "Link Copied!" : isShared ? "Unshare" : "Share"}
        </Button>
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

      {isShared && shareToken && (
        <p className="text-xs text-muted-foreground">
          Shared at: /share/{shareToken}
        </p>
      )}

      <TemplateExerciseList
        templateId={template.id}
        exercises={template.template_exercises}
      />
    </div>
  );
}
