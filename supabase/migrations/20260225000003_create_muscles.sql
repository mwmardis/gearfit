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
