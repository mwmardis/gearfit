import { describe, it, expect } from "vitest";
import { muscleGroupMap, subMuscleLabels } from "../exercise-filters";
import type { MuscleFilter } from "../exercise-filters";

describe("muscleGroupMap", () => {
  it("maps every category to at least one DB muscle group", () => {
    for (const [category, groups] of Object.entries(muscleGroupMap)) {
      expect(groups.length).toBeGreaterThan(0);
    }
  });

  it("Arms includes Biceps, Triceps, and Forearms", () => {
    expect(muscleGroupMap.Arms).toEqual(["Biceps", "Triceps", "Forearms"]);
  });

  it("Legs includes all lower-body groups", () => {
    expect(muscleGroupMap.Legs).toContain("Quadriceps");
    expect(muscleGroupMap.Legs).toContain("Hamstrings");
    expect(muscleGroupMap.Legs).toContain("Glutes");
    expect(muscleGroupMap.Legs).toContain("Calves");
  });
});

describe("subMuscleLabels", () => {
  it("shortens Quadriceps to Quads", () => {
    expect(subMuscleLabels["Quadriceps"]).toBe("Quads");
  });

  it("shortens Trapezius to Traps", () => {
    expect(subMuscleLabels["Trapezius"]).toBe("Traps");
  });

  it("does not override Biceps", () => {
    expect(subMuscleLabels["Biceps"]).toBeUndefined();
  });
});

describe("MuscleFilter type", () => {
  it("can represent no filter", () => {
    const filter: MuscleFilter = { category: "", specific: "" };
    expect(filter.category).toBe("");
    expect(filter.specific).toBe("");
  });

  it("can represent category-only filter", () => {
    const filter: MuscleFilter = { category: "Arms", specific: "" };
    expect(filter.category).toBe("Arms");
  });

  it("can represent specific muscle filter", () => {
    const filter: MuscleFilter = { category: "Arms", specific: "Biceps" };
    expect(filter.specific).toBe("Biceps");
  });
});
