import { createTemplate } from "@/lib/actions/templates";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

export default function NewTemplatePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">New Workout</h1>
        <p className="text-muted-foreground">
          Create a new workout template
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Template Details</CardTitle>
        </CardHeader>
        <CardContent>
          <form action={createTemplate} className="space-y-4">
            <div className="space-y-2">
              <label htmlFor="name" className="text-sm font-medium">
                Name
              </label>
              <Input
                id="name"
                name="name"
                placeholder="e.g., Push Day, Upper Body, Leg Day"
                required
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="description" className="text-sm font-medium">
                Description (optional)
              </label>
              <Input
                id="description"
                name="description"
                placeholder="Brief description of this workout"
              />
            </div>
            <Button type="submit">Create Workout</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
