"use client";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const muscleGroups = [
  { value: "", label: "All Muscles" },
  { value: "chest", label: "Chest" },
  { value: "back", label: "Back" },
  { value: "shoulders", label: "Shoulders" },
  { value: "arms", label: "Arms" },
  { value: "legs", label: "Legs" },
  { value: "core", label: "Core" },
];

interface ExerciseFiltersProps {
  search: string;
  muscleGroup: string;
  availableOnly: boolean;
  onSearchChange: (search: string) => void;
  onMuscleGroupChange: (group: string) => void;
  onAvailableOnlyChange: (available: boolean) => void;
}

export function ExerciseFilters({
  search,
  muscleGroup,
  availableOnly,
  onSearchChange,
  onMuscleGroupChange,
  onAvailableOnlyChange,
}: ExerciseFiltersProps) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
      <Input
        placeholder="Search exercises..."
        value={search}
        onChange={(e) => onSearchChange(e.target.value)}
        className="max-w-xs"
      />
      <div className="flex flex-wrap gap-1">
        {muscleGroups.map((mg) => (
          <Button
            key={mg.value}
            variant={muscleGroup === mg.value ? "default" : "outline"}
            size="sm"
            onClick={() => onMuscleGroupChange(mg.value)}
          >
            {mg.label}
          </Button>
        ))}
      </div>
      <Button
        variant={availableOnly ? "default" : "outline"}
        size="sm"
        onClick={() => onAvailableOnlyChange(!availableOnly)}
      >
        {availableOnly ? "Available Only" : "Show All"}
      </Button>
    </div>
  );
}
