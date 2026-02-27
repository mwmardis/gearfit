import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { generateExerciseRecommendations } from "@/lib/ai/gemini";
import { buildSystemPrompt, buildUserPrompt } from "@/lib/ai/prompts";
import type { ExerciseRecommendation, RecommendRequest } from "@/lib/ai/types";

// Simple in-memory rate limiter
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(userId: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(userId);

  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(userId, { count: 1, resetAt: now + 60_000 });
    return true;
  }

  if (entry.count >= 10) return false;
  entry.count++;
  return true;
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    if (!checkRateLimit(user.id)) {
      return NextResponse.json(
        { error: "Too many requests. Please wait a minute." },
        { status: 429 }
      );
    }

    const body = (await request.json()) as RecommendRequest;

    if (!body.workoutType || !Array.isArray(body.equipment)) {
      return NextResponse.json(
        { error: "workoutType and equipment are required" },
        { status: 400 }
      );
    }

    const systemPrompt = buildSystemPrompt();
    const userPrompt = buildUserPrompt(
      body.workoutType,
      body.equipment,
      body.existingExercises ?? []
    );

    const suggestions = await generateExerciseRecommendations(
      systemPrompt,
      userPrompt
    );

    // Fuzzy match against existing exercises in DB
    const { data: dbExercises } = await supabase
      .from("exercises")
      .select("id, name")
      .or(`is_custom.eq.false,created_by.eq.${user.id}`);

    const recommendations: ExerciseRecommendation[] = suggestions.map((s) => {
      const match = dbExercises?.find(
        (e) => e.name.toLowerCase() === s.name.toLowerCase()
      );
      return {
        ...s,
        existsInDb: !!match,
        existingExerciseId: match?.id,
      };
    });

    return NextResponse.json({ recommendations });
  } catch (error) {
    console.error("AI recommendation error:", error);
    return NextResponse.json(
      { error: "Failed to generate recommendations. Please try again." },
      { status: 500 }
    );
  }
}
