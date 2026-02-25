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
