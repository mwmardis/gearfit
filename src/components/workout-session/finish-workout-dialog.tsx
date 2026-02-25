"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Flag } from "lucide-react";

interface FinishWorkoutDialogProps {
  exerciseCount: number;
  totalSetsLogged: number;
  durationMinutes: number;
  onFinish: (notes: string) => void;
  isPending: boolean;
}

export function FinishWorkoutDialog({
  exerciseCount,
  totalSetsLogged,
  durationMinutes,
  onFinish,
  isPending,
}: FinishWorkoutDialogProps) {
  const [open, setOpen] = useState(false);
  const [notes, setNotes] = useState("");

  function handleFinish() {
    onFinish(notes);
  }

  const hours = Math.floor(durationMinutes / 60);
  const mins = durationMinutes % 60;
  const durationText = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button className="w-full" size="lg">
          <Flag className="mr-2 h-4 w-4" />
          Finish Workout
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Finish Workout?</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p className="text-2xl font-bold">{exerciseCount}</p>
              <p className="text-xs text-muted-foreground">Exercises</p>
            </div>
            <div>
              <p className="text-2xl font-bold">{totalSetsLogged}</p>
              <p className="text-xs text-muted-foreground">Sets</p>
            </div>
            <div>
              <p className="text-2xl font-bold">{durationText}</p>
              <p className="text-xs text-muted-foreground">Duration</p>
            </div>
          </div>
          <div className="space-y-2">
            <label htmlFor="notes" className="text-sm font-medium">
              Notes (optional)
            </label>
            <Input
              id="notes"
              placeholder="How did it go?"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>
          <Button
            className="w-full"
            onClick={handleFinish}
            disabled={isPending}
          >
            {isPending ? "Saving..." : "Save Workout"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
