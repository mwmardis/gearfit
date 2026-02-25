"use client";

import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";

interface PreviousSet {
  set_number: number;
  weight: number;
  reps: number;
  rpe: number | null;
}

interface SetLoggerProps {
  setNumber: number;
  defaultWeight?: number | null;
  defaultReps?: number;
  previousSet?: PreviousSet | null;
  logged?: { weight: number; reps: number } | null;
  onLog: (weight: number, reps: number) => void;
}

export function SetLogger({
  setNumber,
  defaultWeight,
  defaultReps,
  previousSet,
  logged,
  onLog,
}: SetLoggerProps) {
  const [weight, setWeight] = useState(
    logged?.weight?.toString() ??
      previousSet?.weight?.toString() ??
      defaultWeight?.toString() ??
      ""
  );
  const [reps, setReps] = useState(
    logged?.reps?.toString() ??
      previousSet?.reps?.toString() ??
      defaultReps?.toString() ??
      ""
  );
  const isLogged = logged != null;

  function handleLog() {
    const w = parseFloat(weight);
    const r = parseInt(reps, 10);
    if (isNaN(w) || isNaN(r) || w < 0 || r < 1) return;
    onLog(w, r);
  }

  return (
    <div
      className={`flex items-center gap-2 rounded-md border p-2 ${
        isLogged ? "border-green-500/50 bg-green-50 dark:bg-green-950/20" : ""
      }`}
    >
      <span className="w-8 text-center text-xs font-medium text-muted-foreground">
        {setNumber}
      </span>

      {/* Previous set reference */}
      {previousSet && !isLogged && (
        <span className="text-xs text-muted-foreground/60 min-w-[60px]">
          {previousSet.weight}×{previousSet.reps}
        </span>
      )}

      <Input
        type="number"
        min={0}
        step={0.5}
        placeholder="lbs"
        value={weight}
        onChange={(e) => setWeight(e.target.value)}
        className="h-8 w-20 text-sm"
        disabled={isLogged}
      />
      <span className="text-xs text-muted-foreground">×</span>
      <Input
        type="number"
        min={1}
        placeholder="reps"
        value={reps}
        onChange={(e) => setReps(e.target.value)}
        className="h-8 w-16 text-sm"
        disabled={isLogged}
      />
      <Button
        variant={isLogged ? "default" : "outline"}
        size="icon"
        className="h-8 w-8 shrink-0"
        onClick={handleLog}
        disabled={isLogged}
      >
        <Check className="h-4 w-4" />
      </Button>
    </div>
  );
}
