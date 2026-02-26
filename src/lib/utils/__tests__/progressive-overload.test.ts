import { describe, it, expect } from "vitest";
import { shouldSuggestIncrease } from "../progressive-overload";

describe("shouldSuggestIncrease", () => {
  it("suggests increase when target reps hit for 3 consecutive sessions", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(true);
  });

  it("does not suggest increase when fewer than threshold sessions", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(false);
  });

  it("does not suggest increase when reps were not all hit", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 8, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(false);
  });
});
