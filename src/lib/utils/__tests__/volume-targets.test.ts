import { describe, it, expect } from "vitest";
import {
  getVolumeTargets,
  type TrainingGoal,
  MUSCLE_GROUPS,
} from "@/lib/volume-targets";

describe("getVolumeTargets", () => {
  it("returns targets for every muscle group for hypertrophy", () => {
    const targets = getVolumeTargets("hypertrophy");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
      expect(targets[muscle].min).toBeGreaterThan(0);
      expect(targets[muscle].max).toBeGreaterThan(targets[muscle].min);
    }
  });

  it("returns targets for every muscle group for strength", () => {
    const targets = getVolumeTargets("strength");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
    }
  });

  it("returns targets for every muscle group for endurance", () => {
    const targets = getVolumeTargets("endurance");
    for (const muscle of MUSCLE_GROUPS) {
      expect(targets[muscle]).toBeDefined();
    }
  });

  it("strength targets are lower than hypertrophy targets", () => {
    const strength = getVolumeTargets("strength");
    const hypertrophy = getVolumeTargets("hypertrophy");
    expect(strength["chest"].min).toBeLessThan(hypertrophy["chest"].min);
  });

  it("endurance targets are higher than hypertrophy targets", () => {
    const endurance = getVolumeTargets("endurance");
    const hypertrophy = getVolumeTargets("hypertrophy");
    expect(endurance["chest"].min).toBeGreaterThan(hypertrophy["chest"].min);
  });
});
