import { getSharedTemplate, importSharedTemplate } from "@/lib/actions/sharing";
import { createClient } from "@/lib/supabase/server";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Download } from "lucide-react";

interface SharePageProps {
  params: Promise<{ token: string }>;
}

export default async function SharePage({ params }: SharePageProps) {
  const { token } = await params;

  let template;
  try {
    template = await getSharedTemplate(token);
  } catch {
    notFound();
  }

  // Check if user is logged in
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const importAction = importSharedTemplate.bind(null, token);

  return (
    <div className="flex min-h-screen items-start justify-center p-4 pt-16">
      <div className="w-full max-w-lg space-y-6">
        <div className="text-center">
          <p className="text-sm text-muted-foreground mb-1">Shared Workout</p>
          <h1 className="text-2xl font-bold">{template.name}</h1>
          {template.description && (
            <p className="text-muted-foreground mt-1">{template.description}</p>
          )}
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">
              Exercises ({template.template_exercises.length})
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
            {(template.template_exercises as any[]).map(
              (te: {
                id: string;
                target_sets: number;
                target_reps: number;
                target_weight: number | null;
                exercise: {
                  name: string;
                  exercise_muscles: {
                    role: string;
                    muscle: { name: string } | null;
                  }[];
                } | null;
              }) => {
                const primaryMuscles = (te.exercise?.exercise_muscles ?? [])
                  .filter((em: { role: string }) => em.role === "primary")
                  .map((em: { muscle: { name: string } | null }) => em.muscle?.name)
                  .filter(Boolean);

                return (
                  <div key={te.id} className="flex items-start justify-between rounded-md border p-3">
                    <div>
                      <p className="text-sm font-medium">
                        {te.exercise?.name ?? "Unknown"}
                      </p>
                      <div className="mt-1 flex flex-wrap gap-1">
                        {primaryMuscles.map((name) => (
                          <Badge key={name} variant="secondary" className="text-xs">
                            {name}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    <p className="text-xs text-muted-foreground whitespace-nowrap">
                      {te.target_sets}×{te.target_reps}
                      {te.target_weight ? ` @${te.target_weight}` : ""}
                    </p>
                  </div>
                );
              }
            )}
          </CardContent>
        </Card>

        {user ? (
          <form action={importAction}>
            <Button className="w-full" size="lg">
              <Download className="mr-2 h-4 w-4" />
              Import to My Workouts
            </Button>
          </form>
        ) : (
          <div className="text-center space-y-3">
            <p className="text-sm text-muted-foreground">
              Sign in to import this workout to your library.
            </p>
            <Button asChild className="w-full" size="lg">
              <Link href="/login">Sign In</Link>
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
