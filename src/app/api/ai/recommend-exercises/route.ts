// src/app/api/ai/recommend-exercises/route.ts
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { exercises, equipment } from "@/lib/db/schema";
import { or, eq } from "drizzle-orm";
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
    const session = await auth();
    if (!session?.user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const userId = session.user.id!;
    const profileId = (session.user as { profileId?: string }).profileId;

    if (!checkRateLimit(userId)) {
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

    const suggestions = await generateExerciseRecommendations(systemPrompt, userPrompt);

    // Fuzzy match against existing exercises in DB
    const dbExercises = await db
      .select({ id: exercises.id, name: exercises.name })
      .from(exercises)
      .where(
        profileId
          ? or(eq(exercises.isCustom, false), eq(exercises.createdBy, profileId))
          : eq(exercises.isCustom, false)
      );

    const recommendations: ExerciseRecommendation[] = suggestions.map((s) => {
      const match = dbExercises.find(
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
