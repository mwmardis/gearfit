"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { BarChart3 } from "lucide-react";
import { type MuscleVolumeStatus } from "@/lib/volume-analysis";

interface VolumeReportProps {
  volumeStatus: MuscleVolumeStatus[];
}

const statusConfig = {
  under: {
    bar: "from-rose-400 to-rose-500",
    text: "text-rose-500 dark:text-rose-400",
    dot: "bg-rose-500",
    label: "Under",
  },
  optimal: {
    bar: "from-emerald-400 to-emerald-500",
    text: "text-emerald-600 dark:text-emerald-400",
    dot: "bg-emerald-500",
    label: "Optimal",
  },
  over: {
    bar: "from-amber-400 to-amber-500",
    text: "text-amber-600 dark:text-amber-400",
    dot: "bg-amber-500",
    label: "Over",
  },
};

export function VolumeReport({ volumeStatus }: VolumeReportProps) {
  const maxSets = Math.max(
    1,
    ...volumeStatus.map((v) => Math.max(v.currentSets, v.targetMax))
  );

  return (
    <Card className="card-hover overflow-hidden">
      <CardHeader className="pb-3">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-primary/15">
            <BarChart3 className="h-3.5 w-3.5 text-primary" />
          </div>
          <div>
            <CardTitle className="font-display text-sm font-bold">
              Weekly Volume
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Sets vs target range (7-day rolling)
            </p>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-3">
        {volumeStatus.map((v, i) => {
          const config = statusConfig[v.status];
          const currentPercent = Math.max(3, (v.currentSets / maxSets) * 100);
          const minPercent = (v.targetMin / maxSets) * 100;
          const maxPercent = (v.targetMax / maxSets) * 100;

          return (
            <div key={v.muscleGroup} className="space-y-1.5">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold capitalize">
                  {v.muscleGroup}
                </span>
                <span className={`font-mono font-medium ${config.text}`}>
                  {v.currentSets} / {v.targetMin}-{v.targetMax}
                </span>
              </div>
              <div className="relative h-2.5 rounded-full bg-muted/80 overflow-hidden">
                {/* Target range indicator */}
                <div
                  className="absolute top-0 h-full bg-muted-foreground/10 rounded-full"
                  style={{
                    left: `${minPercent}%`,
                    width: `${maxPercent - minPercent}%`,
                  }}
                />
                {/* Current volume bar */}
                <div
                  className={`h-full rounded-full bg-gradient-to-r ${config.bar} animate-bar-fill relative z-10`}
                  style={{
                    width: `${currentPercent}%`,
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
