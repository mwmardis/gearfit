export function normalizeMuscleNames(
  names: string[],
  dbMuscleNames: string[]
): string[] {
  return names
    .map((name) =>
      dbMuscleNames.find((db) => db.toLowerCase() === name.toLowerCase())
    )
    .filter((n): n is string => n !== undefined);
}
