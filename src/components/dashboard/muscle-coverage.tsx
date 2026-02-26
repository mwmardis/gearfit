"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface MuscleCoverageProps {
  coverage: { group: string; sets: number }[];
}

const ALL_GROUPS = ["chest", "back", "shoulders", "arms", "legs", "core"];

function getStatus(sets: number): "adequate" | "low" | "undertrained" {
  if (sets >= 10) return "adequate";
  if (sets >= 5) return "low";
  return "undertrained";
}

const statusColors = {
  adequate: "bg-green-500",
  low: "bg-yellow-500",
  undertrained: "bg-red-400",
};

const statusLabels = {
  adequate: "text-green-700 dark:text-green-400",
  low: "text-yellow-700 dark:text-yellow-400",
  undertrained: "text-red-600 dark:text-red-400",
};

export function MuscleCoverage({ coverage }: MuscleCoverageProps) {
  const coverageMap = new Map(coverage.map((c) => [c.group, c.sets]));

  const groups = ALL_GROUPS.map((group) => ({
    group,
    label: group.charAt(0).toUpperCase() + group.slice(1),
    sets: coverageMap.get(group) ?? 0,
  }));

  const maxSets = Math.max(10, ...groups.map((g) => g.sets));

  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Weekly Muscle Coverage</CardTitle>
        <p className="text-xs text-muted-foreground">Sets per muscle group this week</p>
      </CardHeader>
      <CardContent className="space-y-3">
        {groups.map((g) => {
          const status = getStatus(g.sets);
          const widthPercent = Math.max(2, (g.sets / maxSets) * 100);

          return (
            <div key={g.group} className="space-y-1">
              <div className="flex items-center justify-between text-xs">
                <span className="font-medium">{g.label}</span>
                <span className={statusLabels[status]}>
                  {g.sets} sets
                </span>
              </div>
              <div className="h-2 rounded-full bg-muted overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all ${statusColors[status]}`}
                  style={{ width: `${widthPercent}%` }}
                />
              </div>
            </div>
          );
        })}
        <div className="flex gap-4 pt-2 text-xs text-muted-foreground">
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-green-500" /> 10+ adequate
          </span>
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-yellow-500" /> 5-9 low
          </span>
          <span className="flex items-center gap-1">
            <span className="h-2 w-2 rounded-full bg-red-400" /> &lt;5 undertrained
          </span>
        </div>
      </CardContent>
    </Card>
  );
}
