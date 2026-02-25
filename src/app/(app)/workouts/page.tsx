import Link from "next/link";
import { getTemplates } from "@/lib/actions/templates";
import { TemplateCard } from "@/components/workouts/template-card";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export default async function WorkoutsPage() {
  const templates = await getTemplates();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Workouts</h1>
          <p className="text-muted-foreground">Your workout templates</p>
        </div>
        <Button asChild>
          <Link href="/workouts/new">
            <Plus className="mr-2 h-4 w-4" />
            New Workout
          </Link>
        </Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {templates.map((template) => (
          <TemplateCard key={template.id} template={template} />
        ))}
      </div>

      {templates.length === 0 && (
        <div className="text-center py-12">
          <p className="text-sm text-muted-foreground mb-4">
            You haven&apos;t created any workout templates yet.
          </p>
          <Button asChild>
            <Link href="/workouts/new">Create Your First Workout</Link>
          </Button>
        </div>
      )}
    </div>
  );
}
