import { describe, it, expect } from "vitest";
import { normalizeMuscleNames } from "../ai";

const DB_MUSCLES = [
  "Chest", "Triceps", "Biceps", "Forearms",
  "Front Delts", "Side Delts", "Rear Delts",
  "Lats", "Upper Back", "Lower Back",
  "Quads", "Hamstrings", "Glutes", "Calves", "Abs",
];

describe("normalizeMuscleNames", () => {
  it("returns exact matches unchanged", () => {
    expect(normalizeMuscleNames(["Chest", "Triceps"], DB_MUSCLES))
      .toEqual(["Chest", "Triceps"]);
  });

  it("matches case-insensitively", () => {
    expect(normalizeMuscleNames(["chest", "TRICEPS"], DB_MUSCLES))
      .toEqual(["Chest", "Triceps"]);
  });

  it("drops unmatched names", () => {
    expect(normalizeMuscleNames(["Chest", "Serratus Anterior"], DB_MUSCLES))
      .toEqual(["Chest"]);
  });

  it("returns empty array for all unmatched", () => {
    expect(normalizeMuscleNames(["Rotator Cuff"], DB_MUSCLES))
      .toEqual([]);
  });
});
