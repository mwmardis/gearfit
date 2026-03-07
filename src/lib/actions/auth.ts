// src/lib/actions/auth.ts
"use server";

import { signIn, signOut } from "@/lib/auth";
import { db } from "@/lib/db";
import { users, profiles } from "@/lib/db/schema";
import { redirect } from "next/navigation";
import bcrypt from "bcryptjs";

export async function signUp(
  _prevState: { error: string },
  formData: FormData
) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;
  const displayName = formData.get("displayName") as string;

  try {
    const passwordHash = await bcrypt.hash(password, 12);

    // Create profile first (equivalent to Supabase handle_new_user trigger)
    const [profile] = await db
      .insert(profiles)
      .values({
        id: crypto.randomUUID(),
        displayName,
      })
      .returning();

    // Create auth user linked to profile
    await db.insert(users).values({
      email,
      name: displayName,
      passwordHash,
      profileId: profile.id,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Sign up failed";
    if (message.includes("unique") || message.includes("duplicate")) {
      return { error: "An account with this email already exists" };
    }
    return { error: message };
  }

  // Auto sign-in after registration
  await signIn("credentials", { email, password, redirect: false });
  redirect("/");
}

export async function logIn(
  _prevState: { error: string },
  formData: FormData
) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  try {
    await signIn("credentials", { email, password, redirect: false });
  } catch {
    return { error: "Invalid email or password" };
  }

  redirect("/");
}

export async function handleSignOut() {
  await signOut({ redirect: false });
  redirect("/login");
}
