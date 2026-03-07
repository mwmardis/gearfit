"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ChevronLeft, ChevronRight, Flame } from "lucide-react";

interface Session {
  id: string;
  date: string;
  durationMinutes: number | null;
  template: { name: string } | null;
}

interface WorkoutCalendarProps {
  initialSessions: Session[];
  initialYear: number;
  initialMonth: number;
  streak: number;
  onMonthChange: (year: number, month: number) => Promise<Session[]>;
  onDaySelect: (date: string) => void;
  selectedDate: string | null;
}

export function WorkoutCalendar({
  initialSessions,
  initialYear,
  initialMonth,
  streak,
  onMonthChange,
  onDaySelect,
  selectedDate,
}: WorkoutCalendarProps) {
  const [year, setYear] = useState(initialYear);
  const [month, setMonth] = useState(initialMonth);
  const [sessions, setSessions] = useState(initialSessions);
  const [isPending, startTransition] = useTransition();

  const sessionDates = new Set(sessions.map((s) => s.date));

  const monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const firstDayOfWeek = new Date(year, month, 1).getDay();
  const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  function navigate(direction: -1 | 1) {
    let newMonth = month + direction;
    let newYear = year;
    if (newMonth < 0) {
      newMonth = 11;
      newYear--;
    } else if (newMonth > 11) {
      newMonth = 0;
      newYear++;
    }

    setMonth(newMonth);
    setYear(newYear);

    startTransition(async () => {
      const data = await onMonthChange(newYear, newMonth);
      setSessions(data);
    });
  }

  function handleDayClick(day: number) {
    const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
    onDaySelect(dateStr);
  }

  return (
    <Card>
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CardTitle className="text-base">
              {monthNames[month]} {year}
            </CardTitle>
            {streak > 0 && (
              <span className="flex items-center gap-1 text-xs text-orange-500">
                <Flame className="h-3 w-3" />
                {streak} week streak
              </span>
            )}
          </div>
          <div className="flex gap-1">
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              onClick={() => navigate(-1)}
              disabled={isPending}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              onClick={() => navigate(1)}
              disabled={isPending}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-7 gap-1">
          {dayNames.map((name) => (
            <div
              key={name}
              className="text-center text-xs font-medium text-muted-foreground py-1"
            >
              {name}
            </div>
          ))}
          {/* Empty cells before first day */}
          {Array.from({ length: firstDayOfWeek }, (_, i) => (
            <div key={`empty-${i}`} />
          ))}
          {/* Day cells */}
          {Array.from({ length: daysInMonth }, (_, i) => {
            const day = i + 1;
            const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
            const hasSession = sessionDates.has(dateStr);
            const isSelected = selectedDate === dateStr;

            return (
              <button
                key={day}
                onClick={() => handleDayClick(day)}
                className={`relative flex flex-col items-center justify-center rounded-md p-1 text-sm transition-colors ${
                  isSelected
                    ? "bg-primary text-primary-foreground"
                    : hasSession
                      ? "bg-accent font-medium hover:bg-accent/80"
                      : "hover:bg-muted"
                }`}
              >
                {day}
                {hasSession && !isSelected && (
                  <span className="absolute bottom-0.5 h-1 w-1 rounded-full bg-primary" />
                )}
              </button>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
