export const TRAINING_GOALS = ["hypertrophy", "strength", "endurance"] as const;
export type TrainingGoal = (typeof TRAINING_GOALS)[number];

export const MUSCLE_GROUPS = [
  "chest",
  "back",
  "shoulders",
  "arms",
  "legs",
  "core",
] as const;
export type MuscleGroup = (typeof MUSCLE_GROUPS)[number];

export type VolumeTarget = { min: number; max: number };
export type VolumeTargetMap = Record<MuscleGroup, VolumeTarget>;

const VOLUME_PRESETS: Record<TrainingGoal, VolumeTargetMap> = {
  hypertrophy: {
    chest: { min: 10, max: 20 },
    back: { min: 12, max: 22 },
    shoulders: { min: 10, max: 20 },
    arms: { min: 10, max: 20 },
    legs: { min: 12, max: 22 },
    core: { min: 8, max: 16 },
  },
  strength: {
    chest: { min: 6, max: 12 },
    back: { min: 8, max: 15 },
    shoulders: { min: 6, max: 12 },
    arms: { min: 6, max: 12 },
    legs: { min: 8, max: 15 },
    core: { min: 4, max: 10 },
  },
  endurance: {
    chest: { min: 15, max: 25 },
    back: { min: 15, max: 25 },
    shoulders: { min: 15, max: 25 },
    arms: { min: 15, max: 25 },
    legs: { min: 15, max: 25 },
    core: { min: 12, max: 20 },
  },
};

export function getVolumeTargets(goal: TrainingGoal): VolumeTargetMap {
  return VOLUME_PRESETS[goal];
}
