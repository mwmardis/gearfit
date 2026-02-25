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
