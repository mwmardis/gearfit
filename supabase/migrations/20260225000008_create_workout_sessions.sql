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

create index idx_workout_sessions_user_date on public.workout_sessions(user_id, date desc);
create index idx_session_sets_session on public.session_sets(session_id);
create index idx_session_sets_exercise on public.session_sets(exercise_id);
