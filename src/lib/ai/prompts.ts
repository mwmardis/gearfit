export function buildSystemPrompt(): string {
  return `You are a fitness exercise recommendation engine. You MUST respond with ONLY a valid JSON array of exercise objects. No additional text, explanations, or markdown.

Each exercise object must have these exact fields:
- "name": string - the exercise name
- "primaryMuscles": string[] - primary muscles targeted (use these exact names: Chest, Triceps, Biceps, Forearms, Front Delts, Side Delts, Rear Delts, Lats, Upper Back, Lower Back, Quads, Hamstrings, Glutes, Calves, Abs)
- "secondaryMuscles": string[] - secondary muscles targeted (same names as above)
- "suggestedSets": number - recommended number of sets (typically 3-5)
- "suggestedReps": number - recommended reps per set (typically 6-15)
- "description": string - one sentence describing the exercise
- "instructions": string - brief form instructions (2-3 sentences)

Return exactly 6-8 exercises. Only recommend exercises that can be performed with the available equipment listed.`;
}

export function buildUserPrompt(
  workoutType: string,
  equipment: string[],
  existingExercises: string[]
): string {
  let prompt = `Recommend exercises for a ${workoutType} workout.\n\n`;
  prompt += `Available equipment: ${equipment.length > 0 ? equipment.join(", ") : "Bodyweight only (no equipment)"}\n\n`;

  if (existingExercises.length > 0) {
    prompt += `Exclude these exercises (already in the workout): ${existingExercises.join(", ")}\n`;
  }

  return prompt;
}
