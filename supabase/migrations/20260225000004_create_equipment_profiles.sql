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
