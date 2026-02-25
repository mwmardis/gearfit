# GearFit Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a workout tracking web app that filters exercises by available equipment, supports custom splits, tracks progress, and enables workout sharing between friends.

**Architecture:** Monolithic Next.js App Router application with Supabase for Postgres database, auth, and Row Level Security. Server Actions handle all mutations. Mobile-first UI with Tailwind CSS and shadcn/ui.

**Tech Stack:** Next.js 15 (App Router), TypeScript, Supabase (Postgres + Auth), Tailwind CSS, shadcn/ui, Vitest (unit tests), Playwright (E2E tests)

**Design doc:** `docs/plans/2026-02-25-gearfit-design.md`

---

## Phase 1: Project Scaffolding

### Task 1: Initialize Next.js Project

**Files:**
- Create: `gearfit/` (project root, already exists as git repo)

**Step 1: Scaffold Next.js with TypeScript and Tailwind**

Run from `C:/Users/mwmar/public repos/gearfit`:
```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm
```

When prompted about overwriting files, accept. Choose defaults for all prompts.

**Step 2: Verify the app runs**

```bash
npm run dev
```
Expected: App starts on http://localhost:3000, shows Next.js default page.
Kill the dev server after verifying.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: scaffold Next.js project with TypeScript and Tailwind"
```

---

### Task 2: Install Core Dependencies

**Files:**
- Modify: `package.json`

**Step 1: Install Supabase client libraries**

```bash
npm install @supabase/supabase-js @supabase/ssr
```

**Step 2: Install shadcn/ui**

```bash
npx shadcn@latest init
```

When prompted:
- Style: Default
- Base color: Neutral
- CSS variables: Yes

**Step 3: Install test dependencies**

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @vitejs/plugin-react jsdom @playwright/test
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: install Supabase, shadcn/ui, and test dependencies"
```

---

### Task 3: Configure Vitest

**Files:**
- Create: `vitest.config.ts`
- Create: `src/test/setup.ts`
- Modify: `package.json` (add test scripts)
- Modify: `tsconfig.json` (add vitest types)

**Step 1: Create vitest config**

Create `vitest.config.ts`:
```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    globals: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

**Step 2: Create test setup file**

Create `src/test/setup.ts`:
```typescript
import "@testing-library/jest-dom/vitest";
```

**Step 3: Add test scripts to package.json**

Add to `"scripts"`:
```json
"test": "vitest run",
"test:watch": "vitest",
"test:e2e": "playwright test"
```

**Step 4: Write a smoke test to verify setup**

Create `src/test/smoke.test.ts`:
```typescript
import { describe, it, expect } from "vitest";

describe("test setup", () => {
  it("works", () => {
    expect(1 + 1).toBe(2);
  });
});
```

**Step 5: Run test to verify it passes**

```bash
npm test
```
Expected: 1 test passes.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: configure Vitest with React Testing Library"
```

---

### Task 4: Configure Supabase Client

**Files:**
- Create: `src/lib/supabase/client.ts`
- Create: `src/lib/supabase/server.ts`
- Create: `src/lib/supabase/middleware.ts`
- Create: `.env.local.example`
- Modify: `.gitignore` (ensure .env.local is ignored)

**Step 1: Create browser Supabase client**

Create `src/lib/supabase/client.ts`:
```typescript
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**Step 2: Create server Supabase client**

Create `src/lib/supabase/server.ts`:
```typescript
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing sessions.
          }
        },
      },
    }
  );
}
```

**Step 3: Create middleware helper**

Create `src/lib/supabase/middleware.ts`:
```typescript
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const publicPaths = ["/login", "/signup", "/share"];
  const isPublicPath = publicPaths.some((path) =>
    request.nextUrl.pathname.startsWith(path)
  );

  if (!user && !isPublicPath) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}
```

**Step 4: Create Next.js middleware**

Create `src/middleware.ts`:
```typescript
import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
```

**Step 5: Create env example file**

Create `.env.local.example`:
```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

**Step 6: Verify .gitignore includes .env.local**

Check `.gitignore` includes `.env.local`. Next.js scaffolding should have added it, but verify.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: configure Supabase client, server, and middleware"
```

---

## Phase 2: Database Schema

### Task 5: Create Supabase Project and Connect

**Step 1: Create Supabase project**

Use the Supabase MCP tools:
- List organizations to find the right one
- Get cost estimate
- Create project named "gearfit" in preferred region

**Step 2: Get project credentials**

- Get the project URL and anon key
- Create `.env.local` with the real values:
```
NEXT_PUBLIC_SUPABASE_URL=<actual-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<actual-anon-key>
```

**Step 3: Verify connection works**

```bash
npm run dev
```
App should start without errors. No database tables yet, but the Supabase client should initialize.

**Step 4: Commit (only .env.local.example, NOT .env.local)**

```bash
git add .env.local.example
git commit -m "docs: add env example with Supabase credentials placeholder"
```

---

### Task 6: Create Core Schema — Equipment & Muscles

**Files:**
- Database migrations via Supabase MCP

**Step 1: Create profiles table**

Apply migration `create_profiles`:
```sql
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text,
  avatar_url text,
  preferred_units text not null default 'lbs' check (preferred_units in ('lbs', 'kg')),
  overload_sessions_threshold int not null default 3,
  overload_increment_lbs numeric not null default 5,
  overload_increment_kg numeric not null default 2.5,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data->>'display_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

**Step 2: Create equipment table**

Apply migration `create_equipment`:
```sql
create table public.equipment (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  category text,
  icon text,
  created_at timestamptz not null default now()
);

alter table public.equipment enable row level security;

create policy "Equipment is readable by all authenticated users"
  on public.equipment for select
  to authenticated
  using (true);

-- Seed common equipment
insert into public.equipment (name, category) values
  ('Barbell', 'free_weights'),
  ('Dumbbells', 'free_weights'),
  ('EZ Curl Bar', 'free_weights'),
  ('Kettlebell', 'free_weights'),
  ('Flat Bench', 'benches'),
  ('Adjustable Bench', 'benches'),
  ('Squat Rack', 'racks'),
  ('Power Rack', 'racks'),
  ('Smith Machine', 'machines'),
  ('Cable Machine', 'machines'),
  ('Lat Pulldown Machine', 'machines'),
  ('Leg Press Machine', 'machines'),
  ('Leg Extension Machine', 'machines'),
  ('Leg Curl Machine', 'machines'),
  ('Chest Fly Machine', 'machines'),
  ('Pull-Up Bar', 'bodyweight'),
  ('Dip Station', 'bodyweight'),
  ('Resistance Bands', 'accessories'),
  ('Ab Wheel', 'accessories'),
  ('Foam Roller', 'accessories'),
  ('Bodyweight Only', 'bodyweight');
```

**Step 3: Create muscles table**

Apply migration `create_muscles`:
```sql
create table public.muscles (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  muscle_group text not null,
  created_at timestamptz not null default now()
);

alter table public.muscles enable row level security;

create policy "Muscles are readable by all authenticated users"
  on public.muscles for select
  to authenticated
  using (true);

insert into public.muscles (name, muscle_group) values
  ('Chest', 'chest'),
  ('Triceps', 'arms'),
  ('Biceps', 'arms'),
  ('Forearms', 'arms'),
  ('Front Delts', 'shoulders'),
  ('Side Delts', 'shoulders'),
  ('Rear Delts', 'shoulders'),
  ('Lats', 'back'),
  ('Upper Back', 'back'),
  ('Lower Back', 'back'),
  ('Quads', 'legs'),
  ('Hamstrings', 'legs'),
  ('Glutes', 'legs'),
  ('Calves', 'legs'),
  ('Abs', 'core');
```

**Step 4: Create equipment_profiles and junction table**

Apply migration `create_equipment_profiles`:
```sql
create table public.equipment_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.equipment_profile_items (
  id uuid primary key default gen_random_uuid(),
  equipment_profile_id uuid not null references public.equipment_profiles(id) on delete cascade,
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  unique (equipment_profile_id, equipment_id)
);

alter table public.equipment_profiles enable row level security;
alter table public.equipment_profile_items enable row level security;

create policy "Users can manage own equipment profiles"
  on public.equipment_profiles for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage own equipment profile items"
  on public.equipment_profile_items for all
  using (
    exists (
      select 1 from public.equipment_profiles ep
      where ep.id = equipment_profile_id and ep.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.equipment_profiles ep
      where ep.id = equipment_profile_id and ep.user_id = auth.uid()
    )
  );

-- Ensure only one active profile per user
create or replace function public.ensure_single_active_profile()
returns trigger as $$
begin
  if new.is_active = true then
    update public.equipment_profiles
    set is_active = false
    where user_id = new.user_id and id != new.id and is_active = true;
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger enforce_single_active_profile
  before insert or update on public.equipment_profiles
  for each row execute function public.ensure_single_active_profile();
```

**Step 5: Verify tables exist**

Use Supabase MCP `list_tables` to confirm all tables were created.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: create core schema — profiles, equipment, muscles, equipment_profiles"
```

---

### Task 7: Create Exercise Schema with Seed Data

**Files:**
- Database migrations via Supabase MCP

**Step 1: Create exercises table and junction tables**

Apply migration `create_exercises`:
```sql
create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  instructions text,
  is_custom boolean not null default false,
  created_by uuid references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.exercise_equipment (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  unique (exercise_id, equipment_id)
);

create table public.exercise_muscles (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  muscle_id uuid not null references public.muscles(id) on delete cascade,
  role text not null check (role in ('primary', 'secondary')),
  unique (exercise_id, muscle_id)
);

alter table public.exercises enable row level security;
alter table public.exercise_equipment enable row level security;
alter table public.exercise_muscles enable row level security;

-- Exercises: users can read all pre-built + their own custom
create policy "Users can read all pre-built exercises"
  on public.exercises for select
  to authenticated
  using (is_custom = false or created_by = auth.uid());

create policy "Users can create custom exercises"
  on public.exercises for insert
  to authenticated
  with check (is_custom = true and created_by = auth.uid());

create policy "Users can update own custom exercises"
  on public.exercises for update
  to authenticated
  using (is_custom = true and created_by = auth.uid());

create policy "Users can delete own custom exercises"
  on public.exercises for delete
  to authenticated
  using (is_custom = true and created_by = auth.uid());

-- Junction tables follow exercise visibility
create policy "Exercise equipment readable with exercise"
  on public.exercise_equipment for select
  to authenticated
  using (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id
      and (e.is_custom = false or e.created_by = auth.uid())
    )
  );

create policy "Users can manage custom exercise equipment"
  on public.exercise_equipment for all
  to authenticated
  using (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id and e.is_custom = true and e.created_by = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id and e.is_custom = true and e.created_by = auth.uid()
    )
  );

create policy "Exercise muscles readable with exercise"
  on public.exercise_muscles for select
  to authenticated
  using (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id
      and (e.is_custom = false or e.created_by = auth.uid())
    )
  );

create policy "Users can manage custom exercise muscles"
  on public.exercise_muscles for all
  to authenticated
  using (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id and e.is_custom = true and e.created_by = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.exercises e
      where e.id = exercise_id and e.is_custom = true and e.created_by = auth.uid()
    )
  );
```

**Step 2: Seed exercise data**

Apply migration `seed_exercises`. This is a large seed — include ~40 common exercises across all major muscle groups. Use subqueries to reference equipment and muscles by name:

```sql
-- Helper function to get IDs
create or replace function get_equipment_id(eq_name text) returns uuid as $$
  select id from public.equipment where name = eq_name;
$$ language sql stable;

create or replace function get_muscle_id(m_name text) returns uuid as $$
  select id from public.muscles where name = m_name;
$$ language sql stable;

-- CHEST exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Barbell Bench Press', 'Compound chest exercise', 'Lie on flat bench, grip barbell slightly wider than shoulders, lower to chest, press up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell')),
  ((select id from ex), get_equipment_id('Flat Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Barbell Bench Press';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dumbbell Bench Press', 'Compound chest exercise with greater range of motion', 'Lie on flat bench, press dumbbells from chest level to full extension.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells')),
  ((select id from ex), get_equipment_id('Flat Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Dumbbell Bench Press';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Incline Dumbbell Press', 'Upper chest focused press', 'Set bench to 30-45 degrees, press dumbbells from chest to full extension.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells')),
  ((select id from ex), get_equipment_id('Adjustable Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Front Delts', 'secondary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Incline Dumbbell Press';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Cable Fly', 'Isolation chest exercise', 'Stand between cable towers, bring handles together in an arc motion at chest level.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Cable Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary')) as m(name, role)
where e.name = 'Cable Fly';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Push-Ups', 'Bodyweight chest exercise', 'Start in plank position, lower chest to floor, push back up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Push-Ups';

-- BACK exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Barbell Row', 'Compound back exercise', 'Bend at hips, pull barbell to lower chest, squeeze shoulder blades.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Upper Back', 'primary'), ('Lats', 'primary'), ('Biceps', 'secondary'), ('Rear Delts', 'secondary')) as m(name, role)
where e.name = 'Barbell Row';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Pull-Ups', 'Bodyweight back exercise', 'Hang from bar with overhand grip, pull chin above bar.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Upper Back', 'secondary'), ('Biceps', 'secondary')) as m(name, role)
where e.name = 'Pull-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Lat Pulldown', 'Machine back exercise', 'Sit at lat pulldown machine, pull bar to upper chest.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Lat Pulldown Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Upper Back', 'secondary'), ('Biceps', 'secondary')) as m(name, role)
where e.name = 'Lat Pulldown';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dumbbell Row', 'Unilateral back exercise', 'Place one knee and hand on bench, row dumbbell to hip with other arm.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells')),
  ((select id from ex), get_equipment_id('Flat Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Upper Back', 'secondary'), ('Biceps', 'secondary'), ('Rear Delts', 'secondary')) as m(name, role)
where e.name = 'Dumbbell Row';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Cable Row', 'Seated back exercise', 'Sit at cable row station, pull handle to torso, squeeze back.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Cable Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Upper Back', 'primary'), ('Lats', 'primary'), ('Biceps', 'secondary')) as m(name, role)
where e.name = 'Cable Row';

-- SHOULDERS exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Overhead Press', 'Compound shoulder exercise', 'Press barbell overhead from shoulder height to lockout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Side Delts', 'secondary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Overhead Press';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dumbbell Lateral Raise', 'Isolation shoulder exercise', 'Stand with dumbbells at sides, raise arms to shoulder height.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Side Delts', 'primary')) as m(name, role)
where e.name = 'Dumbbell Lateral Raise';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Face Pull', 'Rear delt and upper back exercise', 'Pull cable rope to face, spreading apart at end.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Cable Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Rear Delts', 'primary'), ('Upper Back', 'secondary')) as m(name, role)
where e.name = 'Face Pull';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dumbbell Shoulder Press', 'Compound shoulder exercise', 'Press dumbbells overhead from shoulder height while seated or standing.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Side Delts', 'secondary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Dumbbell Shoulder Press';

-- ARMS exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Barbell Curl', 'Bicep isolation exercise', 'Stand with barbell, curl to shoulders keeping elbows stationary.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Biceps', 'primary'), ('Forearms', 'secondary')) as m(name, role)
where e.name = 'Barbell Curl';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dumbbell Curl', 'Bicep isolation exercise', 'Curl dumbbells alternating or together, full range of motion.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Biceps', 'primary'), ('Forearms', 'secondary')) as m(name, role)
where e.name = 'Dumbbell Curl';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Hammer Curl', 'Bicep and forearm exercise', 'Curl dumbbells with neutral (palms facing) grip.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Biceps', 'primary'), ('Forearms', 'primary')) as m(name, role)
where e.name = 'Hammer Curl';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Tricep Pushdown', 'Tricep isolation exercise', 'Push cable bar down from chest to full arm extension.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Cable Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary')) as m(name, role)
where e.name = 'Tricep Pushdown';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Skull Crushers', 'Tricep isolation exercise', 'Lie on bench, lower EZ bar to forehead, extend arms.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('EZ Curl Bar')),
  ((select id from ex), get_equipment_id('Flat Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary')) as m(name, role)
where e.name = 'Skull Crushers';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dips', 'Compound arm and chest exercise', 'Lower body between dip bars until upper arms are parallel to floor, push up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dip Station'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary'), ('Chest', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Dips';

-- LEGS exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Barbell Squat', 'Compound leg exercise', 'Bar on upper back, squat to parallel or below, stand back up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell')),
  ((select id from ex), get_equipment_id('Squat Rack'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Barbell Squat';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Romanian Deadlift', 'Hip hinge exercise', 'Hinge at hips with barbell, feel hamstring stretch, return to standing.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Hamstrings', 'primary'), ('Glutes', 'primary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Romanian Deadlift';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Leg Press', 'Machine compound leg exercise', 'Push platform away with feet, control the return.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Leg Press Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'secondary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Leg Press';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Leg Extension', 'Quad isolation exercise', 'Sit on machine, extend legs to full lockout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Leg Extension Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary')) as m(name, role)
where e.name = 'Leg Extension';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Leg Curl', 'Hamstring isolation exercise', 'Lie on machine, curl legs toward glutes.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Leg Curl Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Hamstrings', 'primary')) as m(name, role)
where e.name = 'Leg Curl';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bulgarian Split Squat', 'Unilateral leg exercise', 'Rear foot on bench, squat down on front leg.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells')),
  ((select id from ex), get_equipment_id('Flat Bench'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Bulgarian Split Squat';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Calf Raise', 'Calf isolation exercise', 'Stand on edge of step, raise up onto toes, lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Calves', 'primary')) as m(name, role)
where e.name = 'Calf Raise';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Goblet Squat', 'Dumbbell squat variation', 'Hold dumbbell at chest, squat to parallel or below.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dumbbells'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary')) as m(name, role)
where e.name = 'Goblet Squat';

-- CORE exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Plank', 'Core stability exercise', 'Hold push-up position on forearms, keep body straight.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Plank';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Cable Crunch', 'Weighted ab exercise', 'Kneel at cable machine, crunch down pulling rope toward floor.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Cable Machine'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Cable Crunch';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Hanging Leg Raise', 'Advanced ab exercise', 'Hang from pull-up bar, raise legs to parallel.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Hanging Leg Raise';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Ab Wheel Rollout', 'Core strengthening exercise', 'Kneel on floor, roll ab wheel forward, pull back in.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Ab Wheel'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Ab Wheel Rollout';

-- COMPOUND exercises
with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Deadlift', 'Full body compound exercise', 'Stand over barbell, grip bar, drive through floor to standing.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Barbell'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lower Back', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'primary'), ('Quads', 'secondary'), ('Upper Back', 'secondary'), ('Forearms', 'secondary')) as m(name, role)
where e.name = 'Deadlift';

-- Drop helper functions (they were just for seeding)
drop function get_equipment_id;
drop function get_muscle_id;
```

**Step 3: Verify data**

Use Supabase MCP `execute_sql`:
```sql
select count(*) as exercise_count from public.exercises;
select e.name, array_agg(distinct eq.name) as equipment, array_agg(distinct m.name || ' (' || em.role || ')') as muscles
from exercises e
left join exercise_equipment ee on ee.exercise_id = e.id
left join equipment eq on eq.id = ee.equipment_id
left join exercise_muscles em on em.exercise_id = e.id
left join muscles m on m.id = em.muscle_id
group by e.name
order by e.name
limit 5;
```

Expected: ~30 exercises with correct equipment and muscle associations.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: create exercise schema with seed data (~30 exercises)"
```

---

### Task 8: Create Workout & Session Schema

**Files:**
- Database migrations via Supabase MCP

**Step 1: Create workout templates tables**

Apply migration `create_workout_templates`:
```sql
create table public.workout_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  is_shared boolean not null default false,
  share_token uuid unique default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.template_exercises (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references public.workout_templates(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  order_index int not null,
  target_sets int not null default 3,
  target_reps int not null default 10,
  target_weight numeric,
  created_at timestamptz not null default now()
);

alter table public.workout_templates enable row level security;
alter table public.template_exercises enable row level security;

-- Templates: owner has full access, shared templates readable via token
create policy "Users can manage own templates"
  on public.workout_templates for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Shared templates are readable"
  on public.workout_templates for select
  to authenticated
  using (is_shared = true);

create policy "Users can manage own template exercises"
  on public.template_exercises for all
  using (
    exists (
      select 1 from public.workout_templates wt
      where wt.id = template_id and wt.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.workout_templates wt
      where wt.id = template_id and wt.user_id = auth.uid()
    )
  );

create policy "Shared template exercises are readable"
  on public.template_exercises for select
  to authenticated
  using (
    exists (
      select 1 from public.workout_templates wt
      where wt.id = template_id and wt.is_shared = true
    )
  );
```

**Step 2: Create workout sessions tables**

Apply migration `create_workout_sessions`:
```sql
create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  template_id uuid references public.workout_templates(id) on delete set null,
  date date not null default current_date,
  duration_minutes int,
  notes text,
  completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.session_sets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  set_number int not null,
  weight numeric not null default 0,
  reps int not null default 0,
  rpe numeric check (rpe >= 1 and rpe <= 10),
  created_at timestamptz not null default now()
);

alter table public.workout_sessions enable row level security;
alter table public.session_sets enable row level security;

create policy "Users can manage own sessions"
  on public.workout_sessions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage own session sets"
  on public.session_sets for all
  using (
    exists (
      select 1 from public.workout_sessions ws
      where ws.id = session_id and ws.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.workout_sessions ws
      where ws.id = session_id and ws.user_id = auth.uid()
    )
  );

-- Index for common queries
create index idx_workout_sessions_user_date on public.workout_sessions(user_id, date desc);
create index idx_session_sets_session on public.session_sets(session_id);
create index idx_session_sets_exercise on public.session_sets(exercise_id);
```

**Step 3: Verify tables exist**

```sql
select table_name from information_schema.tables where table_schema = 'public' order by table_name;
```

Expected: All tables present (equipment, equipment_profile_items, equipment_profiles, exercise_equipment, exercise_muscles, exercises, muscles, profiles, session_sets, template_exercises, workout_sessions, workout_templates).

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: create workout template and session schema with RLS"
```

---

## Phase 3: TypeScript Types & Supabase Client Helpers

### Task 9: Generate TypeScript Types

**Files:**
- Create: `src/lib/database.types.ts`

**Step 1: Generate types from Supabase**

Use the Supabase MCP `generate_typescript_types` tool with the project ID. Save the output to `src/lib/database.types.ts`.

**Step 2: Create typed Supabase client helper**

Create `src/lib/supabase/typed-client.ts`:
```typescript
import type { Database } from "@/lib/database.types";
import { createBrowserClient } from "@supabase/ssr";

export function createTypedClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: generate TypeScript types from Supabase schema"
```

---

## Phase 4: Auth Pages

### Task 10: Build Login and Signup Pages

**Files:**
- Create: `src/app/login/page.tsx`
- Create: `src/app/signup/page.tsx`
- Create: `src/app/auth/callback/route.ts`
- Create: `src/lib/actions/auth.ts`

**Step 1: Install shadcn/ui components needed**

```bash
npx shadcn@latest add button input label card toast sonner
```

**Step 2: Create auth server actions**

Create `src/lib/actions/auth.ts`:
```typescript
"use server";

import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export async function signUp(formData: FormData) {
  const supabase = await createClient();
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;
  const displayName = formData.get("displayName") as string;

  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { display_name: displayName },
    },
  });

  if (error) {
    return { error: error.message };
  }

  redirect("/");
}

export async function signIn(formData: FormData) {
  const supabase = await createClient();
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return { error: error.message };
  }

  redirect("/");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}
```

**Step 3: Create auth callback route**

Create `src/app/auth/callback/route.ts`:
```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    const supabase = await createClient();
    await supabase.auth.exchangeCodeForSession(code);
  }

  return NextResponse.redirect(`${origin}/`);
}
```

**Step 4: Create login page**

Create `src/app/login/page.tsx`:
```tsx
import { signIn } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle className="text-2xl">GearFit</CardTitle>
          <CardDescription>Sign in to your account</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input id="email" name="email" type="email" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input id="password" name="password" type="password" required />
            </div>
            <Button formAction={signIn} className="w-full">Sign In</Button>
          </form>
          <p className="mt-4 text-center text-sm text-muted-foreground">
            No account?{" "}
            <Link href="/signup" className="underline">Sign up</Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
```

**Step 5: Create signup page**

Create `src/app/signup/page.tsx`:
```tsx
import { signUp } from "@/lib/actions/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";

export default function SignupPage() {
  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle className="text-2xl">Join GearFit</CardTitle>
          <CardDescription>Create your account</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="displayName">Display Name</Label>
              <Input id="displayName" name="displayName" type="text" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input id="email" name="email" type="email" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input id="password" name="password" type="password" required minLength={6} />
            </div>
            <Button formAction={signUp} className="w-full">Create Account</Button>
          </form>
          <p className="mt-4 text-center text-sm text-muted-foreground">
            Already have an account?{" "}
            <Link href="/login" className="underline">Sign in</Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
```

**Step 6: Verify pages render**

```bash
npm run dev
```
Navigate to http://localhost:3000/login and http://localhost:3000/signup. Both should render forms.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: add login and signup pages with Supabase auth"
```

---

## Phase 5: App Layout & Navigation

### Task 11: Create App Shell with Navigation

**Files:**
- Create: `src/components/nav/sidebar.tsx`
- Create: `src/components/nav/mobile-nav.tsx`
- Modify: `src/app/layout.tsx`
- Create: `src/app/(app)/layout.tsx` (authenticated layout)

**Step 1: Install additional shadcn components**

```bash
npx shadcn@latest add sheet avatar dropdown-menu separator
```

**Step 2: Create the authenticated app layout**

Create route group `src/app/(app)/` for all authenticated pages. This layout wraps all protected routes with navigation.

Create `src/app/(app)/layout.tsx`:
```tsx
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { Sidebar } from "@/components/nav/sidebar";
import { MobileNav } from "@/components/nav/mobile-nav";

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  return (
    <div className="flex min-h-screen">
      <Sidebar user={user} profile={profile} />
      <main className="flex-1 pb-16 md:pb-0">
        <div className="container mx-auto max-w-4xl p-4 md:p-6">
          {children}
        </div>
      </main>
      <MobileNav />
    </div>
  );
}
```

**Step 3: Create sidebar component**

Create `src/components/nav/sidebar.tsx` with links to: Dashboard (/), Workouts (/workouts), Exercises (/exercises), History (/history), Equipment (/equipment), Profile (/profile). Include sign-out button. Desktop only (hidden on mobile).

**Step 4: Create mobile bottom navigation**

Create `src/components/nav/mobile-nav.tsx` with bottom tab bar for the 5 most important routes. Mobile only (hidden on desktop).

**Step 5: Move existing `src/app/page.tsx` to `src/app/(app)/page.tsx`**

This becomes the dashboard. For now, just a placeholder:
```tsx
export default function DashboardPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <p className="text-muted-foreground">Welcome to GearFit</p>
    </div>
  );
}
```

**Step 6: Create placeholder pages for all routes**

Create placeholder `page.tsx` files in:
- `src/app/(app)/workouts/page.tsx`
- `src/app/(app)/exercises/page.tsx`
- `src/app/(app)/history/page.tsx`
- `src/app/(app)/equipment/page.tsx`
- `src/app/(app)/profile/page.tsx`

Each should export a simple component with the page name as an h1.

**Step 7: Verify navigation works**

```bash
npm run dev
```
Sign up, then navigate between all routes. All pages should render with navigation.

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: add app shell with sidebar and mobile navigation"
```

---

## Phase 6: Equipment Profiles

### Task 12: Build Equipment Profile Management

**Files:**
- Create: `src/lib/actions/equipment.ts`
- Create: `src/app/(app)/equipment/page.tsx` (replace placeholder)
- Create: `src/components/equipment/equipment-profile-form.tsx`
- Create: `src/components/equipment/equipment-profile-card.tsx`

**Step 1: Create equipment server actions**

Create `src/lib/actions/equipment.ts` with these server actions:
- `getEquipmentList()` — fetch all equipment
- `getEquipmentProfiles()` — fetch user's profiles with items
- `createEquipmentProfile(formData)` — create profile with selected equipment
- `updateEquipmentProfile(id, formData)` — update profile
- `setActiveProfile(id)` — mark profile as active
- `deleteEquipmentProfile(id)` — delete profile

**Step 2: Build equipment profile form component**

Create `src/components/equipment/equipment-profile-form.tsx`:
- Text input for profile name
- Checkbox grid of all available equipment (grouped by category)
- Submit button

**Step 3: Build equipment profile card component**

Create `src/components/equipment/equipment-profile-card.tsx`:
- Shows profile name, equipment list
- "Set Active" button (if not already active)
- Edit and Delete buttons
- Active indicator badge

**Step 4: Build equipment page**

Replace placeholder `src/app/(app)/equipment/page.tsx`:
- List of user's equipment profiles as cards
- "Create New Profile" button that opens the form
- Active profile highlighted

**Step 5: Test manually**

Create an equipment profile, add equipment, set it as active, verify switching works.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: equipment profile management (create, edit, set active, delete)"
```

---

## Phase 7: Exercise Library

### Task 13: Build Exercise Library Page

**Files:**
- Create: `src/lib/actions/exercises.ts`
- Create: `src/app/(app)/exercises/page.tsx` (replace placeholder)
- Create: `src/app/(app)/exercises/[id]/page.tsx`
- Create: `src/components/exercises/exercise-card.tsx`
- Create: `src/components/exercises/exercise-filters.tsx`

**Step 1: Create exercise server actions**

Create `src/lib/actions/exercises.ts`:
- `getExercises(filters)` — fetch exercises with optional filters (muscle group, equipment availability based on active profile, search text)
- `getExercise(id)` — fetch single exercise with equipment and muscle details
- `getAvailableExercises()` — exercises filtered to active equipment profile
- `createCustomExercise(formData)` — create user exercise
- `getExerciseSwapSuggestions(exerciseId)` — find alternatives for same muscles with available equipment

The key query for equipment filtering:
```sql
select e.* from exercises e
where not exists (
  select 1 from exercise_equipment ee
  where ee.exercise_id = e.id
  and ee.equipment_id not in (
    select epi.equipment_id from equipment_profile_items epi
    join equipment_profiles ep on ep.id = epi.equipment_profile_id
    where ep.user_id = auth.uid() and ep.is_active = true
  )
)
```

**Step 2: Build exercise filters component**

Filter by: muscle group dropdown, equipment availability toggle ("show all" vs "available only"), search text input.

**Step 3: Build exercise card component**

Shows: exercise name, primary muscles as badges, required equipment icons.

**Step 4: Build exercise library page**

Grid of exercise cards with filters at the top. Equipment filter defaults to "available only" based on active profile.

**Step 5: Build exercise detail page**

`src/app/(app)/exercises/[id]/page.tsx`:
- Exercise name, description, instructions
- Required equipment list
- Primary and secondary muscles
- (Placeholder for history chart — built in Phase 9)

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: exercise library with equipment-based filtering"
```

---

## Phase 8: Workout Templates

### Task 14: Build Workout Template Management

**Files:**
- Create: `src/lib/actions/templates.ts`
- Create: `src/app/(app)/workouts/page.tsx` (replace placeholder)
- Create: `src/app/(app)/workouts/[id]/page.tsx`
- Create: `src/app/(app)/workouts/new/page.tsx`
- Create: `src/components/workouts/template-card.tsx`
- Create: `src/components/workouts/template-exercise-list.tsx`
- Create: `src/components/workouts/add-exercise-dialog.tsx`

**Step 1: Create template server actions**

Create `src/lib/actions/templates.ts`:
- `getTemplates()` — fetch user's workout templates
- `getTemplate(id)` — fetch template with exercises
- `createTemplate(formData)` — create template
- `updateTemplate(id, formData)` — update template details
- `addExerciseToTemplate(templateId, exerciseId, order)` — add exercise
- `removeExerciseFromTemplate(templateExerciseId)` — remove exercise
- `reorderTemplateExercises(templateId, exerciseIds)` — reorder
- `updateTemplateExercise(id, data)` — update target sets/reps/weight
- `cloneTemplate(id)` — duplicate a template
- `deleteTemplate(id)` — delete template

**Step 2: Build template card component**

Shows template name, exercise count, last used date. Click to navigate to detail.

**Step 3: Build workouts list page**

Grid of template cards with "Create New Workout" button.

**Step 4: Build add exercise dialog**

Dialog/drawer that shows available exercises (filtered by active equipment profile), with search. Click to add to template.

**Step 5: Build template exercise list component**

Ordered list of exercises in the template. Each row shows: exercise name, target sets x reps x weight, edit/remove buttons. Supports drag-to-reorder (or up/down arrows for simplicity).

**Step 6: Build template detail/edit page**

`src/app/(app)/workouts/[id]/page.tsx`:
- Template name (editable)
- Template exercise list
- "Add Exercise" button
- "Start Workout" button (links to `/workouts/[id]/start`)
- "Clone" and "Delete" actions

**Step 7: Build new template page**

`src/app/(app)/workouts/new/page.tsx`:
- Simple form for template name and description
- Redirects to template detail page after creation

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: workout template CRUD with exercise management"
```

---

## Phase 9: Active Workout Session

### Task 15: Build Active Workout Logging

**Files:**
- Create: `src/lib/actions/sessions.ts`
- Create: `src/app/(app)/workouts/[id]/start/page.tsx`
- Create: `src/components/workout-session/active-exercise.tsx`
- Create: `src/components/workout-session/set-logger.tsx`
- Create: `src/components/workout-session/finish-workout-dialog.tsx`

**Step 1: Create session server actions**

Create `src/lib/actions/sessions.ts`:
- `startSession(templateId?)` — create workout_session, return ID
- `logSet(sessionId, exerciseId, setNumber, weight, reps, rpe?)` — add/update a set
- `deleteSet(setId)` — remove a set
- `finishSession(sessionId, durationMinutes, notes?)` — mark session complete
- `getLastSessionForExercise(exerciseId)` — fetch most recent sets for reference
- `getSession(id)` — fetch session with all sets

**Step 2: Build set logger component**

`src/components/workout-session/set-logger.tsx`:
- Shows set number, weight input, reps input
- Displays last session's weight/reps as reference (grayed out)
- Checkmark button to confirm set
- Progressive overload hint banner (if applicable — see Phase 10)

**Step 3: Build active exercise component**

`src/components/workout-session/active-exercise.tsx`:
- Exercise name and target sets/reps
- List of set loggers (one per target set, can add more)
- "Swap Exercise" button (links to swap suggestions)

**Step 4: Build finish workout dialog**

Shows session summary (exercises completed, total sets, duration). Optional notes field. Confirm to save.

**Step 5: Build active workout page**

`src/app/(app)/workouts/[id]/start/page.tsx`:
- Client component (needs real-time state)
- Lists exercises from template
- Each exercise has set loggers with previous session data
- Timer running at top
- "Finish Workout" button at bottom

**Step 6: Test the full workout flow manually**

1. Create a template with 3 exercises
2. Start a workout from the template
3. Log sets for each exercise
4. Finish the workout
5. Verify session appears in history

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: active workout session with real-time set logging"
```

---

## Phase 10: Progress Tracking & History

### Task 16: Build Workout History & Progress Charts

**Files:**
- Create: `src/lib/actions/history.ts`
- Create: `src/app/(app)/history/page.tsx` (replace placeholder)
- Create: `src/app/(app)/history/[id]/page.tsx`
- Create: `src/components/history/workout-calendar.tsx`
- Create: `src/components/history/session-summary.tsx`
- Create: `src/components/exercises/exercise-progress-chart.tsx`

**Step 1: Install chart library**

```bash
npm install recharts
```

**Step 2: Create history server actions**

Create `src/lib/actions/history.ts`:
- `getSessionsByMonth(year, month)` — sessions for calendar view
- `getSession(id)` — full session detail with sets
- `getExerciseHistory(exerciseId, limit?)` — historical sets for an exercise (for progress chart)
- `getPersonalBests(exerciseId)` — max weight, max reps, max volume
- `getTrainingStreak()` — consecutive weeks with at least one session
- `getWeeklyMuscleCoverage()` — sets per muscle group this week

**Step 3: Build workout calendar component**

`src/components/history/workout-calendar.tsx`:
- Month view calendar grid
- Dots on days with sessions
- Click a day to see sessions
- Navigation arrows for months
- Training streak counter

**Step 4: Build history page**

Calendar view with session summaries below. Shows streak counter.

**Step 5: Build session detail page**

`src/app/(app)/history/[id]/page.tsx`:
- Date, duration, template name
- List of exercises with logged sets (weight x reps)
- Notes if present

**Step 6: Build exercise progress chart**

`src/components/exercises/exercise-progress-chart.tsx` (using Recharts):
- Line chart showing weight over time for a specific exercise
- X-axis: date, Y-axis: weight
- Each data point is the max weight from that session
- Displays personal bests

**Step 7: Add progress chart to exercise detail page**

Update `src/app/(app)/exercises/[id]/page.tsx` to include the progress chart and personal bests section.

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: workout history calendar and exercise progress charts"
```

---

## Phase 11: Progressive Overload & Muscle Coverage

### Task 17: Build Progressive Overload Hints

**Files:**
- Create: `src/lib/utils/progressive-overload.ts`
- Modify: `src/components/workout-session/set-logger.tsx` (add hint)

**Step 1: Write failing test for overload logic**

Create `src/lib/utils/__tests__/progressive-overload.test.ts`:
```typescript
import { describe, it, expect } from "vitest";
import { shouldSuggestIncrease } from "../progressive-overload";

describe("shouldSuggestIncrease", () => {
  it("suggests increase when target reps hit for 3 consecutive sessions", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(true);
  });

  it("does not suggest increase when fewer than threshold sessions", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(false);
  });

  it("does not suggest increase when reps were not all hit", () => {
    const sessions = [
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 8, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
      { sets: [{ reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }, { reps: 10, targetReps: 10 }] },
    ];
    expect(shouldSuggestIncrease(sessions, 3)).toBe(false);
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npm test -- src/lib/utils/__tests__/progressive-overload.test.ts
```
Expected: FAIL — module not found.

**Step 3: Implement progressive overload logic**

Create `src/lib/utils/progressive-overload.ts`:
```typescript
interface SetData {
  reps: number;
  targetReps: number;
}

interface SessionData {
  sets: SetData[];
}

export function shouldSuggestIncrease(
  recentSessions: SessionData[],
  threshold: number
): boolean {
  if (recentSessions.length < threshold) return false;

  const lastN = recentSessions.slice(0, threshold);
  return lastN.every((session) =>
    session.sets.every((set) => set.reps >= set.targetReps)
  );
}

export function getWeightIncrement(units: "lbs" | "kg", incrementLbs: number, incrementKg: number): number {
  return units === "lbs" ? incrementLbs : incrementKg;
}
```

**Step 4: Run test to verify it passes**

```bash
npm test -- src/lib/utils/__tests__/progressive-overload.test.ts
```
Expected: All 3 tests pass.

**Step 5: Integrate hint into set logger**

Update `src/components/workout-session/set-logger.tsx` to:
- Fetch recent session data for the exercise
- Run `shouldSuggestIncrease` logic
- Display a banner like "You've hit your target for 3 sessions — try adding 5 lbs!"

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: progressive overload hints with TDD"
```

---

### Task 18: Build Muscle Group Coverage View

**Files:**
- Create: `src/components/dashboard/muscle-coverage.tsx`
- Modify: `src/app/(app)/page.tsx` (add to dashboard)

**Step 1: Build muscle coverage component**

`src/components/dashboard/muscle-coverage.tsx`:
- Fetches weekly session data (sets per muscle group)
- Bar chart (horizontal) showing sets per muscle group
- Color coding: green (adequate), yellow (low), red (untrained)
- Default threshold: 10+ sets/week = adequate, 5-9 = low, <5 = undertrained

**Step 2: Add to dashboard**

Update `src/app/(app)/page.tsx` to include the muscle coverage chart.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: muscle group coverage view on dashboard"
```

---

## Phase 12: Exercise Swap Suggestions

### Task 19: Build Exercise Swap Feature

**Files:**
- Create: `src/components/workout-session/swap-exercise-dialog.tsx`
- Modify: `src/lib/actions/exercises.ts` (add swap logic)

**Step 1: Write failing test for swap ranking**

Create `src/lib/utils/__tests__/exercise-swap.test.ts`:
```typescript
import { describe, it, expect } from "vitest";
import { rankSwapSuggestions } from "../exercise-swap";

describe("rankSwapSuggestions", () => {
  it("ranks exercises with more secondary muscle overlap higher", () => {
    const original = { primaryMuscles: ["chest"], secondaryMuscles: ["triceps", "front_delts"] };
    const candidates = [
      { id: "a", primaryMuscles: ["chest"], secondaryMuscles: ["triceps"] },
      { id: "b", primaryMuscles: ["chest"], secondaryMuscles: ["triceps", "front_delts"] },
      { id: "c", primaryMuscles: ["chest"], secondaryMuscles: [] },
    ];
    const ranked = rankSwapSuggestions(original, candidates);
    expect(ranked[0].id).toBe("b");
    expect(ranked[1].id).toBe("a");
    expect(ranked[2].id).toBe("c");
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npm test -- src/lib/utils/__tests__/exercise-swap.test.ts
```

**Step 3: Implement swap ranking**

Create `src/lib/utils/exercise-swap.ts`:
```typescript
interface ExerciseForSwap {
  id: string;
  primaryMuscles: string[];
  secondaryMuscles: string[];
}

export function rankSwapSuggestions(
  original: { primaryMuscles: string[]; secondaryMuscles: string[] },
  candidates: ExerciseForSwap[]
): ExerciseForSwap[] {
  return candidates
    .map((candidate) => {
      const overlapCount = original.secondaryMuscles.filter((m) =>
        candidate.secondaryMuscles.includes(m)
      ).length;
      return { ...candidate, overlapCount };
    })
    .sort((a, b) => b.overlapCount - a.overlapCount);
}
```

**Step 4: Run test to verify it passes**

```bash
npm test -- src/lib/utils/__tests__/exercise-swap.test.ts
```
Expected: PASS.

**Step 5: Build swap dialog**

`src/components/workout-session/swap-exercise-dialog.tsx`:
- Shows suggested alternatives ranked by muscle overlap
- Each suggestion shows: name, equipment needed, muscle match percentage
- Click to swap the exercise in the active session

**Step 6: Integrate into active workout**

Update `src/components/workout-session/active-exercise.tsx` to include "Swap" button that opens the dialog.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: exercise swap suggestions ranked by muscle overlap"
```

---

## Phase 13: Sharing

### Task 20: Build Workout Sharing

**Files:**
- Create: `src/lib/actions/sharing.ts`
- Create: `src/app/share/[token]/page.tsx` (public route, outside (app) group)
- Modify: `src/app/(app)/workouts/[id]/page.tsx` (add share button)

**Step 1: Create sharing server actions**

Create `src/lib/actions/sharing.ts`:
- `toggleShareTemplate(templateId)` — toggle is_shared, return share URL
- `getSharedTemplate(shareToken)` — fetch template by token (no auth required for viewing)
- `importSharedTemplate(shareToken)` — clone template into user's library

**Step 2: Build share page (public)**

`src/app/share/[token]/page.tsx`:
- Shows template name, description, exercise list
- "Import to My Workouts" button (requires login)
- If not logged in, show login prompt

**Step 3: Add share button to template detail page**

Update template detail to include a "Share" toggle button that generates a shareable link.

**Step 4: Test sharing flow manually**

1. Create a template
2. Share it (get link)
3. Open link in incognito (should see template, prompt to log in)
4. Log in as different user, import template

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: workout template sharing via link"
```

---

## Phase 14: Dashboard

### Task 21: Build Dashboard

**Files:**
- Modify: `src/app/(app)/page.tsx`
- Create: `src/components/dashboard/recent-sessions.tsx`
- Create: `src/components/dashboard/quick-actions.tsx`
- Create: `src/components/dashboard/todays-workout.tsx`

**Step 1: Build today's workout component**

If the user has a scheduled template for today (or their most recent template), show it with a "Start Workout" button.

**Step 2: Build recent sessions component**

Last 5 workout sessions with date, template name, and total sets.

**Step 3: Build quick actions component**

Buttons for: Start Workout, Browse Exercises, Create Template, Switch Equipment Profile.

**Step 4: Assemble dashboard**

Combine: today's workout, muscle coverage (from Task 18), recent sessions, quick actions.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: dashboard with muscle coverage, recent sessions, quick actions"
```

---

## Phase 15: Profile & Polish

### Task 22: Build Profile Page

**Files:**
- Create: `src/lib/actions/profile.ts`
- Modify: `src/app/(app)/profile/page.tsx`

**Step 1: Create profile server actions**

- `getProfile()` — fetch current user's profile
- `updateProfile(formData)` — update display name, units, overload settings

**Step 2: Build profile page**

Form with: display name, preferred units (lbs/kg toggle), overload threshold (sessions count), overload increment. Sign out button.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: user profile settings page"
```

---

### Task 23: Add Dark Mode Support

**Files:**
- Modify: `src/app/layout.tsx`
- Create: `src/components/theme-provider.tsx`
- Create: `src/components/theme-toggle.tsx`

**Step 1: Install next-themes**

```bash
npm install next-themes
```

**Step 2: Create theme provider and toggle**

Follow shadcn/ui dark mode guide. Add toggle to sidebar and mobile nav.

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: dark mode support with theme toggle"
```

---

### Task 24: Final Review & Cleanup

**Step 1: Run all tests**

```bash
npm test
```
Expected: All tests pass.

**Step 2: Run build**

```bash
npm run build
```
Expected: Build succeeds with no errors.

**Step 3: Run lint**

```bash
npm run lint
```
Expected: No lint errors.

**Step 4: Fix any issues found**

Address any test failures, build errors, or lint warnings.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: final review and cleanup"
```

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| 1 | 1-4 | Project scaffolding, deps, Vitest, Supabase config |
| 2 | 5-8 | Database schema, seed data, RLS policies |
| 3 | 9 | TypeScript types generation |
| 4 | 10 | Auth pages (login, signup) |
| 5 | 11 | App layout, sidebar, mobile nav |
| 6 | 12 | Equipment profile management |
| 7 | 13 | Exercise library with filtering |
| 8 | 14 | Workout templates CRUD |
| 9 | 15 | Active workout session logging |
| 10 | 16 | History calendar, progress charts |
| 11 | 17-18 | Progressive overload hints, muscle coverage |
| 12 | 19 | Exercise swap suggestions |
| 13 | 20 | Workout sharing |
| 14 | 21 | Dashboard assembly |
| 15 | 22-24 | Profile page, dark mode, final cleanup |
