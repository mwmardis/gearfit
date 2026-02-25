"use client";

import { useState, useMemo } from "react";
import { ExerciseFilters } from "@/components/exercises/exercise-filters";
import { ExerciseCard } from "@/components/exercises/exercise-card";

interface Exercise {
  id: string;
  name: string;
  exercise_equipment: {
    equipment: { id: string; name: string } | null;
  }[];
  exercise_muscles: {
    role: string;
    muscle: { id: string; name: string; muscle_group: string } | null;
  }[];
}

interface ExercisesPageClientProps {
  initialExercises: Exercise[];
}

export function ExercisesPageClient({
  initialExercises,
}: ExercisesPageClientProps) {
  const [search, setSearch] = useState("");
  const [muscleGroup, setMuscleGroup] = useState("");
  const [availableOnly, setAvailableOnly] = useState(false);

  const filtered = useMemo(() => {
    let result = initialExercises;

    if (search) {
      const lower = search.toLowerCase();
      result = result.filter((ex) => ex.name.toLowerCase().includes(lower));
    }

    if (muscleGroup) {
      result = result.filter((ex) =>
        ex.exercise_muscles.some(
          (em) =>
            em.muscle?.muscle_group === muscleGroup && em.role === "primary"
        )
      );
    }

    return result;
  }, [initialExercises, search, muscleGroup]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Exercises</h1>
        <p className="text-muted-foreground">Browse the exercise library</p>
      </div>

      <ExerciseFilters
        search={search}
        muscleGroup={muscleGroup}
        availableOnly={availableOnly}
        onSearchChange={setSearch}
        onMuscleGroupChange={setMuscleGroup}
        onAvailableOnlyChange={setAvailableOnly}
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
