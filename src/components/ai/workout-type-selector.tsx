"use client";

import { useState } from "react";
import { Input } from "@/components/ui/input";

const WORKOUT_TYPES = [
  "Push", "Pull", "Legs", "Upper", "Lower", "Full Body", "Arms", "Core",
] as const;

interface WorkoutTypeSelectorProps {
  value: string;
  onChange: (value: string) => void;
}

export function WorkoutTypeSelector({ value, onChange }: WorkoutTypeSelectorProps) {
  const [isCustom, setIsCustom] = useState(false);

  return (
    <div className="space-y-2">
      <label className="text-sm font-medium">Workout Type</label>
      <div className="flex flex-wrap gap-2">
        {WORKOUT_TYPES.map((type) => (
          <button
            key={type}
            type="button"
            onClick={() => { setIsCustom(false); onChange(type); }}
            className={`rounded-full px-3 py-1 text-sm border transition-colors ${
              !isCustom && value === type
                ? "bg-primary text-primary-foreground border-primary"
                : "bg-muted hover:bg-muted/80 border-transparent"
            }`}
          >
            {type}
          </button>
        ))}
        <button
          type="button"
          onClick={() => { setIsCustom(true); onChange(""); }}
          className={`rounded-full px-3 py-1 text-sm border transition-colors ${
            isCustom
              ? "bg-primary text-primary-foreground border-primary"
              : "bg-muted hover:bg-muted/80 border-transparent"
          }`}
        >
          Custom
        </button>
      </div>
      {isCustom && (
        <Input
          placeholder="e.g. chest and triceps hypertrophy"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="mt-2"
        />
      )}
    </div>
  );
}
