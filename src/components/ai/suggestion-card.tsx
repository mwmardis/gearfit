"use client";

import { Bookmark, Plus, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import type { ExerciseRecommendation } from "@/lib/ai/types";

interface SuggestionCardProps {
  suggestion: ExerciseRecommendation;
  isAdded: boolean;
  isSaved: boolean;
  onAdd: () => void;
  onSave: () => void;
}

export function SuggestionCard({
  suggestion,
  isAdded,
  isSaved,
  onAdd,
  onSave,
}: SuggestionCardProps) {
  return (
    <div className="rounded-lg border p-3 space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div>
          <span className={suggestion.existsInDb ? "font-semibold" : "italic"}>
            {suggestion.name}
          </span>
          {!suggestion.existsInDb && (
            <Badge variant="outline" className="ml-2 text-xs">New</Badge>
          )}
        </div>
        <div className="flex gap-1 shrink-0">
          <Button
            size="icon"
            variant="ghost"
            onClick={onSave}
            className={isSaved ? "text-primary" : ""}
          >
            <Bookmark className={`h-4 w-4 ${isSaved ? "fill-current" : ""}`} />
          </Button>
          <Button
            size="sm"
            variant={isAdded ? "ghost" : "default"}
            onClick={onAdd}
            disabled={isAdded}
          >
            {isAdded ? <><Check className="h-4 w-4 mr-1" /> Added</> : <><Plus className="h-4 w-4 mr-1" /> Add</>}
          </Button>
        </div>
      </div>
      <div className="flex flex-wrap gap-1">
        {suggestion.primaryMuscles.map((m) => (
          <Badge key={m} variant="default" className="text-xs">{m}</Badge>
        ))}
        {suggestion.secondaryMuscles.map((m) => (
          <Badge key={m} variant="secondary" className="text-xs">{m}</Badge>
        ))}
      </div>
      <p className="text-xs text-muted-foreground">
        {suggestion.suggestedSets} sets x {suggestion.suggestedReps} reps
      </p>
      <p className="text-xs text-muted-foreground">{suggestion.description}</p>
    </div>
  );
}
