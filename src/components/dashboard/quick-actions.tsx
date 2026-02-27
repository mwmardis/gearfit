import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Dumbbell, Search, Plus, Settings, Sparkles } from "lucide-react";

const actions = [
  {
    href: "/workouts",
    label: "Start Workout",
    icon: Dumbbell,
    gradient: "from-primary/15 to-primary/5",
    iconColor: "text-primary",
  },
  {
    href: "/exercises",
    label: "Browse Exercises",
    icon: Search,
    gradient: "from-chart-2/15 to-chart-2/5",
    iconColor: "text-chart-2",
  },
  {
    href: "/workouts/new",
    label: "New Template",
    icon: Plus,
    gradient: "from-chart-3/15 to-chart-3/5",
    iconColor: "text-chart-3",
  },
  {
    href: "/equipment",
    label: "Equipment",
    icon: Settings,
    gradient: "from-chart-4/15 to-chart-4/5",
    iconColor: "text-chart-4",
  },
];

export function QuickActions() {
  return (
    <Card className="card-hover">
      <CardHeader className="pb-3">
        <div className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-chart-4/15">
            <Sparkles className="h-3.5 w-3.5 text-chart-4" />
          </div>
          <CardTitle className="font-display text-sm font-bold">
            Quick Actions
          </CardTitle>
        </div>
      </CardHeader>
      <CardContent className="grid grid-cols-2 gap-2.5">
        {actions.map(({ href, label, icon: Icon, gradient, iconColor }) => (
          <Link
            key={href}
            href={href}
            className={`group flex flex-col items-center gap-2 rounded-xl bg-gradient-to-br ${gradient} p-4 transition-all duration-200 hover:scale-[1.03] hover:shadow-md`}
          >
            <Icon
              className={`h-5 w-5 ${iconColor} transition-transform duration-200 group-hover:scale-110`}
            />
            <span className="text-xs font-semibold">{label}</span>
          </Link>
        ))}
      </CardContent>
    </Card>
  );
}
