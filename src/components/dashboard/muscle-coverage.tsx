"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Target } from "lucide-react";

interface MuscleCoverageProps {
  coverage: { group: string; sets: number }[];
}

const ALL_GROUPS = ["chest", "back", "shoulders", "arms", "legs", "core"];

function getStatus(sets: number): "adequate" | "low" | "undertrained" {
  if (sets >= 10) return "adequate";
  if (sets >= 5) return "low";
  return "undertrained";
}

const statusConfig = {
  adequate: {
    bar: "from-emerald-400 to-emerald-500",
    text: "text-emerald-600 dark:text-emerald-400",
    dot: "bg-emerald-500",
    label: "10+ adequate",
  },
  low: {
    bar: "from-amber-400 to-amber-500",
    text: "text-amber-600 dark:text-amber-400",
    dot: "bg-amber-500",
    label: "5-9 low",
  },
  undertrained: {
    bar: "from-rose-400 to-rose-500",
    text: "text-rose-500 dark:text-rose-400",
    dot: "bg-rose-500",
    label: "<5 needs work",
  },
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
    <Card className="card-hover overflow-hidden">
      <CardHeader className="pb-3">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-chart-3/15">
            <Target className="h-3.5 w-3.5 text-chart-3" />
          </div>
          <div>
            <CardTitle className="font-display text-sm font-bold">
              Weekly Muscle Coverage
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Sets per muscle group this week
            </p>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-3">
        {groups.map((g, i) => {
          const status = getStatus(g.sets);
          const widthPercent = Math.max(3, (g.sets / maxSets) * 100);
          const config = statusConfig[status];

          return (
            <div key={g.group} className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold">{g.label}</span>
                <span className={`font-mono font-medium ${config.text}`}>
                  {g.sets} sets
                </span>
              </div>
              <div className="h-2.5 rounded-full bg-muted/80 overflow-hidden">
                <div
                  className={`h-full rounded-full bg-gradient-to-r ${config.bar} animate-bar-fill`}
                  style={{
                    width: `${widthPercent}%`,
                    animationDelay: `${i * 100 + 200}ms`,
                  }}
                />
              </div>
            </div>
          );
        })}

        {/* Legend */}
        <div className="flex flex-wrap gap-3 pt-3 text-xs text-muted-foreground">
          {(Object.keys(statusConfig) as Array<keyof typeof statusConfig>).map(
            (key) => (
              <span key={key} className="flex items-center gap-1.5">
                <span
                  className={`h-2 w-2 rounded-full ${statusConfig[key].dot}`}
                />
                {statusConfig[key].label}
              </span>
            )
          )}
        </div>
      </CardContent>
    </Card>
  );
}
