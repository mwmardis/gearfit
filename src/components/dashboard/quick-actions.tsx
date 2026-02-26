import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Dumbbell, Search, Plus, Settings } from "lucide-react";

export function QuickActions() {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Quick Actions</CardTitle>
      </CardHeader>
      <CardContent className="grid grid-cols-2 gap-2">
        <Button variant="outline" asChild className="h-auto flex-col gap-1 py-3">
          <Link href="/workouts">
            <Dumbbell className="h-4 w-4" />
            <span className="text-xs">Start Workout</span>
          </Link>
        </Button>
        <Button variant="outline" asChild className="h-auto flex-col gap-1 py-3">
          <Link href="/exercises">
            <Search className="h-4 w-4" />
            <span className="text-xs">Browse Exercises</span>
          </Link>
        </Button>
        <Button variant="outline" asChild className="h-auto flex-col gap-1 py-3">
          <Link href="/workouts/new">
            <Plus className="h-4 w-4" />
            <span className="text-xs">New Template</span>
          </Link>
        </Button>
        <Button variant="outline" asChild className="h-auto flex-col gap-1 py-3">
          <Link href="/equipment">
            <Settings className="h-4 w-4" />
            <span className="text-xs">Equipment</span>
          </Link>
        </Button>
      </CardContent>
    </Card>
  );
}
