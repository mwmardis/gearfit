interface SetData {
  reps: number;
  targetReps: number;
}

interface SessionData {
  sets: SetData[];
}

export function shouldSuggestIncrease(
  recentSessions: SessionData[],
  threshold: number
): boolean {
  if (recentSessions.length < threshold) return false;

  const lastN = recentSessions.slice(0, threshold);
  return lastN.every((session) =>
    session.sets.every((set) => set.reps >= set.targetReps)
  );
}

export function getWeightIncrement(
  units: "lbs" | "kg",
  incrementLbs: number,
  incrementKg: number
): number {
  return units === "lbs" ? incrementLbs : incrementKg;
}
