"use client";

import { useState } from "react";
import { WorkoutCalendar } from "@/components/history/workout-calendar";
import { SessionSummary } from "@/components/history/session-summary";
import { getSessionsByMonth } from "@/lib/actions/history";

interface Session {
  id: string;
  date: string;
  completed: boolean;
  duration_minutes: number | null;
  notes: string | null;
  template: { id: string; name: string } | null;
  session_sets: {
    exercise_id: string;
    exercise: { name: string } | null;
  }[];
}

interface HistoryClientProps {
  initialSessions: Session[];
  initialYear: number;
  initialMonth: number;
  streak: number;
}

export function HistoryClient({
  initialSessions,
  initialYear,
  initialMonth,
  streak,
}: HistoryClientProps) {
  const [sessions, setSessions] = useState(initialSessions);
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  async function handleMonthChange(year: number, month: number) {
    const data = await getSessionsByMonth(year, month);
    setSessions(data as unknown as Session[]);
    setSelectedDate(null);
    return data as unknown as Session[];
  }

  const filteredSessions = selectedDate
    ? sessions.filter((s) => s.date === selectedDate)
    : sessions;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">History</h1>
        <p className="text-muted-foreground">Your workout history</p>
      </div>

      <WorkoutCalendar
        initialSessions={initialSessions}
        initialYear={initialYear}
        initialMonth={initialMonth}
        streak={streak}
        onMonthChange={handleMonthChange}
        onDaySelect={(date) =>
          setSelectedDate(date === selectedDate ? null : date)
        }
        selectedDate={selectedDate}
      />

      <div className="space-y-2">
        {selectedDate && (
          <p className="text-sm text-muted-foreground">
            {new Date(selectedDate + "T12:00:00").toLocaleDateString("en-US", {
              weekday: "long",
              month: "long",
              day: "numeric",
            })}
          </p>
        )}
        {filteredSessions.map((session) => (
          <SessionSummary key={session.id} session={session} />
        ))}
        {filteredSessions.length === 0 && (
          <p className="text-center text-sm text-muted-foreground py-4">
            {selectedDate
              ? "No workouts on this day."
              : "No workouts this month."}
          </p>
        )}
      </div>
    </div>
  );
}
