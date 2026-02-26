import { getSessionsByMonth, getTrainingStreak } from "@/lib/actions/history";
import { HistoryClient } from "./client";

export default async function HistoryPage() {
  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth();

  const [sessions, streak] = await Promise.all([
    getSessionsByMonth(year, month),
    getTrainingStreak(),
  ]);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (
    <HistoryClient
      initialSessions={sessions as any}
      initialYear={year}
      initialMonth={month}
      streak={streak}
    />
  );
}
