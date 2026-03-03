import { GoogleGenerativeAI } from "@google/generative-ai";
import type { GeminiExerciseSuggestion } from "./types";

export type { GeminiExerciseSuggestion };

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

export function parseGeminiResponse(text: string): GeminiExerciseSuggestion[] {
  // Strip markdown code block wrapper if present
  let cleaned = text.trim();
  if (cleaned.startsWith("```")) {
    cleaned = cleaned.replace(/^```(?:json)?\n?/, "").replace(/\n?```$/, "");
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    throw new Error("Failed to parse Gemini response as JSON");
  }

  if (!Array.isArray(parsed) || parsed.length === 0) {
    throw new Error("Gemini returned empty or invalid response");
  }

  const valid = parsed.filter(
    (item: Record<string, unknown>) =>
      typeof item.name === "string" &&
      Array.isArray(item.primaryMuscles) &&
      item.primaryMuscles.length > 0
  ) as GeminiExerciseSuggestion[];

  if (valid.length === 0) {
    throw new Error("No valid exercises in Gemini response");
  }

  return valid;
}

export async function generateExerciseRecommendations(
  systemPrompt: string,
  userPrompt: string
): Promise<GeminiExerciseSuggestion[]> {
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: userPrompt }] }],
    systemInstruction: { role: "model", parts: [{ text: systemPrompt }] },
  });

  const text = result.response.text();
  return parseGeminiResponse(text);
}
