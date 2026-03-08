# GearFit Supabase Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate GearFit from Supabase (DB + Auth) to Neon (Postgres) + Drizzle ORM + Auth.js v5, keeping Vercel deployment.

**Architecture:** Replace the Supabase client layer with Drizzle ORM connecting to Neon serverless Postgres. Replace Supabase Auth with Auth.js v5 using Credentials + Email providers. RLS authorization moves into server actions. All existing server actions are rewritten from Supabase query builder to Drizzle queries.

**Tech Stack:** Next.js 16, Drizzle ORM, @neondatabase/serverless, Auth.js v5 (next-auth), Resend (email), Vercel

---

## Task 1: Install Dependencies

**Files:**
- Modify: `package.json`

**Step 1: Install Neon + Drizzle packages**

Run: `npm install drizzle-orm @neondatabase/serverless`
Run: `npm install -D drizzle-kit`

**Step 2: Install Auth.js packages**

Run: `npm install next-auth@beta @auth/drizzle-adapter`
Run: `npm install bcryptjs`
Run: `npm install -D @types/bcryptjs`

**Step 3: Verify installation**

Run: `npm ls drizzle-orm next-auth @neondatabase/serverless bcryptjs`
Expected: All packages listed without errors

**Step 4: Commit**

```bash
git add package.json package-lock.json
git commit -m "chore: install Neon, Drizzle, Auth.js, and bcryptjs"
```

---

## Task 2: Define Drizzle Schema

**Files:**
- Create: `src/lib/db/schema.ts`
- Reference: `src/lib/database.types.ts` (for current types), `supabase/migrations/` (for constraints)

This schema must exactly match the existing Supabase tables so pg_dump data is compatible.

**Step 1: Create the Drizzle schema file**

```typescript
// src/lib/db/schema.ts
import {
  pgTable,
  uuid,
  text,
  boolean,
  integer,
  numeric,
  date,
  timestamp,
  unique,
  check,
} from "drizzle-orm/pg-core";
import { relations, sql } from "drizzle-orm";

// ── profiles ──────────────────────────────────────────────
export const profiles = pgTable("profiles", {
  id: uuid("id").primaryKey(),
  displayName: text("display_name"),
  avatarUrl: text("avatar_url"),
  preferredUnits: text("preferred_units").notNull().default("lbs"),
  overloadSessionsThreshold: integer("overload_sessions_threshold").notNull().default(3),
  overloadIncrementLbs: numeric("overload_increment_lbs").notNull().default("5"),
  overloadIncrementKg: numeric("overload_increment_kg").notNull().default("2.5"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment ─────────────────────────────────────────────
export const equipment = pgTable("equipment", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  category: text("category"),
  icon: text("icon"),
  isCustom: boolean("is_custom").notNull().default(false),
  createdBy: uuid("created_by").references(() => profiles.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── muscles ───────────────────────────────────────────────
export const muscles = pgTable("muscles", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull().unique(),
  muscleGroup: text("muscle_group").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment_profiles ────────────────────────────────────
export const equipmentProfiles = pgTable("equipment_profiles", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  isActive: boolean("is_active").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── equipment_profile_items ───────────────────────────────
export const equipmentProfileItems = pgTable(
  "equipment_profile_items",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    equipmentProfileId: uuid("equipment_profile_id")
      .notNull()
      .references(() => equipmentProfiles.id, { onDelete: "cascade" }),
    equipmentId: uuid("equipment_id")
      .notNull()
      .references(() => equipment.id, { onDelete: "cascade" }),
  },
  (t) => [unique().on(t.equipmentProfileId, t.equipmentId)]
);

// ── exercises ─────────────────────────────────────────────
export const exercises = pgTable("exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  description: text("description"),
  instructions: text("instructions"),
  isCustom: boolean("is_custom").notNull().default(false),
  createdBy: uuid("created_by").references(() => profiles.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── exercise_equipment ────────────────────────────────────
export const exerciseEquipment = pgTable(
  "exercise_equipment",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    exerciseId: uuid("exercise_id")
      .notNull()
      .references(() => exercises.id, { onDelete: "cascade" }),
    equipmentId: uuid("equipment_id")
      .notNull()
      .references(() => equipment.id, { onDelete: "cascade" }),
  },
  (t) => [unique().on(t.exerciseId, t.equipmentId)]
);

// ── exercise_muscles ──────────────────────────────────────
export const exerciseMuscles = pgTable(
  "exercise_muscles",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    exerciseId: uuid("exercise_id")
      .notNull()
      .references(() => exercises.id, { onDelete: "cascade" }),
    muscleId: uuid("muscle_id")
      .notNull()
      .references(() => muscles.id, { onDelete: "cascade" }),
    role: text("role").notNull(), // 'primary' | 'secondary'
  },
  (t) => [unique().on(t.exerciseId, t.muscleId)]
);

// ── workout_templates ─────────────────────────────────────
export const workoutTemplates = pgTable("workout_templates", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  description: text("description"),
  isShared: boolean("is_shared").notNull().default(false),
  shareToken: uuid("share_token").unique().defaultRandom(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── template_exercises ────────────────────────────────────
export const templateExercises = pgTable("template_exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  templateId: uuid("template_id")
    .notNull()
    .references(() => workoutTemplates.id, { onDelete: "cascade" }),
  exerciseId: uuid("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "cascade" }),
  orderIndex: integer("order_index").notNull(),
  targetSets: integer("target_sets").notNull().default(3),
  targetReps: integer("target_reps").notNull().default(10),
  targetWeight: numeric("target_weight"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── workout_sessions ──────────────────────────────────────
export const workoutSessions = pgTable("workout_sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  templateId: uuid("template_id").references(() => workoutTemplates.id, { onDelete: "set null" }),
  date: date("date").notNull().defaultNow(),
  durationMinutes: integer("duration_minutes"),
  notes: text("notes"),
  completed: boolean("completed").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── session_sets ──────────────────────────────────────────
export const sessionSets = pgTable("session_sets", {
  id: uuid("id").primaryKey().defaultRandom(),
  sessionId: uuid("session_id")
    .notNull()
    .references(() => workoutSessions.id, { onDelete: "cascade" }),
  exerciseId: uuid("exercise_id")
    .notNull()
    .references(() => exercises.id, { onDelete: "cascade" }),
  setNumber: integer("set_number").notNull(),
  weight: numeric("weight").notNull().default("0"),
  reps: integer("reps").notNull().default(0),
  rpe: numeric("rpe"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── saved_ai_suggestions ──────────────────────────────────
export const savedAiSuggestions = pgTable("saved_ai_suggestions", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id").notNull().references(() => profiles.id, { onDelete: "cascade" }),
  exerciseName: text("exercise_name").notNull(),
  exerciseId: uuid("exercise_id").references(() => exercises.id, { onDelete: "set null" }),
  primaryMuscles: text("primary_muscles").array().notNull().default(sql`'{}'`),
  secondaryMuscles: text("secondary_muscles").array().notNull().default(sql`'{}'`),
  suggestedSets: integer("suggested_sets").notNull().default(3),
  suggestedReps: integer("suggested_reps").notNull().default(10),
  description: text("description"),
  instructions: text("instructions"),
  workoutType: text("workout_type").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

// ── Auth.js tables ────────────────────────────────────────
// These are required by the Drizzle adapter for Auth.js.
// They are NEW tables, not migrated from Supabase.

export const users = pgTable("authjs_users", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name"),
  email: text("email").unique(),
  emailVerified: timestamp("email_verified", { withTimezone: true }),
  image: text("image"),
  passwordHash: text("password_hash"),
  profileId: uuid("profile_id").references(() => profiles.id, { onDelete: "cascade" }),
});

export const accounts = pgTable("authjs_accounts", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  type: text("type").notNull(),
  provider: text("provider").notNull(),
  providerAccountId: text("provider_account_id").notNull(),
  refreshToken: text("refresh_token"),
  accessToken: text("access_token"),
  expiresAt: integer("expires_at"),
  tokenType: text("token_type"),
  scope: text("scope"),
  idToken: text("id_token"),
  sessionState: text("session_state"),
});

export const sessions = pgTable("authjs_sessions", {
  id: uuid("id").primaryKey().defaultRandom(),
  sessionToken: text("session_token").notNull().unique(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  expires: timestamp("expires", { withTimezone: true }).notNull(),
});

export const verificationTokens = pgTable("authjs_verification_tokens", {
  identifier: text("identifier").notNull(),
  token: text("token").notNull().unique(),
  expires: timestamp("expires", { withTimezone: true }).notNull(),
});
```

**Step 2: Verify the file compiles**

Run: `npx tsc --noEmit src/lib/db/schema.ts 2>&1 | head -20`
Expected: No errors (or only unrelated errors from other files)

**Step 3: Commit**

```bash
git add src/lib/db/schema.ts
git commit -m "feat: add Drizzle schema for all tables including Auth.js"
```

---

## Task 3: Create Database Connection + Drizzle Config

**Files:**
- Create: `src/lib/db/index.ts`
- Create: `drizzle.config.ts`

**Step 1: Create the database connection**

```typescript
// src/lib/db/index.ts
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import * as schema from "./schema";

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql, { schema });
```

**Step 2: Create the Drizzle config**

```typescript
// drizzle.config.ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/lib/db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

**Step 3: Commit**

```bash
git add src/lib/db/index.ts drizzle.config.ts
git commit -m "feat: add Neon database connection and Drizzle config"
```

---

## Task 4: Set Up Auth.js

**Files:**
- Create: `src/lib/auth.ts`
- Create: `src/app/api/auth/[...nextauth]/route.ts`
- Modify: `src/middleware.ts` (or wherever the root middleware is)

**Step 1: Find and read the current middleware file**

Run: `find src -name "middleware.ts" -not -path "*/supabase/*"` and also check root-level `middleware.ts`.

The current middleware is at the root and imports from `src/lib/supabase/middleware.ts`. Read it first.

**Step 2: Create the Auth.js config**

```typescript
// src/lib/auth.ts
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { DrizzleAdapter } from "@auth/drizzle-adapter";
import { db } from "@/lib/db";
import { users, profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import bcrypt from "bcryptjs";

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: DrizzleAdapter(db, {
    usersTable: users,
    accountsTable: accounts,
    sessionsTable: sessions,
    verificationTokensTable: verificationTokens,
  }),
  session: { strategy: "jwt" },
  pages: {
    signIn: "/login",
  },
  providers: [
    Credentials({
      credentials: {
        email: {},
        password: {},
      },
      async authorize(credentials) {
        const email = credentials.email as string;
        const password = credentials.password as string;

        const [user] = await db
          .select()
          .from(users)
          .where(eq(users.email, email))
          .limit(1);

        if (!user?.passwordHash) return null;

        const valid = await bcrypt.compare(password, user.passwordHash);
        if (!valid) return null;

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          profileId: user.profileId,
        };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.profileId = (user as { profileId?: string }).profileId;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!;
        (session.user as { profileId?: string }).profileId = token.profileId as string;
      }
      return session;
    },
  },
});
```

Note: The `accounts`, `sessions`, `verificationTokens` imports need to be added from schema. Adjust the import line in the actual file:
```typescript
import { users, accounts, sessions, verificationTokens, profiles } from "@/lib/db/schema";
```

**Step 3: Create the Auth.js types augmentation**

```typescript
// src/types/next-auth.d.ts
import { DefaultSession } from "next-auth";

declare module "next-auth" {
  interface Session {
    user: DefaultSession["user"] & {
      profileId: string;
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    profileId?: string;
  }
}
```

**Step 4: Create the API route handler**

```typescript
// src/app/api/auth/[...nextauth]/route.ts
import { handlers } from "@/lib/auth";
export const { GET, POST } = handlers;
```

**Step 5: Create an auth helper for server actions**

This replaces the `createClient() + supabase.auth.getUser()` pattern used in every server action.

```typescript
// src/lib/auth-utils.ts
import { auth } from "@/lib/auth";

/**
 * Get the authenticated user's profile ID, or throw.
 * Replaces: const supabase = await createClient();
 *           const { data: { user } } = await supabase.auth.getUser();
 */
export async function requireAuth(): Promise<{ userId: string; profileId: string }> {
  const session = await auth();
  if (!session?.user?.profileId) {
    throw new Error("Not authenticated");
  }
  return {
    userId: session.user.id,
    profileId: session.user.profileId,
  };
}

/**
 * Get the authenticated user if logged in, or null.
 */
export async function getOptionalAuth(): Promise<{ userId: string; profileId: string } | null> {
  const session = await auth();
  if (!session?.user?.profileId) return null;
  return {
    userId: session.user.id,
    profileId: session.user.profileId,
  };
}
```

**Step 6: Commit**

```bash
git add src/lib/auth.ts src/lib/auth-utils.ts src/types/next-auth.d.ts src/app/api/auth/\[...nextauth\]/route.ts
git commit -m "feat: set up Auth.js v5 with Credentials provider and auth helpers"
```

---

## Task 5: Replace Middleware

**Files:**
- Modify: root `middleware.ts`
- Delete after migration: `src/lib/supabase/middleware.ts`

**Step 1: Read the current root middleware**

Check for `middleware.ts` at the project root. It likely imports `updateSession` from `src/lib/supabase/middleware.ts`.

**Step 2: Replace with Auth.js middleware**

```typescript
// middleware.ts (root)
export { auth as middleware } from "@/lib/auth";

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - api/auth (Auth.js routes)
     * - _next/static, _next/image (Next.js internals)
     * - favicon.ico, public files
     * - login, signup, share (public pages)
     */
    "/((?!api/auth|_next/static|_next/image|favicon\\.ico|login|signup|share|.*\\.svg$).*)",
  ],
};
```

Then update the Auth.js config in `src/lib/auth.ts` to add the `authorized` callback:

```typescript
// Add to the NextAuth callbacks in src/lib/auth.ts:
callbacks: {
  authorized({ auth, request: { nextUrl } }) {
    const isLoggedIn = !!auth?.user;
    const publicPaths = ["/login", "/signup", "/share"];
    const isPublicPath = publicPaths.some((path) =>
      nextUrl.pathname.startsWith(path)
    );

    if (!isLoggedIn && !isPublicPath) {
      return false; // Redirects to signIn page
    }
    return true;
  },
  // ... existing jwt and session callbacks
},
```

**Step 3: Verify middleware compiles**

Run: `npx tsc --noEmit middleware.ts 2>&1 | head -10`

**Step 4: Commit**

```bash
git add middleware.ts src/lib/auth.ts
git commit -m "feat: replace Supabase middleware with Auth.js middleware"
```

---

## Task 6: Migrate Auth Actions

**Files:**
- Rewrite: `src/lib/actions/auth.ts`
- Delete after migration: `src/app/auth/callback/route.ts` (Supabase OAuth callback, no longer needed)

**Step 1: Rewrite auth actions**

```typescript
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

export { signOut };

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
```

**Important:** The login/signup pages currently call `signIn` from auth actions. The new `logIn` function replaces the old `signIn` server action. Update the login page to import `logIn` instead of `signIn`:

**Step 2: Update login page import**

In `src/app/login/page.tsx`, change:
```typescript
import { signIn } from "@/lib/actions/auth";
```
to:
```typescript
import { logIn } from "@/lib/actions/auth";
```
And update `useActionState(signIn, ...)` to `useActionState(logIn, ...)`.

**Step 3: Update signup page**

No changes needed — `signUp` keeps the same name and signature.

**Step 4: Update sidebar signOut**

In `src/components/nav/sidebar.tsx`, change:
```typescript
import { signOut } from "@/lib/actions/auth";
```
This still works since we re-export `signOut` from Auth.js. However, Auth.js `signOut` is not a server action by default — we need a wrapper:

```typescript
// Add to src/lib/actions/auth.ts:
export async function handleSignOut() {
  await signOut({ redirect: false });
  redirect("/login");
}
```

Then update sidebar to import `handleSignOut` instead of `signOut`.

**Step 5: Delete the Supabase OAuth callback**

Delete `src/app/auth/callback/route.ts` — no longer needed.

**Step 6: Commit**

```bash
git add src/lib/actions/auth.ts src/app/login/page.tsx src/components/nav/sidebar.tsx
git rm src/app/auth/callback/route.ts
git commit -m "feat: migrate auth actions to Auth.js"
```

---

## Task 7: Migrate Profile Actions

**Files:**
- Rewrite: `src/lib/actions/profile.ts`

**Step 1: Rewrite profile actions using Drizzle**

```typescript
// src/lib/actions/profile.ts
"use server";

import { db } from "@/lib/db";
import { profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";

export async function getProfile() {
  const { profileId } = await requireAuth();

  const [profile] = await db
    .select()
    .from(profiles)
    .where(eq(profiles.id, profileId))
    .limit(1);

  if (!profile) throw new Error("Profile not found");
  return profile;
}

export async function updateProfile(formData: FormData) {
  const { profileId } = await requireAuth();

  const displayName = formData.get("display_name") as string;
  const preferredUnits = formData.get("preferred_units") as string;
  const overloadSessionsThreshold = Number(formData.get("overload_sessions_threshold"));
  const overloadIncrementLbs = Number(formData.get("overload_increment_lbs"));
  const overloadIncrementKg = Number(formData.get("overload_increment_kg"));

  await db
    .update(profiles)
    .set({
      displayName: displayName || null,
      preferredUnits,
      overloadSessionsThreshold,
      overloadIncrementLbs: String(overloadIncrementLbs),
      overloadIncrementKg: String(overloadIncrementKg),
      updatedAt: new Date(),
    })
    .where(eq(profiles.id, profileId));

  revalidatePath("/profile");
  revalidatePath("/", "layout");
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/profile.ts
git commit -m "feat: migrate profile actions to Drizzle"
```

---

## Task 8: Migrate Equipment Actions

**Files:**
- Rewrite: `src/lib/actions/equipment.ts`

**Step 1: Rewrite equipment actions using Drizzle**

```typescript
// src/lib/actions/equipment.ts
"use server";

import { db } from "@/lib/db";
import { equipment, equipmentProfiles, equipmentProfileItems } from "@/lib/db/schema";
import { eq, and, asc } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { validateCustomEquipmentInput } from "@/lib/validators/equipment";

export { validateCustomEquipmentInput };

export async function getEquipmentList() {
  return db
    .select()
    .from(equipment)
    .orderBy(asc(equipment.category), asc(equipment.name));
}

export async function getEquipmentProfiles() {
  const { profileId } = await requireAuth();

  const profilesData = await db.query.equipmentProfiles.findMany({
    where: eq(equipmentProfiles.userId, profileId),
    with: {
      equipmentProfileItems: {
        with: {
          equipment: true,
        },
      },
    },
    orderBy: (ep, { desc }) => [desc(ep.createdAt)],
  });

  return profilesData;
}

export async function createEquipmentProfile(formData: FormData) {
  const { profileId } = await requireAuth();

  const name = formData.get("name") as string;
  const equipmentIds = formData.getAll("equipment") as string[];

  const [profile] = await db
    .insert(equipmentProfiles)
    .values({ userId: profileId, name, isActive: false })
    .returning();

  if (equipmentIds.length > 0) {
    await db.insert(equipmentProfileItems).values(
      equipmentIds.map((equipmentId) => ({
        equipmentProfileId: profile.id,
        equipmentId,
      }))
    );
  }

  revalidatePath("/equipment");
}

export async function setActiveProfile(profileId: string) {
  await db
    .update(equipmentProfiles)
    .set({ isActive: true })
    .where(eq(equipmentProfiles.id, profileId));

  revalidatePath("/equipment");
}

export async function deleteEquipmentProfile(profileId: string) {
  await db
    .delete(equipmentProfiles)
    .where(eq(equipmentProfiles.id, profileId));

  revalidatePath("/equipment");
}

export async function createCustomEquipment(formData: FormData) {
  const { profileId } = await requireAuth();

  const rawName = formData.get("name");
  const name = typeof rawName === "string" ? rawName.trim() : "";
  const rawCategory = formData.get("category");
  const category = typeof rawCategory === "string" ? rawCategory : "";

  const validation = validateCustomEquipmentInput(name, category);
  if (!validation.valid) throw new Error(validation.error);

  const [data] = await db
    .insert(equipment)
    .values({ name, category, isCustom: true, createdBy: profileId })
    .returning();

  revalidatePath("/equipment");
  return data;
}
```

Note: The `getEquipmentProfiles` function uses Drizzle's relational query API (`db.query`). This requires defining relations in the schema. Add relations to `src/lib/db/schema.ts` (see Step 2 below).

**Step 2: Add Drizzle relations to schema**

Add the following to the bottom of `src/lib/db/schema.ts`:

```typescript
// ── Relations ─────────────────────────────────────────────

export const equipmentProfilesRelations = relations(equipmentProfiles, ({ many }) => ({
  equipmentProfileItems: many(equipmentProfileItems),
}));

export const equipmentProfileItemsRelations = relations(equipmentProfileItems, ({ one }) => ({
  equipmentProfile: one(equipmentProfiles, {
    fields: [equipmentProfileItems.equipmentProfileId],
    references: [equipmentProfiles.id],
  }),
  equipment: one(equipment, {
    fields: [equipmentProfileItems.equipmentId],
    references: [equipment.id],
  }),
}));

export const exercisesRelations = relations(exercises, ({ many }) => ({
  exerciseEquipment: many(exerciseEquipment),
  exerciseMuscles: many(exerciseMuscles),
}));

export const exerciseEquipmentRelations = relations(exerciseEquipment, ({ one }) => ({
  exercise: one(exercises, {
    fields: [exerciseEquipment.exerciseId],
    references: [exercises.id],
  }),
  equipment: one(equipment, {
    fields: [exerciseEquipment.equipmentId],
    references: [equipment.id],
  }),
}));

export const exerciseMusclesRelations = relations(exerciseMuscles, ({ one }) => ({
  exercise: one(exercises, {
    fields: [exerciseMuscles.exerciseId],
    references: [exercises.id],
  }),
  muscle: one(muscles, {
    fields: [exerciseMuscles.muscleId],
    references: [muscles.id],
  }),
}));

export const workoutTemplatesRelations = relations(workoutTemplates, ({ many }) => ({
  templateExercises: many(templateExercises),
}));

export const templateExercisesRelations = relations(templateExercises, ({ one }) => ({
  template: one(workoutTemplates, {
    fields: [templateExercises.templateId],
    references: [workoutTemplates.id],
  }),
  exercise: one(exercises, {
    fields: [templateExercises.exerciseId],
    references: [exercises.id],
  }),
}));

export const workoutSessionsRelations = relations(workoutSessions, ({ one, many }) => ({
  template: one(workoutTemplates, {
    fields: [workoutSessions.templateId],
    references: [workoutTemplates.id],
  }),
  sessionSets: many(sessionSets),
}));

export const sessionSetsRelations = relations(sessionSets, ({ one }) => ({
  session: one(workoutSessions, {
    fields: [sessionSets.sessionId],
    references: [workoutSessions.id],
  }),
  exercise: one(exercises, {
    fields: [sessionSets.exerciseId],
    references: [exercises.id],
  }),
}));

export const savedAiSuggestionsRelations = relations(savedAiSuggestions, ({ one }) => ({
  exercise: one(exercises, {
    fields: [savedAiSuggestions.exerciseId],
    references: [exercises.id],
  }),
}));
```

**Step 3: Commit**

```bash
git add src/lib/db/schema.ts src/lib/actions/equipment.ts
git commit -m "feat: migrate equipment actions to Drizzle and add relations"
```

---

## Task 9: Migrate Exercise Actions

**Files:**
- Rewrite: `src/lib/actions/exercises.ts`

**Step 1: Rewrite exercise actions using Drizzle**

```typescript
// src/lib/actions/exercises.ts
"use server";

import { db } from "@/lib/db";
import {
  exercises,
  exerciseEquipment,
  exerciseMuscles,
  equipmentProfiles,
  equipmentProfileItems,
} from "@/lib/db/schema";
import { eq, ilike, and } from "drizzle-orm";
import { getOptionalAuth } from "@/lib/auth-utils";

export interface ExerciseFilters {
  muscleGroup?: string;
  availableOnly?: boolean;
  search?: string;
}

export async function getExercises(filters: ExerciseFilters = {}) {
  let allExercises = await db.query.exercises.findMany({
    with: {
      exerciseEquipment: {
        with: { equipment: true },
      },
      exerciseMuscles: {
        with: { muscle: true },
      },
    },
    orderBy: (e, { asc }) => [asc(e.name)],
    ...(filters.search
      ? { where: ilike(exercises.name, `%${filters.search}%`) }
      : {}),
  });

  // Filter by muscle group
  if (filters.muscleGroup) {
    allExercises = allExercises.filter((ex) =>
      ex.exerciseMuscles.some(
        (em) => em.muscle?.muscleGroup === filters.muscleGroup && em.role === "primary"
      )
    );
  }

  // Filter by available equipment
  if (filters.availableOnly) {
    const authUser = await getOptionalAuth();
    if (authUser) {
      const activeProfile = await db.query.equipmentProfiles.findFirst({
        where: and(
          eq(equipmentProfiles.userId, authUser.profileId),
          eq(equipmentProfiles.isActive, true)
        ),
      });

      if (activeProfile) {
        const profileItems = await db
          .select({ equipmentId: equipmentProfileItems.equipmentId })
          .from(equipmentProfileItems)
          .where(eq(equipmentProfileItems.equipmentProfileId, activeProfile.id));

        const availableIds = new Set(profileItems.map((i) => i.equipmentId));

        allExercises = allExercises.filter((ex) => {
          const required = ex.exerciseEquipment.map((ee) => ee.equipment?.id);
          return required.every((id) => id && availableIds.has(id));
        });
      }
    }
  }

  return allExercises;
}

export async function getExercise(id: string) {
  const result = await db.query.exercises.findFirst({
    where: eq(exercises.id, id),
    with: {
      exerciseEquipment: {
        with: { equipment: true },
      },
      exerciseMuscles: {
        with: { muscle: true },
      },
    },
  });

  if (!result) throw new Error("Exercise not found");
  return result;
}

export async function getAvailableExercises() {
  return getExercises({ availableOnly: true });
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/exercises.ts
git commit -m "feat: migrate exercise actions to Drizzle"
```

---

## Task 10: Migrate Template Actions

**Files:**
- Rewrite: `src/lib/actions/templates.ts`

**Step 1: Rewrite template actions using Drizzle**

```typescript
// src/lib/actions/templates.ts
"use server";

import { db } from "@/lib/db";
import { workoutTemplates, templateExercises } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function getTemplates() {
  const { profileId } = await requireAuth();

  return db.query.workoutTemplates.findMany({
    where: eq(workoutTemplates.userId, profileId),
    with: {
      templateExercises: {
        with: { exercise: true },
      },
    },
    orderBy: (t, { desc }) => [desc(t.updatedAt)],
  }) ?? [];
}

export async function getTemplate(id: string) {
  const result = await db.query.workoutTemplates.findFirst({
    where: eq(workoutTemplates.id, id),
    with: {
      templateExercises: {
        with: {
          exercise: {
            with: {
              exerciseMuscles: {
                with: { muscle: true },
              },
            },
          },
        },
        orderBy: (te, { asc }) => [asc(te.orderIndex)],
      },
    },
  });

  if (!result) throw new Error("Template not found");
  return result;
}

export async function createTemplate(formData: FormData) {
  const { profileId } = await requireAuth();
  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  const [data] = await db
    .insert(workoutTemplates)
    .values({ name, description, userId: profileId })
    .returning();

  redirect(`/workouts/${data.id}`);
}

export async function updateTemplate(id: string, formData: FormData) {
  const name = formData.get("name") as string;
  const description = (formData.get("description") as string) || null;

  await db
    .update(workoutTemplates)
    .set({ name, description, updatedAt: new Date() })
    .where(eq(workoutTemplates.id, id));

  revalidatePath(`/workouts/${id}`);
  revalidatePath("/workouts");
}

export async function addExerciseToTemplate(
  templateId: string,
  exerciseId: string,
  orderIndex: number
) {
  await db.insert(templateExercises).values({
    templateId,
    exerciseId,
    orderIndex,
  });

  await db
    .update(workoutTemplates)
    .set({ updatedAt: new Date() })
    .where(eq(workoutTemplates.id, templateId));

  revalidatePath(`/workouts/${templateId}`);
}

export async function removeExerciseFromTemplate(
  templateExerciseId: string,
  templateId: string
) {
  await db
    .delete(templateExercises)
    .where(eq(templateExercises.id, templateExerciseId));

  revalidatePath(`/workouts/${templateId}`);
}

export async function reorderTemplateExercises(
  templateId: string,
  exerciseIds: string[]
) {
  await Promise.all(
    exerciseIds.map((id, index) =>
      db
        .update(templateExercises)
        .set({ orderIndex: index })
        .where(eq(templateExercises.id, id))
    )
  );

  revalidatePath(`/workouts/${templateId}`);
}

export async function updateTemplateExercise(
  id: string,
  templateId: string,
  data: { target_sets?: number; target_reps?: number; target_weight?: number | null }
) {
  await db
    .update(templateExercises)
    .set({
      ...(data.target_sets !== undefined && { targetSets: data.target_sets }),
      ...(data.target_reps !== undefined && { targetReps: data.target_reps }),
      ...(data.target_weight !== undefined && { targetWeight: data.target_weight ? String(data.target_weight) : null }),
    })
    .where(eq(templateExercises.id, id));

  revalidatePath(`/workouts/${templateId}`);
}

export async function cloneTemplate(id: string) {
  const { profileId } = await requireAuth();

  const original = await db.query.workoutTemplates.findFirst({
    where: eq(workoutTemplates.id, id),
    with: { templateExercises: true },
  });

  if (!original) throw new Error("Template not found");

  const [newTemplate] = await db
    .insert(workoutTemplates)
    .values({
      name: `${original.name} (Copy)`,
      description: original.description,
      userId: profileId,
    })
    .returning();

  if (original.templateExercises.length > 0) {
    await db.insert(templateExercises).values(
      original.templateExercises.map((te) => ({
        templateId: newTemplate.id,
        exerciseId: te.exerciseId,
        orderIndex: te.orderIndex,
        targetSets: te.targetSets,
        targetReps: te.targetReps,
        targetWeight: te.targetWeight,
      }))
    );
  }

  revalidatePath("/workouts");
  redirect(`/workouts/${newTemplate.id}`);
}

export async function deleteTemplate(id: string) {
  await db.delete(workoutTemplates).where(eq(workoutTemplates.id, id));

  revalidatePath("/workouts");
  redirect("/workouts");
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/templates.ts
git commit -m "feat: migrate template actions to Drizzle"
```

---

## Task 11: Migrate Session Actions

**Files:**
- Rewrite: `src/lib/actions/sessions.ts`

**Step 1: Rewrite session actions using Drizzle**

```typescript
// src/lib/actions/sessions.ts
"use server";

import { db } from "@/lib/db";
import { workoutSessions, sessionSets, workoutTemplates, exercises } from "@/lib/db/schema";
import { eq, and } from "drizzle-orm";
import { requireAuth, getOptionalAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";

export async function startSession(templateId?: string) {
  const { profileId } = await requireAuth();

  const [data] = await db
    .insert(workoutSessions)
    .values({
      userId: profileId,
      templateId: templateId ?? null,
      date: new Date().toISOString().split("T")[0],
    })
    .returning();

  return data;
}

export async function logSet(
  sessionId: string,
  exerciseId: string,
  setNumber: number,
  weight: number,
  reps: number,
  rpe?: number | null
) {
  // Check if set already exists
  const [existing] = await db
    .select({ id: sessionSets.id })
    .from(sessionSets)
    .where(
      and(
        eq(sessionSets.sessionId, sessionId),
        eq(sessionSets.exerciseId, exerciseId),
        eq(sessionSets.setNumber, setNumber)
      )
    )
    .limit(1);

  if (existing) {
    await db
      .update(sessionSets)
      .set({ weight: String(weight), reps, rpe: rpe != null ? String(rpe) : null })
      .where(eq(sessionSets.id, existing.id));
  } else {
    await db.insert(sessionSets).values({
      sessionId,
      exerciseId,
      setNumber,
      weight: String(weight),
      reps,
      rpe: rpe != null ? String(rpe) : null,
    });
  }
}

export async function deleteSet(setId: string) {
  await db.delete(sessionSets).where(eq(sessionSets.id, setId));
}

export async function finishSession(
  sessionId: string,
  durationMinutes: number,
  notes?: string
) {
  await db
    .update(workoutSessions)
    .set({
      completed: true,
      durationMinutes,
      notes: notes || null,
      updatedAt: new Date(),
    })
    .where(eq(workoutSessions.id, sessionId));

  revalidatePath("/history");
  revalidatePath("/workouts");
}

export async function getLastSessionForExercise(exerciseId: string) {
  const authUser = await getOptionalAuth();
  if (!authUser) return null;

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: {
      session: true,
    },
    orderBy: (s, { desc }) => [desc(s.createdAt)],
    limit: 20,
  });

  const completedSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (completedSets.length === 0) return null;

  const sessionId = completedSets[0].session.id;
  const lastSets = completedSets
    .filter((s) => s.session.id === sessionId)
    .sort((a, b) => a.setNumber - b.setNumber);

  return lastSets.map((s) => ({
    set_number: s.setNumber,
    weight: Number(s.weight),
    reps: s.reps,
    rpe: s.rpe ? Number(s.rpe) : null,
  }));
}

export async function getSession(id: string) {
  const result = await db.query.workoutSessions.findFirst({
    where: eq(workoutSessions.id, id),
    with: {
      template: true,
      sessionSets: {
        with: { exercise: true },
      },
    },
  });

  if (!result) throw new Error("Session not found");
  return result;
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/sessions.ts
git commit -m "feat: migrate session actions to Drizzle"
```

---

## Task 12: Migrate History Actions

**Files:**
- Rewrite: `src/lib/actions/history.ts`

**Step 1: Rewrite history actions using Drizzle**

```typescript
// src/lib/actions/history.ts
"use server";

import { db } from "@/lib/db";
import { workoutSessions, sessionSets, exercises, exerciseMuscles, muscles } from "@/lib/db/schema";
import { eq, and, gte, lte, desc, asc } from "drizzle-orm";
import { requireAuth, getOptionalAuth } from "@/lib/auth-utils";

export async function getSessionsByMonth(year: number, month: number) {
  const { profileId } = await requireAuth();

  const startDate = new Date(year, month, 1).toISOString().split("T")[0];
  const endDate = new Date(year, month + 1, 0).toISOString().split("T")[0];

  return db.query.workoutSessions.findMany({
    where: and(
      eq(workoutSessions.userId, profileId),
      eq(workoutSessions.completed, true),
      gte(workoutSessions.date, startDate),
      lte(workoutSessions.date, endDate)
    ),
    with: {
      template: true,
      sessionSets: {
        with: { exercise: true },
      },
    },
    orderBy: [desc(workoutSessions.date)],
  }) ?? [];
}

export async function getHistorySession(id: string) {
  const result = await db.query.workoutSessions.findFirst({
    where: eq(workoutSessions.id, id),
    with: {
      template: true,
      sessionSets: {
        with: { exercise: true },
      },
    },
  });

  if (!result) throw new Error("Session not found");
  return result;
}

export async function getExerciseHistory(exerciseId: string, limit = 20) {
  const authUser = await getOptionalAuth();
  if (!authUser) return [];

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: { session: true },
    orderBy: (s, { desc }) => [desc(s.createdAt)],
    limit: limit * 10,
  });

  const userSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (userSets.length === 0) return [];

  const sessionMap = new Map<
    string,
    { date: string; maxWeight: number; totalVolume: number }
  >();

  for (const set of userSets) {
    const date = set.session.date;
    const weight = Number(set.weight);
    const volume = weight * set.reps;
    const existing = sessionMap.get(date);

    if (existing) {
      existing.maxWeight = Math.max(existing.maxWeight, weight);
      existing.totalVolume += volume;
    } else {
      sessionMap.set(date, { date, maxWeight: weight, totalVolume: volume });
    }
  }

  return Array.from(sessionMap.values())
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(-limit);
}

export async function getPersonalBests(exerciseId: string) {
  const authUser = await getOptionalAuth();
  if (!authUser) return null;

  const sets = await db.query.sessionSets.findMany({
    where: eq(sessionSets.exerciseId, exerciseId),
    with: { session: true },
  });

  const userSets = sets.filter(
    (s) => s.session.userId === authUser.profileId && s.session.completed
  );

  if (userSets.length === 0) return null;

  let maxWeight = 0;
  let maxReps = 0;
  let maxVolume = 0;

  for (const set of userSets) {
    const weight = Number(set.weight);
    maxWeight = Math.max(maxWeight, weight);
    maxReps = Math.max(maxReps, set.reps);
    maxVolume = Math.max(maxVolume, weight * set.reps);
  }

  return { maxWeight, maxReps, maxVolume };
}

export async function getTrainingStreak() {
  const authUser = await getOptionalAuth();
  if (!authUser) return 0;

  const startDate = new Date();
  startDate.setDate(startDate.getDate() - 365);

  const sessionsData = await db
    .select({ date: workoutSessions.date })
    .from(workoutSessions)
    .where(
      and(
        eq(workoutSessions.userId, authUser.profileId),
        eq(workoutSessions.completed, true),
        gte(workoutSessions.date, startDate.toISOString().split("T")[0])
      )
    )
    .orderBy(desc(workoutSessions.date));

  if (sessionsData.length === 0) return 0;

  const weeks = new Set<string>();
  for (const session of sessionsData) {
    const d = new Date(session.date);
    const weekStart = new Date(d);
    weekStart.setDate(d.getDate() - d.getDay());
    weeks.add(weekStart.toISOString().split("T")[0]);
  }

  const sortedWeeks = Array.from(weeks).sort().reverse();
  let streak = 0;

  const now = new Date();
  const currentWeekStart = new Date(now);
  currentWeekStart.setDate(now.getDate() - now.getDay());
  const currentWeekKey = currentWeekStart.toISOString().split("T")[0];

  const lastWeekStart = new Date(currentWeekStart);
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);
  const lastWeekKey = lastWeekStart.toISOString().split("T")[0];

  if (!weeks.has(currentWeekKey) && !weeks.has(lastWeekKey)) return 0;

  const startIdx = weeks.has(currentWeekKey)
    ? sortedWeeks.indexOf(currentWeekKey)
    : sortedWeeks.indexOf(lastWeekKey);

  for (let i = startIdx; i < sortedWeeks.length; i++) {
    const expectedWeek = new Date(sortedWeeks[startIdx]);
    expectedWeek.setDate(expectedWeek.getDate() - (i - startIdx) * 7);
    const expectedKey = expectedWeek.toISOString().split("T")[0];

    if (sortedWeeks[i] === expectedKey) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

export async function getWeeklyMuscleCoverage() {
  const authUser = await getOptionalAuth();
  if (!authUser) return [];

  const now = new Date();
  const weekStart = new Date(now);
  weekStart.setDate(now.getDate() - now.getDay());
  weekStart.setHours(0, 0, 0, 0);

  const sets = await db.query.sessionSets.findMany({
    with: {
      exercise: {
        with: {
          exerciseMuscles: {
            with: { muscle: true },
          },
        },
      },
      session: true,
    },
  });

  const userSets = sets.filter(
    (s) =>
      s.session.userId === authUser.profileId &&
      s.session.completed &&
      new Date(s.session.date) >= weekStart
  );

  if (userSets.length === 0) return [];

  const coverage = new Map<string, number>();

  for (const set of userSets) {
    for (const em of set.exercise.exerciseMuscles) {
      if (em.role === "primary" && em.muscle) {
        const group = em.muscle.muscleGroup;
        coverage.set(group, (coverage.get(group) ?? 0) + 1);
      }
    }
  }

  return Array.from(coverage.entries())
    .map(([group, sets]) => ({ group, sets }))
    .sort((a, b) => b.sets - a.sets);
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/history.ts
git commit -m "feat: migrate history actions to Drizzle"
```

---

## Task 13: Migrate Sharing Actions

**Files:**
- Rewrite: `src/lib/actions/sharing.ts`

**Step 1: Rewrite sharing actions using Drizzle**

```typescript
// src/lib/actions/sharing.ts
"use server";

import { db } from "@/lib/db";
import { workoutTemplates, templateExercises } from "@/lib/db/schema";
import { eq, and } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function toggleShareTemplate(templateId: string) {
  const [template] = await db
    .select({ isShared: workoutTemplates.isShared, shareToken: workoutTemplates.shareToken })
    .from(workoutTemplates)
    .where(eq(workoutTemplates.id, templateId))
    .limit(1);

  if (!template) throw new Error("Template not found");

  if (template.isShared) {
    await db
      .update(workoutTemplates)
      .set({ isShared: false })
      .where(eq(workoutTemplates.id, templateId));

    revalidatePath(`/workouts/${templateId}`);
    return { shared: false, shareUrl: null };
  } else {
    const shareToken =
      template.shareToken ?? crypto.randomUUID().replace(/-/g, "").slice(0, 16);

    await db
      .update(workoutTemplates)
      .set({ isShared: true, shareToken })
      .where(eq(workoutTemplates.id, templateId));

    revalidatePath(`/workouts/${templateId}`);
    return { shared: true, shareToken };
  }
}

export async function getSharedTemplate(shareToken: string) {
  const result = await db.query.workoutTemplates.findFirst({
    where: and(
      eq(workoutTemplates.shareToken, shareToken),
      eq(workoutTemplates.isShared, true)
    ),
    with: {
      templateExercises: {
        with: {
          exercise: {
            with: {
              exerciseMuscles: {
                with: { muscle: true },
              },
            },
          },
        },
        orderBy: (te, { asc }) => [asc(te.orderIndex)],
      },
    },
  });

  if (!result) throw new Error("Shared template not found");
  return result;
}

export async function importSharedTemplate(shareToken: string) {
  const { profileId } = await requireAuth();
  const shared = await getSharedTemplate(shareToken);

  const [newTemplate] = await db
    .insert(workoutTemplates)
    .values({
      name: shared.name,
      description: shared.description,
      userId: profileId,
    })
    .returning();

  if (shared.templateExercises.length > 0) {
    const exercisesToInsert = shared.templateExercises
      .filter((te) => te.exercise)
      .map((te) => ({
        templateId: newTemplate.id,
        exerciseId: te.exerciseId,
        orderIndex: te.orderIndex,
        targetSets: te.targetSets,
        targetReps: te.targetReps,
        targetWeight: te.targetWeight,
      }));

    if (exercisesToInsert.length > 0) {
      await db.insert(templateExercises).values(exercisesToInsert);
    }
  }

  redirect(`/workouts/${newTemplate.id}`);
}
```

**Step 2: Commit**

```bash
git add src/lib/actions/sharing.ts
git commit -m "feat: migrate sharing actions to Drizzle"
```

---

## Task 14: Migrate AI Actions

**Files:**
- Rewrite: `src/lib/actions/ai.ts`
- Rewrite: `src/app/api/ai/recommend-exercises/route.ts`

**Step 1: Rewrite AI server actions**

```typescript
// src/lib/actions/ai.ts
"use server";

import { db } from "@/lib/db";
import {
  exercises,
  muscles,
  exerciseMuscles,
  equipment,
  exerciseEquipment,
  savedAiSuggestions,
} from "@/lib/db/schema";
import { eq, or } from "drizzle-orm";
import { requireAuth } from "@/lib/auth-utils";
import { revalidatePath } from "next/cache";
import type { GeminiExerciseSuggestion } from "@/lib/ai/types";
import { normalizeMuscleNames } from "@/lib/validators/muscles";

export async function createExerciseFromSuggestion(
  suggestion: GeminiExerciseSuggestion,
  equipmentNames: string[]
) {
  const { profileId } = await requireAuth();

  const [exercise] = await db
    .insert(exercises)
    .values({
      name: suggestion.name,
      description: suggestion.description,
      instructions: suggestion.instructions,
      isCustom: true,
      createdBy: profileId,
    })
    .returning();

  // Get muscle IDs
  const allMuscles = await db.select().from(muscles);
  if (allMuscles.length > 0) {
    const dbMuscleNames = allMuscles.map((m) => m.name);
    const primaryMatched = normalizeMuscleNames(suggestion.primaryMuscles, dbMuscleNames);
    const secondaryMatched = normalizeMuscleNames(suggestion.secondaryMuscles, dbMuscleNames);

    const muscleRows = [
      ...primaryMatched.map((name) => ({
        exerciseId: exercise.id,
        muscleId: allMuscles.find((m) => m.name === name)!.id,
        role: "primary" as const,
      })),
      ...secondaryMatched.map((name) => ({
        exerciseId: exercise.id,
        muscleId: allMuscles.find((m) => m.name === name)!.id,
        role: "secondary" as const,
      })),
    ];

    if (muscleRows.length > 0) {
      await db.insert(exerciseMuscles).values(muscleRows);
    }
  }

  // Link to equipment
  const allEquipment = await db
    .select()
    .from(equipment)
    .where(or(eq(equipment.isCustom, false), eq(equipment.createdBy, profileId)));

  if (allEquipment.length > 0) {
    const equipmentRows = equipmentNames
      .map((name) =>
        allEquipment.find((e) => e.name.toLowerCase() === name.toLowerCase())
      )
      .filter((e): e is NonNullable<typeof e> => e !== undefined)
      .map((e) => ({ exerciseId: exercise.id, equipmentId: e.id }));

    if (equipmentRows.length > 0) {
      await db.insert(exerciseEquipment).values(equipmentRows);
    }
  }

  revalidatePath("/exercises");
  return exercise;
}

export async function saveSuggestion(
  suggestion: GeminiExerciseSuggestion & {
    existingExerciseId?: string;
    workoutType: string;
  }
) {
  const { profileId } = await requireAuth();

  await db.insert(savedAiSuggestions).values({
    userId: profileId,
    exerciseName: suggestion.name,
    exerciseId: suggestion.existingExerciseId ?? null,
    primaryMuscles: suggestion.primaryMuscles,
    secondaryMuscles: suggestion.secondaryMuscles,
    suggestedSets: suggestion.suggestedSets,
    suggestedReps: suggestion.suggestedReps,
    description: suggestion.description,
    instructions: suggestion.instructions,
    workoutType: suggestion.workoutType,
  });
}

export async function getSavedSuggestions() {
  const { profileId } = await requireAuth();

  return db
    .select()
    .from(savedAiSuggestions)
    .where(eq(savedAiSuggestions.userId, profileId))
    .orderBy(savedAiSuggestions.createdAt);
}

export async function deleteSavedSuggestion(id: string) {
  await db.delete(savedAiSuggestions).where(eq(savedAiSuggestions.id, id));
}
```

**Step 2: Rewrite AI API route**

```typescript
// src/app/api/ai/recommend-exercises/route.ts
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { exercises, equipment } from "@/lib/db/schema";
import { or, eq } from "drizzle-orm";
import { generateExerciseRecommendations } from "@/lib/ai/gemini";
import { buildSystemPrompt, buildUserPrompt } from "@/lib/ai/prompts";
import type { ExerciseRecommendation, RecommendRequest } from "@/lib/ai/types";

// Simple in-memory rate limiter
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(userId: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(userId);

  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(userId, { count: 1, resetAt: now + 60_000 });
    return true;
  }

  if (entry.count >= 10) return false;
  entry.count++;
  return true;
}

export async function POST(request: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const userId = session.user.id;
    const profileId = (session.user as { profileId?: string }).profileId;

    if (!checkRateLimit(userId)) {
      return NextResponse.json(
        { error: "Too many requests. Please wait a minute." },
        { status: 429 }
      );
    }

    const body = (await request.json()) as RecommendRequest;

    if (!body.workoutType || !Array.isArray(body.equipment)) {
      return NextResponse.json(
        { error: "workoutType and equipment are required" },
        { status: 400 }
      );
    }

    const systemPrompt = buildSystemPrompt();
    const userPrompt = buildUserPrompt(
      body.workoutType,
      body.equipment,
      body.existingExercises ?? []
    );

    const suggestions = await generateExerciseRecommendations(systemPrompt, userPrompt);

    // Fuzzy match against existing exercises in DB
    const dbExercises = await db
      .select({ id: exercises.id, name: exercises.name })
      .from(exercises)
      .where(
        profileId
          ? or(eq(exercises.isCustom, false), eq(exercises.createdBy, profileId))
          : eq(exercises.isCustom, false)
      );

    const recommendations: ExerciseRecommendation[] = suggestions.map((s) => {
      const match = dbExercises.find(
        (e) => e.name.toLowerCase() === s.name.toLowerCase()
      );
      return {
        ...s,
        existsInDb: !!match,
        existingExerciseId: match?.id,
      };
    });

    return NextResponse.json({ recommendations });
  } catch (error) {
    console.error("AI recommendation error:", error);
    return NextResponse.json(
      { error: "Failed to generate recommendations. Please try again." },
      { status: 500 }
    );
  }
}
```

**Step 3: Commit**

```bash
git add src/lib/actions/ai.ts src/app/api/ai/recommend-exercises/route.ts
git commit -m "feat: migrate AI actions and API route to Drizzle"
```

---

## Task 15: Migrate Pages and Layouts

**Files:**
- Modify: `src/app/(app)/layout.tsx`
- Modify: `src/app/(app)/page.tsx`
- Modify: `src/app/(app)/profile/page.tsx`
- Modify: `src/app/share/[token]/page.tsx`
- Modify: `src/components/nav/sidebar.tsx`

**Step 1: Rewrite app layout**

```typescript
// src/app/(app)/layout.tsx
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { profiles } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { Sidebar } from "@/components/nav/sidebar";
import { MobileNav } from "@/components/nav/mobile-nav";

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth();
  if (!session?.user) redirect("/login");

  const profileId = (session.user as { profileId?: string }).profileId;

  const [profile] = profileId
    ? await db.select().from(profiles).where(eq(profiles.id, profileId)).limit(1)
    : [null];

  return (
    <div className="flex min-h-screen bg-mesh">
      <Sidebar user={session.user} profile={profile} />
      <main className="flex-1 pb-20 md:pb-0">
        <div className="container mx-auto max-w-4xl p-4 md:p-8">
          {children}
        </div>
      </main>
      <MobileNav />
    </div>
  );
}
```

**Step 2: Update sidebar to accept Auth.js user type**

In `src/components/nav/sidebar.tsx`, change:
```typescript
import type { User as SupabaseUser } from "@supabase/supabase-js";
```
to:
```typescript
import type { User } from "next-auth";
```

And update the interface:
```typescript
interface SidebarProps {
  user: User;
  profile: typeof import("@/lib/db/schema").profiles.$inferSelect | null;
}
```

Update references from `user.user_metadata?.display_name` to `user.name` (Auth.js stores name at top level).

**Step 3: Rewrite dashboard page**

```typescript
// src/app/(app)/page.tsx
import { getWeeklyMuscleCoverage } from "@/lib/actions/history";
import { getTemplates } from "@/lib/actions/templates";
import { auth } from "@/lib/auth";
import { db } from "@/lib/db";
import { workoutSessions, workoutTemplates, sessionSets } from "@/lib/db/schema";
import { eq, and, desc } from "drizzle-orm";
import { MuscleCoverage } from "@/components/dashboard/muscle-coverage";
import { TodaysWorkout } from "@/components/dashboard/todays-workout";
import { RecentSessions } from "@/components/dashboard/recent-sessions";
import { QuickActions } from "@/components/dashboard/quick-actions";
import { Flame } from "lucide-react";

export default async function DashboardPage() {
  const session = await auth();
  const profileId = (session?.user as { profileId?: string })?.profileId;

  const [coverage, templates, recentSessionsData] = await Promise.all([
    getWeeklyMuscleCoverage(),
    getTemplates(),
    db.query.workoutSessions.findMany({
      where: and(
        eq(workoutSessions.userId, profileId!),
        eq(workoutSessions.completed, true)
      ),
      with: {
        template: true,
        sessionSets: true,
      },
      orderBy: [desc(workoutSessions.date)],
      limit: 5,
    }),
  ]);

  const todaysTemplate = templates.length > 0 ? templates[0] : null;

  const recentSessions = recentSessionsData.map((s) => ({
    id: s.id,
    date: s.date,
    duration_minutes: s.durationMinutes,
    template: s.template ? { name: s.template.name } : null,
    totalSets: s.sessionSets.length,
  }));

  const firstName = session?.user?.name?.split(" ")[0] ?? "there";

  return (
    <div className="stagger-children space-y-8">
      <div className="relative">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-energy shadow-lg">
            <Flame className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="font-display text-3xl font-extrabold tracking-tight">
              Hey, <span className="gradient-text">{firstName}</span>
            </h1>
            <p className="text-sm text-muted-foreground">
              Let&apos;s crush it today
            </p>
          </div>
        </div>
      </div>

      <TodaysWorkout template={todaysTemplate} />

      <div className="grid gap-6 md:grid-cols-2">
        <MuscleCoverage coverage={coverage} />
        <QuickActions />
      </div>

      <RecentSessions sessions={recentSessions} />
    </div>
  );
}
```

**Step 4: Rewrite profile page**

```typescript
// src/app/(app)/profile/page.tsx
import { getProfile } from "@/lib/actions/profile";
import { auth } from "@/lib/auth";
import { ProfileForm } from "./client";

export default async function ProfilePage() {
  const session = await auth();
  const profile = await getProfile();

  return <ProfileForm profile={profile} email={session?.user?.email ?? ""} />;
}
```

**Step 5: Rewrite share page**

```typescript
// src/app/share/[token]/page.tsx
import { getSharedTemplate, importSharedTemplate } from "@/lib/actions/sharing";
import { auth } from "@/lib/auth";
// ... rest of imports stay the same

export default async function SharePage({ params }: SharePageProps) {
  const { token } = await params;
  // ... template fetch stays the same

  const session = await auth();
  const user = session?.user;

  // ... rest of JSX stays the same, replace `user` references
}
```

**Step 6: Commit**

```bash
git add src/app/(app)/layout.tsx src/app/(app)/page.tsx src/app/(app)/profile/page.tsx src/app/share/[token]/page.tsx src/components/nav/sidebar.tsx
git commit -m "feat: migrate pages and layouts from Supabase to Auth.js + Drizzle"
```

---

## Task 16: Update Component Type References

**Files:**
- Modify: any components that import `Database` type from `src/lib/database.types.ts`
- Modify: `src/components/nav/sidebar.tsx` (if not already done)

**Step 1: Search for remaining Supabase type imports**

Run: `grep -r "database.types" src/ --include="*.ts" --include="*.tsx" -l`
Run: `grep -r "@supabase" src/ --include="*.ts" --include="*.tsx" -l`

**Step 2: Replace each import with Drizzle schema inference**

For any component that uses `Database["public"]["Tables"]["tablename"]["Row"]`, replace with:
```typescript
import { type InferSelectModel } from "drizzle-orm";
import { profiles } from "@/lib/db/schema";
type Profile = InferSelectModel<typeof profiles>;
```

Or use Drizzle's `$inferSelect`:
```typescript
import { profiles } from "@/lib/db/schema";
type Profile = typeof profiles.$inferSelect;
```

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor: replace Supabase types with Drizzle schema types"
```

---

## Task 17: Clean Up Supabase Dependencies

**Files:**
- Delete: `src/lib/supabase/` (entire directory)
- Delete: `src/lib/database.types.ts`
- Delete: `src/lib/supabase/typed-client.ts`
- Modify: `package.json`

**Step 1: Verify no remaining Supabase imports**

Run: `grep -r "@supabase" src/ --include="*.ts" --include="*.tsx" -l`
Run: `grep -r "supabase" src/ --include="*.ts" --include="*.tsx" -l`

Expected: No results (or only comments/docs)

**Step 2: Remove Supabase files**

```bash
rm -rf src/lib/supabase/
rm src/lib/database.types.ts
```

**Step 3: Uninstall Supabase packages**

Run: `npm uninstall @supabase/ssr @supabase/supabase-js`

**Step 4: Verify the build compiles**

Run: `npm run build`

Expected: Build succeeds with no errors

**Step 5: Run existing tests**

Run: `npm test`

Expected: Tests pass (some may need updating if they mock Supabase)

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: remove Supabase dependencies and client files"
```

---

## Task 18: Update Environment Variables

**Files:**
- Modify: `.env.local` (or `.env`)
- Modify: Vercel project settings (manual step)

**Step 1: Update local env file**

Remove:
```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
```

Add:
```
DATABASE_URL=postgresql://...@...neon.tech/gearfit?sslmode=require
AUTH_SECRET=<generate with: npx auth secret>
AUTH_URL=http://localhost:3000
```

**Step 2: Generate AUTH_SECRET**

Run: `npx auth secret`
Copy the output and set it in `.env.local`.

**Step 3: Document Vercel env var changes**

The following must be set in Vercel dashboard before deploying:
- `DATABASE_URL` (Neon connection string)
- `AUTH_SECRET` (same value generated above)
- `AUTH_URL` (production URL, e.g., `https://gearfit.vercel.app`)

Remove the old Supabase variables from Vercel.

**Step 4: Commit (do NOT commit .env.local)**

```bash
git add -A
git commit -m "docs: update environment variable requirements"
```

---

## Task 19: Database Migration (Neon Setup)

This is a manual step performed outside of code.

**Step 1: Create Neon project**

Go to https://neon.tech, create a new project. Create a database called `gearfit`.

**Step 2: Export data from Supabase**

```bash
pg_dump --no-owner --no-acl -h db.<supabase-project-ref>.supabase.co -U postgres -d postgres > supabase_dump.sql
```

**Step 3: Clean the dump**

Remove from the dump:
- All RLS policy statements (`CREATE POLICY`, `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)
- Supabase-specific extensions (`supabase_functions`, `pgbouncer`, etc.)
- The `auth` schema tables (these are Supabase-specific, replaced by Auth.js tables)
- The `handle_new_user()` trigger (replaced by signup logic in auth actions)
- The `ensure_single_active_profile()` trigger (keep this one, it's useful)

**Step 4: Import into Neon**

```bash
psql $DATABASE_URL < supabase_dump_cleaned.sql
```

**Step 5: Create Auth.js tables**

Run: `npx drizzle-kit push`

This will create the `authjs_users`, `authjs_accounts`, `authjs_sessions`, and `authjs_verification_tokens` tables.

**Step 6: Migrate existing users**

Write a one-time script to:
1. Export users from Supabase Auth API
2. For each user, insert into `authjs_users` with their existing bcrypt password hash
3. Link to their existing `profiles` row via `profile_id`

```typescript
// scripts/migrate-users.ts (one-time script)
// Run with: npx tsx scripts/migrate-users.ts
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import { users, profiles } from "../src/lib/db/schema";
import { eq } from "drizzle-orm";

const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql);

// Supabase exports users as JSON via their management API
// Get this from: supabase auth admin listUsers() or dashboard export
const supabaseUsers = [
  // Paste exported users here, format:
  // { id: "uuid", email: "...", encrypted_password: "$2a$...", raw_user_meta_data: { display_name: "..." } }
];

async function migrate() {
  for (const su of supabaseUsers) {
    // The profile already exists (migrated via pg_dump)
    // Just create the Auth.js user linked to it
    await db.insert(users).values({
      email: su.email,
      name: su.raw_user_meta_data?.display_name ?? null,
      passwordHash: su.encrypted_password,
      profileId: su.id, // Supabase user ID = profile ID (profiles.id references auth.users.id)
    });

    console.log(`Migrated: ${su.email}`);
  }
}

migrate().catch(console.error);
```

**Step 7: Verify locally**

Run: `npm run dev`
Test: Login with an existing user, navigate through the app.

**Step 8: Commit the migration script**

```bash
git add scripts/migrate-users.ts
git commit -m "chore: add one-time user migration script for Supabase to Auth.js"
```

---

## Task 20: Final Verification and Deploy

**Step 1: Run full build**

Run: `npm run build`
Expected: Clean build, no errors

**Step 2: Run tests**

Run: `npm test`
Expected: All tests pass

**Step 3: Test locally end-to-end**

Manually verify:
- [ ] Sign up works
- [ ] Login works
- [ ] Dashboard loads with data
- [ ] Exercise list loads and filters work
- [ ] Create/edit/delete workout templates
- [ ] Start workout session, log sets
- [ ] History calendar shows sessions
- [ ] Equipment profiles CRUD
- [ ] AI recommendations work
- [ ] Share template and import it
- [ ] Profile settings save correctly

**Step 4: Deploy to Vercel**

Set environment variables in Vercel dashboard, then deploy.

**Step 5: Final commit**

```bash
git add -A
git commit -m "feat: complete Supabase to Neon + Auth.js migration"
```
