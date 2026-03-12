import { describe, it, expect } from "vitest";
import {
  computeVolumeStatus,
  type SessionSetWithMuscles,
  type MuscleVolumeStatus,
} from "@/lib/volume-analysis";
import { type VolumeTargetMap } from "@/lib/volume-targets";

const mockTargets: VolumeTargetMap = {
  chest: { min: 10, max: 20 },
  back: { min: 12, max: 22 },
  shoulders: { min: 10, max: 20 },
  arms: { min: 10, max: 20 },
  legs: { min: 12, max: 22 },
  core: { min: 8, max: 16 },
};

function makeSets(
  muscles: { group: string; role: "primary" | "secondary" }[],
  count: number
): SessionSetWithMuscles[] {
  return Array.from({ length: count }, () => ({
    muscles: muscles.map((m) => ({ muscleGroup: m.group, role: m.role })),
  }));
}

describe("computeVolumeStatus", () => {
  it("returns under status when no sets logged", () => {
    const result = computeVolumeStatus([], mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest).toBeDefined();
    expect(chest!.currentSets).toBe(0);
    expect(chest!.status).toBe("under");
  });

  it("counts primary muscles as 1 set each", () => {
    const sets = makeSets([{ group: "chest", role: "primary" }], 12);
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest!.currentSets).toBe(12);
    expect(chest!.status).toBe("optimal");
  });

  it("counts secondary muscles as 0.5 sets each", () => {
    const sets = makeSets([{ group: "arms", role: "secondary" }], 10);
    const result = computeVolumeStatus(sets, mockTargets);
    const arms = result.find((r) => r.muscleGroup === "arms");
    expect(arms!.currentSets).toBe(5);
    expect(arms!.status).toBe("under");
  });

  it("returns over status when exceeding max", () => {
    const sets = makeSets([{ group: "core", role: "primary" }], 20);
    const result = computeVolumeStatus(sets, mockTargets);
    const core = result.find((r) => r.muscleGroup === "core");
    expect(core!.currentSets).toBe(20);
    expect(core!.status).toBe("over");
  });

  it("returns optimal status when within range", () => {
    const sets = makeSets([{ group: "chest", role: "primary" }], 15);
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    expect(chest!.status).toBe("optimal");
  });

  it("handles mixed primary and secondary muscles per set", () => {
    const sets = makeSets(
      [
        { group: "chest", role: "primary" },
        { group: "arms", role: "secondary" },
      ],
      20
    );
    const result = computeVolumeStatus(sets, mockTargets);
    const chest = result.find((r) => r.muscleGroup === "chest");
    const arms = result.find((r) => r.muscleGroup === "arms");
    expect(chest!.currentSets).toBe(20);
    expect(arms!.currentSets).toBe(10);
  });

  it("returns a status for every muscle group in targets", () => {
    const result = computeVolumeStatus([], mockTargets);
    expect(result).toHaveLength(6);
    const groups = result.map((r) => r.muscleGroup);
    expect(groups).toContain("chest");
    expect(groups).toContain("back");
    expect(groups).toContain("legs");
  });
});
