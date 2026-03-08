"use client";

import { useActionState } from "react";
import { logIn } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import Link from "next/link";
import { Flame } from "lucide-react";

export default function LoginPage() {
  const [state, action, isPending] = useActionState(logIn, { error: "" });

  return (
    <div className="relative flex min-h-screen items-center justify-center p-4 bg-mesh">
      {/* Decorative blobs */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute -top-32 -right-32 h-96 w-96 rounded-full bg-primary/10 blur-3xl" />
        <div className="absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-chart-2/10 blur-3xl" />
      </div>

      <div className="relative w-full max-w-sm animate-fade-up">
        {/* Brand */}
        <div className="mb-8 flex flex-col items-center gap-3">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-energy shadow-xl">
            <Flame className="h-7 w-7 text-white" />
          </div>
          <h1 className="font-display text-2xl font-extrabold tracking-tight gradient-text">
            GearFit
          </h1>
        </div>

        <Card className="border-border/50 shadow-xl">
          <CardHeader className="text-center">
            <CardTitle className="font-display text-xl font-bold">
              Welcome back
            </CardTitle>
            <CardDescription>Sign in to your account</CardDescription>
          </CardHeader>
          <CardContent>
            <form action={action} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email" className="text-sm font-semibold">
                  Email
                </Label>
                <Input
                  id="email"
                  name="email"
                  type="email"
                  required
                  className="h-11 rounded-xl"
                  placeholder="you@example.com"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="password" className="text-sm font-semibold">
                  Password
                </Label>
                <Input
                  id="password"
                  name="password"
                  type="password"
                  required
                  className="h-11 rounded-xl"
                  placeholder="••••••••"
                />
              </div>
              {state.error && (
                <p className="rounded-lg bg-destructive/10 px-3 py-2 text-sm font-medium text-destructive">
                  {state.error}
                </p>
              )}
              <Button
                type="submit"
                className="btn-glow h-11 w-full rounded-xl bg-gradient-energy font-semibold text-white"
                disabled={isPending}
              >
                {isPending ? "Signing in..." : "Sign In"}
              </Button>
            </form>
            <p className="mt-6 text-center text-sm text-muted-foreground">
              No account?{" "}
              <Link
                href="/signup"
                className="font-semibold text-primary hover:underline"
              >
                Sign up
              </Link>
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
