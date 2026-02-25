import Link from "next/link";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

interface TemplateCardProps {
  template: {
    id: string;
    name: string;
    description: string | null;
    updated_at: string;
    template_exercises: {
      id: string;
      exercise: { name: string } | null;
    }[];
  };
}

export function TemplateCard({ template }: TemplateCardProps) {
  const exerciseCount = template.template_exercises.length;

  return (
    <Link href={`/workouts/${template.id}`}>
      <Card className="h-full transition-colors hover:bg-accent/50">
        <CardHeader className="pb-2">
          <CardTitle className="text-base">{template.name}</CardTitle>
          {template.description && (
            <p className="text-xs text-muted-foreground">
              {template.description}
            </p>
          )}
        </CardHeader>
        <CardContent>
          <div className="mb-2 flex flex-wrap gap-1">
            {template.template_exercises.slice(0, 4).map((te) => (
              <Badge key={te.id} variant="secondary" className="text-xs">
                {te.exercise?.name ?? "Unknown"}
              </Badge>
            ))}
            {exerciseCount > 4 && (
              <Badge variant="outline" className="text-xs">
                +{exerciseCount - 4} more
              </Badge>
            )}
          </div>
          <p className="text-xs text-muted-foreground">
            {exerciseCount} {exerciseCount === 1 ? "exercise" : "exercises"}
          </p>
        </CardContent>
      </Card>
    </Link>
  );
}
