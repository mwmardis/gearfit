-- Helper functions to get IDs by name
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

-- Drop helper functions (used only for seeding)
drop function get_equipment_id;
drop function get_muscle_id;
