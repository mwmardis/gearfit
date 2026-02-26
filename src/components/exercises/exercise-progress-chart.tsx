"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface ProgressDataPoint {
  date: string;
  maxWeight: number;
  totalVolume: number;
}

interface PersonalBests {
  maxWeight: number;
  maxReps: number;
  maxVolume: number;
}

interface ExerciseProgressChartProps {
  data: ProgressDataPoint[];
  personalBests: PersonalBests | null;
}

export function ExerciseProgressChart({
  data,
  personalBests,
}: ExerciseProgressChartProps) {
  if (data.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-center text-sm text-muted-foreground py-4">
            No workout history yet for this exercise.
          </p>
        </CardContent>
      </Card>
    );
  }

  const formattedData = data.map((d) => ({
    ...d,
    label: new Date(d.date + "T12:00:00").toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
    }),
  }));

  return (
    <div className="space-y-4">
      {personalBests && (
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Personal Bests</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-xl font-bold">{personalBests.maxWeight}</p>
                <p className="text-xs text-muted-foreground">Max Weight (lbs)</p>
              </div>
              <div>
                <p className="text-xl font-bold">{personalBests.maxReps}</p>
                <p className="text-xs text-muted-foreground">Max Reps</p>
              </div>
              <div>
                <p className="text-xl font-bold">{personalBests.maxVolume}</p>
                <p className="text-xs text-muted-foreground">Max Volume</p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Weight Over Time</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={formattedData}>
                <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
                <XAxis
                  dataKey="label"
                  tick={{ fontSize: 12 }}
                  interval="preserveStartEnd"
                />
                <YAxis
                  tick={{ fontSize: 12 }}
                  domain={["dataMin - 5", "dataMax + 5"]}
                />
                <Tooltip
                  contentStyle={{
                    fontSize: 12,
                    borderRadius: 8,
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="maxWeight"
                  stroke="hsl(var(--primary))"
                  strokeWidth={2}
                  dot={{ r: 3 }}
                  name="Max Weight (lbs)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
