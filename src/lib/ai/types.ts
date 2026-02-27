export interface GeminiExerciseSuggestion {
  name: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
  suggestedSets: number;
  suggestedReps: number;
  description: string;
  instructions: string;
}

export interface ExerciseRecommendation extends GeminiExerciseSuggestion {
  existsInDb: boolean;
  existingExerciseId?: string;
}

export interface RecommendRequest {
  workoutType: string;
  equipment: string[];
  existingExercises?: string[];
}
