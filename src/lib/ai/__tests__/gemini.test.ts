import { describe, it, expect } from "vitest";
import { parseGeminiResponse, type GeminiExerciseSuggestion } from "../gemini";

const validResponse: GeminiExerciseSuggestion[] = [
  {
    name: "Barbell Bench Press",
    primaryMuscles: ["Chest"],
    secondaryMuscles: ["Triceps", "Front Delts"],
    suggestedSets: 4,
    suggestedReps: 8,
    description: "A compound chest exercise",
    instructions: "Lie on bench, press barbell up",
  },
];

describe("parseGeminiResponse", () => {
  it("parses valid JSON array", () => {
    const result = parseGeminiResponse(JSON.stringify(validResponse));
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe("Barbell Bench Press");
  });

  it("handles JSON wrapped in markdown code block", () => {
    const wrapped = "```json\n" + JSON.stringify(validResponse) + "\n```";
    const result = parseGeminiResponse(wrapped);
    expect(result).toHaveLength(1);
  });

  it("throws on invalid JSON", () => {
    expect(() => parseGeminiResponse("not json")).toThrow();
  });

  it("throws on empty array", () => {
    expect(() => parseGeminiResponse("[]")).toThrow();
  });

  it("filters out items missing required fields", () => {
    const mixed = [
      validResponse[0],
      { name: "Incomplete" },
    ];
    const result = parseGeminiResponse(JSON.stringify(mixed));
    expect(result).toHaveLength(1);
  });
});
