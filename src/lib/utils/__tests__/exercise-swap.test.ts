import { describe, it, expect } from "vitest";
import { rankSwapSuggestions } from "../exercise-swap";

describe("rankSwapSuggestions", () => {
  it("ranks exercises with more secondary muscle overlap higher", () => {
    const original = { primaryMuscles: ["chest"], secondaryMuscles: ["triceps", "front_delts"] };
    const candidates = [
      { id: "a", primaryMuscles: ["chest"], secondaryMuscles: ["triceps"] },
      { id: "b", primaryMuscles: ["chest"], secondaryMuscles: ["triceps", "front_delts"] },
      { id: "c", primaryMuscles: ["chest"], secondaryMuscles: [] },
    ];
    const ranked = rankSwapSuggestions(original, candidates);
    expect(ranked[0].id).toBe("b");
    expect(ranked[1].id).toBe("a");
    expect(ranked[2].id).toBe("c");
  });
});
