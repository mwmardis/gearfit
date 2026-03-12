import { describe, it, expect } from "vitest";
import {
  scoreTemplates,
  getRecommendation,
  type TemplateForScoring,
  type MuscleVolumeInput,
} from "@/lib/workout-recommender";

function makeTemplate(
  overrides: Partial<TemplateForScoring> & { id: string }
): TemplateForScoring {
  return {
    name: `Template ${overrides.id}`,
    muscleGroups: [],
    lastUsedDate: null,
    ...overrides,
  };
}

describe("scoreTemplates", () => {
  it("ranks staler templates higher", () => {
    const templates = [
      makeTemplate({ id: "a", lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", lastUsedDate: "2026-03-08" }),
    ];
    const volume: MuscleVolumeInput[] = [];
    const result = scoreTemplates(templates, volume, "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("ranks templates covering under-trained muscles higher", () => {
    const templates = [
      makeTemplate({ id: "a", muscleGroups: ["chest"] }),
      makeTemplate({ id: "b", muscleGroups: ["back"] }),
    ];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
      { muscleGroup: "back", status: "under" },
    ];
    const result = scoreTemplates(templates, volume, "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("gives never-used templates the highest staleness score", () => {
    const templates = [
      makeTemplate({ id: "a", lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", lastUsedDate: null }),
    ];
    const result = scoreTemplates(templates, [], "2026-03-12");

    const scoreA = result.find((r) => r.templateId === "a")!.score;
    const scoreB = result.find((r) => r.templateId === "b")!.score;
    expect(scoreB).toBeGreaterThan(scoreA);
  });

  it("returns empty array for no templates", () => {
    const result = scoreTemplates([], [], "2026-03-12");
    expect(result).toEqual([]);
  });
});

describe("getRecommendation", () => {
  it("suggests rest when all muscles optimal and trained 5+ days", () => {
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
      { muscleGroup: "back", status: "optimal" },
    ];
    const result = getRecommendation([], volume, 6, "2026-03-12");
    expect(result.type).toBe("rest");
    expect(result.reason).toContain("rest day");
  });

  it("suggests workout even when all optimal if trained fewer than 5 days", () => {
    const templates = [makeTemplate({ id: "a", muscleGroups: ["chest"] })];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "chest", status: "optimal" },
    ];
    const result = getRecommendation(templates, volume, 3, "2026-03-12");
    expect(result.type).toBe("workout");
  });

  it("picks the highest-scored template", () => {
    const templates = [
      makeTemplate({ id: "a", muscleGroups: ["chest"], lastUsedDate: "2026-03-11" }),
      makeTemplate({ id: "b", muscleGroups: ["back"], lastUsedDate: "2026-03-05" }),
    ];
    const volume: MuscleVolumeInput[] = [
      { muscleGroup: "back", status: "under" },
    ];
    const result = getRecommendation(templates, volume, 2, "2026-03-12");
    expect(result.type).toBe("workout");
    expect(result.template!.id).toBe("b");
  });
});
