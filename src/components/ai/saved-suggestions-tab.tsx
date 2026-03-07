"use client";

import { useEffect, useState, useTransition } from "react";
import { Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getSavedSuggestions, deleteSavedSuggestion } from "@/lib/actions/ai";

interface SavedSuggestion {
  id: string;
  exerciseName: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  suggestedSets: number;
  suggestedReps: number;
  description: string | null;
  workoutType: string;
  exerciseId: string | null;
}

interface SavedSuggestionsTabProps {
  onAdd: (suggestion: SavedSuggestion) => void;
  addedIds: Set<string>;
}

export function SavedSuggestionsTab({ onAdd, addedIds }: SavedSuggestionsTabProps) {
  const [suggestions, setSuggestions] = useState<SavedSuggestion[]>([]);
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    getSavedSuggestions().then(setSuggestions);
  }, []);

  function handleDelete(id: string) {
    startTransition(async () => {
      await deleteSavedSuggestion(id);
      setSuggestions((prev) => prev.filter((s) => s.id !== id));
    });
  }

  if (suggestions.length === 0) {
    return (
      <p className="text-sm text-muted-foreground text-center py-8">
        No saved suggestions yet. Generate recommendations and bookmark the ones you like.
      </p>
    );
  }

  return (
    <div className="space-y-3">
      {suggestions.map((s) => (
        <div key={s.id} className="rounded-lg border p-3 space-y-2">
          <div className="flex items-start justify-between gap-2">
            <div>
              <span className="font-semibold">{s.exerciseName}</span>
              <Badge variant="outline" className="ml-2 text-xs">{s.workoutType}</Badge>
            </div>
            <div className="flex gap-1 shrink-0">
              <Button
                size="sm"
                variant="default"
                onClick={() => onAdd(s)}
                disabled={addedIds.has(s.id)}
              >
                {addedIds.has(s.id) ? "Added" : "Add"}
              </Button>
              <Button
                size="icon"
                variant="ghost"
                onClick={() => handleDelete(s.id)}
                disabled={isPending}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          </div>
          <div className="flex flex-wrap gap-1">
            {s.primaryMuscles.map((m) => (
              <Badge key={m} variant="default" className="text-xs">{m}</Badge>
            ))}
            {s.secondaryMuscles.map((m) => (
              <Badge key={m} variant="secondary" className="text-xs">{m}</Badge>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            {s.suggestedSets} sets x {s.suggestedReps} reps
          </p>
        </div>
      ))}
    </div>
  );
}
