"use client";

import { useMemo } from "react";
import { ChevronDown } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const muscleGroups = [
  { value: "", label: "All Muscles" },
  { value: "Chest", label: "Chest" },
  { value: "Back", label: "Back" },
  { value: "Shoulders", label: "Shoulders" },
  { value: "Arms", label: "Arms" },
  { value: "Legs", label: "Legs" },
  { value: "Core", label: "Core" },
];

// Maps user-friendly filter names to actual DB muscle_group values
export const muscleGroupMap: Record<string, string[]> = {
  Chest: ["Chest"],
  Back: ["Back", "Trapezius"],
  Shoulders: ["Shoulders"],
  Arms: ["Biceps", "Triceps", "Forearms"],
  Legs: ["Quadriceps", "Hamstrings", "Glutes", "Calves", "Adductors", "Hip Flexors", "Hip Rotators"],
  Core: ["Core", "Neck"],
};

export interface MuscleFilter {
  category: string; // "Arms", "Legs", etc. or ""
  specific: string; // "Biceps", "Quadriceps", etc. or ""
}

export const subMuscleLabels: Record<string, string> = {
  Quadriceps: "Quads",
  Trapezius: "Traps",
};

interface ExerciseFiltersProps {
  search: string;
  muscleFilter: MuscleFilter;
  availableOnly: boolean;
  onSearchChange: (search: string) => void;
  onMuscleFilterChange: (filter: MuscleFilter) => void;
  onAvailableOnlyChange: (available: boolean) => void;
}

export function ExerciseFilters({
  search,
  muscleFilter,
  availableOnly,
  onSearchChange,
  onMuscleFilterChange,
  onAvailableOnlyChange,
}: ExerciseFiltersProps) {
  const activeCategory = muscleFilter.category;
  const subMuscles = useMemo(
    () => (activeCategory ? muscleGroupMap[activeCategory] ?? [] : []),
    [activeCategory]
  );
  const isSubRowOpen = subMuscles.length > 0;

  function handleCategoryClick(value: string) {
    if (value === "" || value === activeCategory) {
      onMuscleFilterChange({ category: "", specific: "" });
    } else {
      onMuscleFilterChange({ category: value, specific: "" });
    }
  }

  function handleSpecificClick(value: string) {
    if (value === muscleFilter.specific) {
      onMuscleFilterChange({ category: activeCategory, specific: "" });
    } else {
      onMuscleFilterChange({ category: activeCategory, specific: value });
    }
  }

  return (
    <div className="flex flex-col gap-2">
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
              aria-pressed={activeCategory === mg.value}
              variant={activeCategory === mg.value ? "default" : "outline"}
              size="sm"
              onClick={() => handleCategoryClick(mg.value)}
            >
              {mg.label}
              {mg.value && activeCategory === mg.value && (
                <ChevronDown className="size-3" />
              )}
            </Button>
          ))}
        </div>
        <Button
          aria-pressed={availableOnly}
          variant={availableOnly ? "default" : "outline"}
          size="sm"
          onClick={() => onAvailableOnlyChange(!availableOnly)}
        >
          {availableOnly ? "Available Only" : "Show All"}
        </Button>
      </div>
      <div
        className="grid transition-all duration-200"
        style={{ gridTemplateRows: isSubRowOpen ? "1fr" : "0fr" }}
      >
        <div className="overflow-hidden">
        <div className="flex flex-wrap gap-1 pt-1">
          {subMuscles.map((muscle) => (
            <Button
              key={muscle}
              aria-pressed={muscleFilter.specific === muscle}
              variant={muscleFilter.specific === muscle ? "secondary" : "outline"}
              size="xs"
              onClick={() => handleSpecificClick(muscle)}
            >
              {subMuscleLabels[muscle] ?? muscle}
            </Button>
          ))}
        </div>
        </div>
      </div>
    </div>
  );
}
