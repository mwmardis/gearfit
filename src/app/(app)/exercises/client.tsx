"use client";

import { useState, useMemo } from "react";
import { ExerciseFilters, muscleGroupMap, type MuscleFilter } from "@/components/exercises/exercise-filters";
import { ExerciseCard } from "@/components/exercises/exercise-card";
import { AICopilotPanel } from "@/components/ai/ai-copilot-panel";

interface Exercise {
  id: string;
  name: string;
  exerciseEquipment: {
    equipment: { id: string; name: string } | null;
  }[];
  exerciseMuscles: {
    role: string;
    muscle: { id: string; name: string; muscleGroup: string } | null;
  }[];
}

interface ExercisesPageClientProps {
  initialExercises: Exercise[];
  equipmentProfileName: string | null;
  equipmentNames: string[];
}

export function ExercisesPageClient({
  initialExercises,
  equipmentProfileName,
  equipmentNames,
}: ExercisesPageClientProps) {
  const [search, setSearch] = useState("");
  const [muscleFilter, setMuscleFilter] = useState<MuscleFilter>({ category: "", specific: "" });
  const [availableOnly, setAvailableOnly] = useState(false);

  const filtered = useMemo(() => {
    let result = initialExercises;

    if (search) {
      const lower = search.toLowerCase();
      result = result.filter((ex) => ex.name.toLowerCase().includes(lower));
    }

    if (muscleFilter.specific) {
      result = result.filter((ex) =>
        ex.exerciseMuscles.some(
          (em) =>
            em.muscle?.muscleGroup === muscleFilter.specific &&
            em.role === "primary"
        )
      );
    } else if (muscleFilter.category) {
      const dbGroups = muscleGroupMap[muscleFilter.category] ?? [muscleFilter.category];
      result = result.filter((ex) =>
        ex.exerciseMuscles.some(
          (em) =>
            em.muscle?.muscleGroup &&
            dbGroups.includes(em.muscle.muscleGroup) &&
            em.role === "primary"
        )
      );
    }

    return result;
  }, [initialExercises, search, muscleFilter]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Exercises</h1>
        <p className="text-muted-foreground">Browse the exercise library</p>
      </div>

      <ExerciseFilters
        search={search}
        muscleFilter={muscleFilter}
        availableOnly={availableOnly}
        onSearchChange={setSearch}
        onMuscleFilterChange={setMuscleFilter}
        onAvailableOnlyChange={setAvailableOnly}
      />

      <AICopilotPanel
        equipmentProfileName={equipmentProfileName}
        equipmentNames={equipmentNames}
      />

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((exercise) => (
          <ExerciseCard key={exercise.id} exercise={exercise} />
        ))}
      </div>

      {filtered.length === 0 && (
        <p className="text-center text-sm text-muted-foreground">
          No exercises found matching your filters.
        </p>
      )}
    </div>
  );
}
