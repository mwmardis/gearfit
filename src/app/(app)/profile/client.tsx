"use client";

import { useTransition, useState } from "react";
import { updateProfile } from "@/lib/actions/profile";
import { handleSignOut } from "@/lib/actions/auth";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { LogOut, Save } from "lucide-react";
import { type InferSelectModel } from "drizzle-orm";
import { profiles } from "@/lib/db/schema";

type Profile = InferSelectModel<typeof profiles>;

interface ProfileFormProps {
  profile: Profile;
  email: string;
}

export function ProfileForm({ profile, email }: ProfileFormProps) {
  const [isPending, startTransition] = useTransition();
  const [saved, setSaved] = useState(false);
  const [units, setUnits] = useState(profile.preferredUnits);
  const [trainingGoal, setTrainingGoal] = useState(profile.trainingGoal ?? "hypertrophy");

  function handleSubmit(formData: FormData) {
    setSaved(false);
    startTransition(async () => {
      await updateProfile(formData);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    });
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Profile</h1>
        <p className="text-muted-foreground">Your account settings</p>
      </div>

      <form action={handleSubmit} className="space-y-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Account</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input id="email" value={email} disabled />
            </div>
            <div className="space-y-2">
              <Label htmlFor="display_name">Display Name</Label>
              <Input
                id="display_name"
                name="display_name"
                defaultValue={profile.displayName ?? ""}
                placeholder="Your name"
              />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Preferences</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Preferred Units</Label>
              <div className="flex gap-2">
                <input type="hidden" name="preferred_units" value={units} />
                <Button
                  type="button"
                  variant={units === "lbs" ? "default" : "outline"}
                  size="sm"
                  onClick={() => setUnits("lbs")}
                >
                  lbs
                </Button>
                <Button
                  type="button"
                  variant={units === "kg" ? "default" : "outline"}
                  size="sm"
                  onClick={() => setUnits("kg")}
                >
                  kg
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Training Goal</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Goal</Label>
              <div className="flex gap-2">
                <input type="hidden" name="training_goal" value={trainingGoal} />
                {(["hypertrophy", "strength", "endurance"] as const).map((goal) => (
                  <Button
                    key={goal}
                    type="button"
                    variant={trainingGoal === goal ? "default" : "outline"}
                    size="sm"
                    onClick={() => setTrainingGoal(goal)}
                  >
                    {goal.charAt(0).toUpperCase() + goal.slice(1)}
                  </Button>
                ))}
              </div>
              <p className="text-xs text-muted-foreground">
                Adjusts your weekly volume targets on the dashboard.
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Progressive Overload</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="overload_sessions_threshold">
                Sessions before suggesting increase
              </Label>
              <Input
                id="overload_sessions_threshold"
                name="overload_sessions_threshold"
                type="number"
                min={1}
                max={10}
                defaultValue={profile.overloadSessionsThreshold}
              />
              <p className="text-xs text-muted-foreground">
                Number of consecutive sessions hitting target reps before
                suggesting a weight increase.
              </p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="overload_increment_lbs">Increment (lbs)</Label>
                <Input
                  id="overload_increment_lbs"
                  name="overload_increment_lbs"
                  type="number"
                  min={0.5}
                  step={0.5}
                  defaultValue={profile.overloadIncrementLbs}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="overload_increment_kg">Increment (kg)</Label>
                <Input
                  id="overload_increment_kg"
                  name="overload_increment_kg"
                  type="number"
                  min={0.5}
                  step={0.5}
                  defaultValue={profile.overloadIncrementKg}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        <Button type="submit" disabled={isPending}>
          <Save className="mr-2 h-4 w-4" />
          {isPending ? "Saving..." : saved ? "Saved!" : "Save Changes"}
        </Button>
      </form>

      <Separator />

      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Account Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <form action={handleSignOut}>
            <Button variant="outline" type="submit">
              <LogOut className="mr-2 h-4 w-4" />
              Sign Out
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
