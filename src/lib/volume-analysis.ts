import { type VolumeTargetMap, type MuscleGroup, MUSCLE_GROUPS } from "@/lib/volume-targets";

export type SessionSetWithMuscles = {
  muscles: { muscleGroup: string; role: "primary" | "secondary" }[];
};

export type MuscleVolumeStatus = {
  muscleGroup: MuscleGroup;
  currentSets: number;
  targetMin: number;
  targetMax: number;
  status: "under" | "optimal" | "over";
};

export function computeVolumeStatus(
  sets: SessionSetWithMuscles[],
  targets: VolumeTargetMap
): MuscleVolumeStatus[] {
  const volumeMap = new Map<string, number>();

  for (const set of sets) {
    for (const muscle of set.muscles) {
      const weight = muscle.role === "primary" ? 1 : 0.5;
      const current = volumeMap.get(muscle.muscleGroup) ?? 0;
      volumeMap.set(muscle.muscleGroup, current + weight);
    }
  }

  return MUSCLE_GROUPS.map((group) => {
    const currentSets = volumeMap.get(group) ?? 0;
    const target = targets[group];
    let status: "under" | "optimal" | "over";

    if (currentSets < target.min) {
      status = "under";
    } else if (currentSets > target.max) {
      status = "over";
    } else {
      status = "optimal";
    }

    return {
      muscleGroup: group,
      currentSets,
      targetMin: target.min,
      targetMax: target.max,
      status,
    };
  });
}
