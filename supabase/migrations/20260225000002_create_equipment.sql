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
