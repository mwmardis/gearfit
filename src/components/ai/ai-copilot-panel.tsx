"use client";

import { useState, useTransition } from "react";
import { Sparkles, Loader2, RefreshCw } from "lucide-react";
import {
  Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { WorkoutTypeSelector } from "./workout-type-selector";
import { SuggestionCard } from "./suggestion-card";
import { SavedSuggestionsTab } from "./saved-suggestions-tab";
import { saveSuggestion, createExerciseFromSuggestion } from "@/lib/actions/ai";
import { addExerciseToTemplate } from "@/lib/actions/templates";
import type { ExerciseRecommendation } from "@/lib/ai/types";

interface AICopilotPanelProps {
  equipmentProfileName: string | null;
  equipmentNames: string[];
  templateId?: string;
  existingExerciseNames?: string[];
  nextOrderIndex?: number;
}

export function AICopilotPanel({
  equipmentProfileName,
  equipmentNames,
  templateId,
  existingExerciseNames = [],
  nextOrderIndex = 0,
}: AICopilotPanelProps) {
  const [open, setOpen] = useState(false);
  const [tab, setTab] = useState<"generate" | "saved">("generate");
  const [workoutType, setWorkoutType] = useState("");
  const [recommendations, setRecommendations] = useState<ExerciseRecommendation[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [addedIds, setAddedIds] = useState<Set<string>>(new Set());
  const [savedNames, setSavedNames] = useState<Set<string>>(new Set());
  const [isPending, startTransition] = useTransition();
  const [orderCounter, setOrderCounter] = useState(nextOrderIndex);

  async function handleGenerate() {
    setError(null);
    startTransition(async () => {
      try {
        const res = await fetch("/api/ai/recommend-exercises", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            workoutType,
            equipment: equipmentNames,
            existingExercises: existingExerciseNames,
          }),
        });

        if (!res.ok) {
          const data = await res.json();
          setError(data.error || "Failed to generate recommendations");
          return;
        }

        const data = await res.json();
        setRecommendations(data.recommendations);
        setAddedIds(new Set());
      } catch {
        setError("Failed to connect. Please try again.");
      }
    });
  }

  async function handleAdd(rec: ExerciseRecommendation) {
    startTransition(async () => {
      let exerciseId = rec.existingExerciseId;

      if (!rec.existsInDb) {
        const newExercise = await createExerciseFromSuggestion(rec, equipmentNames);
        exerciseId = newExercise.id;
      }

      if (templateId && exerciseId) {
        await addExerciseToTemplate(templateId, exerciseId, orderCounter);
        setOrderCounter((c) => c + 1);
      }

      setAddedIds((prev) => new Set(prev).add(rec.name));
    });
  }

  async function handleSave(rec: ExerciseRecommendation) {
    startTransition(async () => {
      await saveSuggestion({
        ...rec,
        existingExerciseId: rec.existingExerciseId,
        workoutType,
      });
      setSavedNames((prev) => new Set(prev).add(rec.name));
    });
  }

  async function handleAddFromSaved(saved: {
    exercise_name: string;
    exercise_id: string | null;
    primary_muscles: string[];
    secondary_muscles: string[];
    suggested_sets: number;
    suggested_reps: number;
    description: string | null;
  }) {
    startTransition(async () => {
      let exerciseId = saved.exercise_id;

      if (!exerciseId) {
        const newExercise = await createExerciseFromSuggestion(
          {
            name: saved.exercise_name,
            primaryMuscles: saved.primary_muscles,
            secondaryMuscles: saved.secondary_muscles,
            suggestedSets: saved.suggested_sets,
            suggestedReps: saved.suggested_reps,
            description: saved.description ?? "",
            instructions: "",
          },
          equipmentNames
        );
        exerciseId = newExercise.id;
      }

      if (templateId && exerciseId) {
        await addExerciseToTemplate(templateId, exerciseId, orderCounter);
        setOrderCounter((c) => c + 1);
      }

      setAddedIds((prev) => new Set(prev).add(saved.exercise_name));
    });
  }

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="outline" size="sm">
          <Sparkles className="h-4 w-4 mr-2" />
          AI Suggest
        </Button>
      </SheetTrigger>
      <SheetContent className="w-full sm:max-w-lg overflow-y-auto">
        <SheetHeader>
          <SheetTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5" />
            AI Exercise Recommendations
          </SheetTitle>
        </SheetHeader>

        {/* Tabs */}
        <div className="flex gap-2 mt-4 border-b pb-2">
          <button
            onClick={() => setTab("generate")}
            className={`text-sm font-medium pb-1 border-b-2 transition-colors ${
              tab === "generate" ? "border-primary text-primary" : "border-transparent text-muted-foreground"
            }`}
          >
            Generate
          </button>
          <button
            onClick={() => setTab("saved")}
            className={`text-sm font-medium pb-1 border-b-2 transition-colors ${
              tab === "saved" ? "border-primary text-primary" : "border-transparent text-muted-foreground"
            }`}
          >
            Saved
          </button>
        </div>

        {tab === "generate" ? (
          <div className="space-y-4 mt-4">
            <WorkoutTypeSelector value={workoutType} onChange={setWorkoutType} />

            {/* Equipment context */}
            <div className="text-sm">
              <span className="text-muted-foreground">Equipment: </span>
              {equipmentProfileName ? (
                <span className="font-medium">{equipmentProfileName}</span>
              ) : (
                <span className="text-destructive">
                  No active profile.{" "}
                  <a href="/equipment" className="underline">Set one up</a>
                </span>
              )}
            </div>

            {/* Generate button */}
            <Button
              onClick={handleGenerate}
              disabled={!workoutType || isPending}
              className="w-full"
            >
              {isPending ? (
                <><Loader2 className="h-4 w-4 mr-2 animate-spin" /> Generating...</>
              ) : (
                "Generate Recommendations"
              )}
            </Button>

            {/* Error */}
            {error && (
              <div className="rounded-lg bg-destructive/10 text-destructive text-sm p-3">
                {error}
              </div>
            )}

            {/* Results */}
            {recommendations.length > 0 && (
              <div className="space-y-3">
                {recommendations.map((rec) => (
                  <SuggestionCard
                    key={rec.name}
                    suggestion={rec}
                    isAdded={addedIds.has(rec.name)}
                    isSaved={savedNames.has(rec.name)}
                    onAdd={() => handleAdd(rec)}
                    onSave={() => handleSave(rec)}
                  />
                ))}
                <Button
                  variant="outline"
                  onClick={handleGenerate}
                  disabled={isPending}
                  className="w-full"
                >
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Regenerate
                </Button>
              </div>
            )}
          </div>
        ) : (
          <div className="mt-4">
            <SavedSuggestionsTab
              onAdd={handleAddFromSaved}
              addedIds={addedIds}
            />
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}
