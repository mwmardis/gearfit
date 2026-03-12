export type TemplateForScoring = {
  id: string;
  name: string;
  muscleGroups: string[];
  lastUsedDate: string | null;
};

export type MuscleVolumeInput = {
  muscleGroup: string;
  status: "under" | "optimal" | "over";
};

export type ScoredTemplate = {
  templateId: string;
  templateName: string;
  score: number;
  reason: string;
};

export type WorkoutRecommendation = {
  type: "workout" | "rest";
  template?: { id: string; name: string; muscleGroups: string[] };
  reason: string;
};

export function scoreTemplates(
  templates: TemplateForScoring[],
  volumeStatus: MuscleVolumeInput[],
  today: string
): ScoredTemplate[] {
  if (templates.length === 0) return [];

  const underTrainedGroups = new Set(
    volumeStatus.filter((v) => v.status === "under").map((v) => v.muscleGroup)
  );

  const todayMs = new Date(today).getTime();

  return templates
    .map((t) => {
      let stalenessScore: number;
      if (t.lastUsedDate === null) {
        stalenessScore = 7;
      } else {
        const daysSince = Math.max(
          0,
          (todayMs - new Date(t.lastUsedDate).getTime()) / (1000 * 60 * 60 * 24)
        );
        stalenessScore = Math.min(daysSince, 7);
      }

      const gapScore = t.muscleGroups.filter((g) =>
        underTrainedGroups.has(g)
      ).length;

      const score = stalenessScore + gapScore * 2;

      const reasons: string[] = [];
      const underHit = t.muscleGroups.filter((g) => underTrainedGroups.has(g));
      if (underHit.length > 0) {
        reasons.push(
          `targets under-trained muscles: ${underHit.join(", ")}`
        );
      }
      if (t.lastUsedDate === null) {
        reasons.push("never used before");
      } else if (stalenessScore >= 3) {
        reasons.push(`not used in ${Math.round(stalenessScore)} days`);
      }

      return {
        templateId: t.id,
        templateName: t.name,
        score,
        reason:
          reasons.length > 0
            ? reasons.join(" and ")
            : "next in your rotation",
      };
    })
    .sort((a, b) => b.score - a.score);
}

export function getRecommendation(
  templates: TemplateForScoring[],
  volumeStatus: MuscleVolumeInput[],
  consecutiveTrainingDays: number,
  today: string
): WorkoutRecommendation {
  const allOptimalOrOver =
    volumeStatus.length > 0 &&
    volumeStatus.every((v) => v.status !== "under");

  if (allOptimalOrOver && consecutiveTrainingDays >= 5) {
    return {
      type: "rest",
      reason: `You've trained ${consecutiveTrainingDays} days straight and all muscle groups are on track. Take a rest day!`,
    };
  }

  if (templates.length === 0) {
    return {
      type: "workout",
      reason:
        "Create your first workout template to get personalized recommendations.",
    };
  }

  const scored = scoreTemplates(templates, volumeStatus, today);
  const top = scored[0];
  const template = templates.find((t) => t.id === top.templateId)!;

  return {
    type: "workout",
    template: {
      id: template.id,
      name: template.name,
      muscleGroups: template.muscleGroups,
    },
    reason: top.reason.charAt(0).toUpperCase() + top.reason.slice(1),
  };
}
