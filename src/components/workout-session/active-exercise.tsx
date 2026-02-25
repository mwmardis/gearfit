"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import { SetLogger } from "./set-logger";

interface PreviousSet {
  set_number: number;
  weight: number;
  reps: number;
  rpe: number | null;
}

interface LoggedSet {
  setNumber: number;
  weight: number;
  reps: number;
}

interface ActiveExerciseProps {
  exerciseId: string;
  exerciseName: string;
  targetSets: number;
  targetReps: number;
  targetWeight: number | null;
  previousSets: PreviousSet[] | null;
  loggedSets: LoggedSet[];
  onLogSet: (exerciseId: string, setNumber: number, weight: number, reps: number) => void;
}

export function ActiveExercise({
  exerciseId,
  exerciseName,
  targetSets,
  targetReps,
  targetWeight,
  previousSets,
  loggedSets,
  onLogSet,
}: ActiveExerciseProps) {
  const [extraSets, setExtraSets] = useState(0);
  const totalSets = targetSets + extraSets;

  function handleLog(setNumber: number, weight: number, reps: number) {
    onLogSet(exerciseId, setNumber, weight, reps);
  }

  const completedCount = loggedSets.length;

  return (
    <Card>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <CardTitle className="text-base">{exerciseName}</CardTitle>
          <Badge variant="outline" className="text-xs">
            {completedCount}/{totalSets}
          </Badge>
        </div>
        <p className="text-xs text-muted-foreground">
          Target: {targetSets} × {targetReps}
          {targetWeight ? ` @ ${targetWeight} lbs` : ""}
        </p>
      </CardHeader>
      <CardContent className="space-y-2">
        {Array.from({ length: totalSets }, (_, i) => {
          const setNumber = i + 1;
          const previous = previousSets?.find(
            (ps) => ps.set_number === setNumber
          );
          const logged = loggedSets.find((ls) => ls.setNumber === setNumber);

          return (
            <SetLogger
              key={setNumber}
              setNumber={setNumber}
              defaultWeight={targetWeight}
              defaultReps={targetReps}
              previousSet={previous}
              logged={logged ? { weight: logged.weight, reps: logged.reps } : null}
              onLog={(weight, reps) => handleLog(setNumber, weight, reps)}
            />
          );
        })}
        <Button
          variant="ghost"
          size="sm"
          className="w-full text-xs"
          onClick={() => setExtraSets((s) => s + 1)}
        >
          <Plus className="mr-1 h-3 w-3" />
          Add Set
        </Button>
      </CardContent>
    </Card>
  );
}
