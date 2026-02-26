interface ExerciseForSwap {
  id: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
}

export function rankSwapSuggestions(
  original: { primaryMuscles: string[]; secondaryMuscles: string[] },
  candidates: ExerciseForSwap[]
): ExerciseForSwap[] {
  return candidates
    .map((candidate) => {
      const overlapCount = original.secondaryMuscles.filter((m) =>
        candidate.secondaryMuscles.includes(m)
      ).length;
      return { ...candidate, overlapCount };
    })
    .sort((a, b) => b.overlapCount - a.overlapCount);
}
