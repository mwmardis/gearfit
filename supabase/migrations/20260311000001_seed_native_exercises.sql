-- Add native bodyweight/calisthenics exercises
-- Sources: common calisthenics exercise databases (Calistree, WorkoutLabs, etc.)

-- Helper functions to get IDs by name
create or replace function get_equipment_id(eq_name text) returns uuid as $$
  select id from public.equipment where name = eq_name;
$$ language sql stable;

create or replace function get_muscle_id(m_name text) returns uuid as $$
  select id from public.muscles where name = m_name;
$$ language sql stable;

-- ============================================================
-- CHEST exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Diamond Push-Ups', 'Tricep-focused push-up variation', 'Place hands close together under chest forming a diamond shape with thumbs and index fingers. Lower chest to hands, then press back up. Keep elbows tucked close to body throughout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'primary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Diamond Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Wide Push-Ups', 'Chest-focused push-up variation with wider hand placement', 'Place hands wider than shoulder-width apart. Lower chest toward the floor, then press back up. Focus on squeezing the chest at the top of the movement.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Wide Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Decline Push-Ups', 'Upper chest focused push-up with feet elevated', 'Place feet on a bench or elevated surface, hands on the floor shoulder-width apart. Lower chest to the floor, then press back up. The higher the feet, the more the upper chest and shoulders are engaged.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Decline Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Archer Push-Ups', 'Advanced unilateral push-up variation', 'Start in a wide push-up position. Shift your weight to one arm and lower toward that hand while the other arm extends straight out to the side. Push back up and alternate sides.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Archer Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Hindu Push-Ups', 'Dynamic push-up combining downward and upward dog movements', 'Start in a downward dog position. Swoop your body down and forward, skimming the floor, then press up into an upward dog position. Reverse the movement to return to the start.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Triceps', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Hindu Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Pseudo Planche Push-Ups', 'Advanced push-up targeting chest and front delts', 'Place hands by your waist with fingers pointing to the sides or slightly backward. Lean forward so shoulders are well past your hands. Lower and press back up while maintaining the forward lean.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Front Delts', 'primary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Pseudo Planche Push-Ups';

-- ============================================================
-- BACK exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Chin-Ups', 'Underhand grip pull-up emphasizing biceps', 'Hang from bar with underhand (supinated) grip, hands shoulder-width apart. Pull chin above bar by driving elbows down and back. Lower with control to full hang.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Biceps', 'primary'), ('Upper Back', 'secondary')) as m(name, role)
where e.name = 'Chin-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Inverted Rows', 'Horizontal pulling exercise using bodyweight', 'Lie under a bar or sturdy table. Grip with overhand grip, body straight. Pull chest to the bar by squeezing shoulder blades together. Lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Upper Back', 'primary'), ('Lats', 'secondary'), ('Biceps', 'secondary'), ('Rear Delts', 'secondary')) as m(name, role)
where e.name = 'Inverted Rows';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Wide Grip Pull-Ups', 'Pull-up variation emphasizing lat width', 'Hang from bar with overhand grip wider than shoulder-width. Pull up until chin clears the bar, focusing on driving elbows toward hips. Lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Upper Back', 'primary'), ('Rear Delts', 'secondary'), ('Biceps', 'secondary')) as m(name, role)
where e.name = 'Wide Grip Pull-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Commando Pull-Ups', 'Alternating side pull-up for grip and lat development', 'Stand perpendicular to the bar and grip it with hands close together, one in front of the other. Pull up to one side of the bar, lower, then pull up to the other side. Alternate each rep.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Biceps', 'secondary'), ('Upper Back', 'secondary')) as m(name, role)
where e.name = 'Commando Pull-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Negative Pull-Ups', 'Eccentric-focused pull-up for building pulling strength', 'Jump or step up to the top position of a pull-up with chin above the bar. Slowly lower yourself down over 3-5 seconds to a full hang. Repeat by jumping back to the top.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Upper Back', 'secondary'), ('Biceps', 'secondary')) as m(name, role)
where e.name = 'Negative Pull-Ups';

-- ============================================================
-- SHOULDERS exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Pike Push-Ups', 'Bodyweight shoulder press alternative', 'Start in a downward dog position with hips high and hands shoulder-width apart. Bend elbows to lower the top of your head toward the floor between your hands. Press back up to the starting position.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Triceps', 'secondary'), ('Side Delts', 'secondary')) as m(name, role)
where e.name = 'Pike Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Wall Handstand Push-Ups', 'Advanced bodyweight overhead pressing movement', 'Kick up into a handstand against a wall, hands shoulder-width apart. Lower your head toward the floor by bending the elbows, then press back up. Keep core tight throughout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Side Delts', 'primary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Wall Handstand Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Shoulder Taps', 'Anti-rotation core and shoulder stability exercise', 'Hold a push-up position. Lift one hand and tap the opposite shoulder, then return it to the floor. Alternate sides while keeping hips as stable as possible.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Abs', 'secondary')) as m(name, role)
where e.name = 'Shoulder Taps';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dive Bomber Push-Ups', 'Dynamic shoulder and chest movement', 'Start in downward dog. Dive forward, sweeping your chest close to the floor, then press up into upward dog. Reverse the motion back to the start position.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Front Delts', 'primary'), ('Chest', 'secondary'), ('Triceps', 'secondary')) as m(name, role)
where e.name = 'Dive Bomber Push-Ups';

-- ============================================================
-- ARMS exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Close-Grip Push-Ups', 'Tricep-dominant push-up variation', 'Place hands directly under shoulders or slightly narrower. Lower chest to the floor keeping elbows tight to your sides. Press back up to full extension.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary'), ('Chest', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Close-Grip Push-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bodyweight Tricep Extensions', 'Bodyweight skull crusher using a bar or elevated surface', 'Place hands on a bar or sturdy surface at about waist height. Walk feet back so body is angled. Bend at the elbows to lower your head below the bar, then extend arms to press back up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary')) as m(name, role)
where e.name = 'Bodyweight Tricep Extensions';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bench Dips', 'Tricep exercise using a bench or chair', 'Place hands on the edge of a bench behind you, fingers forward. Extend legs in front. Lower body by bending elbows to about 90 degrees, then press back up.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Triceps', 'primary'), ('Chest', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Bench Dips';

-- ============================================================
-- LEGS exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bodyweight Squats', 'Fundamental lower body exercise', 'Stand with feet shoulder-width apart. Push hips back and bend knees to lower until thighs are parallel to the floor. Drive through heels to stand. Keep chest up and core braced.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Bodyweight Squats';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Lunges', 'Unilateral leg exercise for strength and balance', 'Step forward with one leg, lowering your hips until both knees are bent at about 90 degrees. Push through the front heel to return to standing. Alternate legs.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Lunges';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Reverse Lunges', 'Knee-friendly lunge variation', 'Step backward with one leg, lowering your hips until both knees are at about 90 degrees. Push through the front heel to return to standing. Alternate legs.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Reverse Lunges';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Walking Lunges', 'Dynamic lunge variation covering distance', 'Step forward into a lunge, then drive through the front foot and step the back leg forward into the next lunge. Continue walking forward alternating legs.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Walking Lunges';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Pistol Squats', 'Advanced single-leg squat', 'Stand on one leg with the other leg extended straight in front of you. Squat down on the standing leg as low as possible while keeping the other leg off the ground. Press back up to standing.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary'), ('Calves', 'secondary')) as m(name, role)
where e.name = 'Pistol Squats';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Jump Squats', 'Explosive plyometric squat', 'Perform a bodyweight squat, then explosively jump as high as possible from the bottom position. Land softly with bent knees and immediately descend into the next rep.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Calves', 'secondary')) as m(name, role)
where e.name = 'Jump Squats';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Step-Ups', 'Unilateral leg exercise using an elevated surface', 'Stand in front of a bench or sturdy elevated surface. Step up with one foot, driving through the heel to stand on top. Step back down with control. Complete all reps on one side or alternate.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'secondary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Step-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Glute Bridges', 'Hip extension exercise targeting glutes', 'Lie on your back with knees bent and feet flat on the floor. Drive through your heels to lift hips toward the ceiling, squeezing glutes at the top. Lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Glute Bridges';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Single-Leg Glute Bridges', 'Unilateral glute bridge for strength imbalance correction', 'Lie on your back with one knee bent and the other leg extended straight. Drive through the planted heel to lift hips, squeezing the glute. Lower with control. Complete all reps then switch.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Single-Leg Glute Bridges';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Wall Sit', 'Isometric quad endurance exercise', 'Lean against a wall and slide down until thighs are parallel to the floor with knees at 90 degrees. Hold this position for time while keeping your back flat against the wall.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'secondary')) as m(name, role)
where e.name = 'Wall Sit';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Nordic Curls', 'Advanced bodyweight hamstring exercise', 'Kneel on the floor with feet anchored. Slowly lower your body forward by extending at the knees while keeping hips straight. Use hamstrings to control the descent. Push off the floor to return up if needed.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Hamstrings', 'primary'), ('Glutes', 'secondary')) as m(name, role)
where e.name = 'Nordic Curls';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Single-Leg Deadlift', 'Unilateral hip hinge for balance and posterior chain', 'Stand on one leg. Hinge at the hips, extending the free leg behind you as your torso lowers toward the floor. Keep your back straight. Return to standing by driving hips forward.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Hamstrings', 'primary'), ('Glutes', 'primary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Single-Leg Deadlift';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Lateral Lunges', 'Side lunge for adductors and lateral movement', 'Stand with feet together. Step wide to one side, pushing hips back and bending the stepping knee while keeping the other leg straight. Push off the bent leg to return to start. Alternate sides.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Quads', 'primary'), ('Glutes', 'primary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Lateral Lunges';

-- ============================================================
-- CORE exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Hollow Body Hold', 'Foundational gymnastics core exercise', 'Lie on your back with arms extended overhead. Press lower back into the floor, lift shoulders and legs off the ground. Hold this position with body forming a shallow curve.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Hollow Body Hold';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('V-Ups', 'Dynamic full-range ab exercise', 'Lie flat on your back with arms extended overhead. Simultaneously lift your legs and torso, reaching your hands toward your toes to form a V shape. Lower back down with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'V-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('L-Sit', 'Isometric core and hip flexor exercise', 'Support yourself on parallel bars or dip station with arms locked out. Lift legs straight in front of you until parallel to the floor. Hold this position for time.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Dip Station'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Quads', 'secondary')) as m(name, role)
where e.name = 'L-Sit';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Mountain Climbers', 'Dynamic core exercise with cardio benefits', 'Start in a push-up position. Drive one knee toward your chest, then quickly switch legs in a running motion. Keep hips level and core tight throughout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Quads', 'secondary')) as m(name, role)
where e.name = 'Mountain Climbers';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Flutter Kicks', 'Core endurance exercise targeting lower abs', 'Lie on your back with legs extended. Lift feet a few inches off the floor and alternately kick legs up and down in small, controlled movements. Keep lower back pressed to the floor.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Flutter Kicks';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Superman Hold', 'Lower back and posterior chain exercise', 'Lie face down with arms extended overhead. Simultaneously lift arms, chest, and legs off the floor. Squeeze your glutes and lower back at the top. Hold for time or perform reps.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lower Back', 'primary'), ('Glutes', 'secondary')) as m(name, role)
where e.name = 'Superman Hold';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Dead Bug', 'Anti-extension core stability exercise', 'Lie on your back with arms extended toward the ceiling and knees bent at 90 degrees. Slowly extend one arm overhead and the opposite leg out straight, keeping lower back flat on the floor. Return and alternate sides.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Lower Back', 'secondary')) as m(name, role)
where e.name = 'Dead Bug';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Side Plank', 'Lateral core stability exercise', 'Lie on your side and prop yourself up on your forearm with elbow directly under shoulder. Lift hips so body forms a straight line from head to feet. Hold for time, then switch sides.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Side Plank';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bicycle Crunches', 'Rotational ab exercise', 'Lie on your back with hands behind your head. Bring one knee toward your chest while rotating the opposite elbow to meet it. Alternate sides in a pedaling motion.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Bicycle Crunches';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Leg Raises', 'Lower ab focused exercise', 'Lie on your back with legs straight and hands under your hips for support. Lift legs together until perpendicular to the floor, then lower them slowly without touching the ground.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Leg Raises';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Russian Twists', 'Rotational core exercise', 'Sit on the floor with knees bent and feet slightly elevated. Lean back slightly, keeping back straight. Rotate your torso side to side, touching the floor on each side.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Russian Twists';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Windshield Wipers', 'Advanced rotational core exercise', 'Hang from a pull-up bar and raise legs to the bar. Rotate legs from side to side in a controlled sweeping motion, like windshield wipers. Keep the movement controlled.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Windshield Wipers';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Crunches', 'Basic ab isolation exercise', 'Lie on your back with knees bent and feet flat. Place hands behind your head or across your chest. Curl your shoulders off the floor by contracting your abs. Lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Crunches';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Knee Raises', 'Hanging knee raise for lower abs', 'Hang from a pull-up bar with arms extended. Raise knees toward your chest by contracting your abs. Lower legs with control to the starting position.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary')) as m(name, role)
where e.name = 'Knee Raises';

-- ============================================================
-- COMPOUND exercises
-- ============================================================

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Burpees', 'Full-body explosive compound exercise', 'From standing, drop into a squat and place hands on the floor. Jump feet back into a push-up position. Perform a push-up, jump feet forward to hands, then jump up with arms overhead.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Chest', 'primary'), ('Quads', 'primary'), ('Abs', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Burpees';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Muscle-Ups', 'Advanced compound pulling and pushing movement', 'Hang from a pull-up bar. Perform an explosive pull-up, transitioning at the top so your chest is above the bar. Press up to full arm extension above the bar. Lower with control.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Pull-Up Bar'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Lats', 'primary'), ('Chest', 'primary'), ('Triceps', 'secondary'), ('Upper Back', 'secondary')) as m(name, role)
where e.name = 'Muscle-Ups';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Bear Crawl', 'Full-body crawling movement', 'Start on all fours with knees hovering just above the ground. Move forward by stepping opposite hand and foot simultaneously. Keep hips low and core engaged throughout.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Quads', 'secondary'), ('Front Delts', 'secondary')) as m(name, role)
where e.name = 'Bear Crawl';

with ex as (
  insert into public.exercises (name, description, instructions, is_custom) values
  ('Inchworms', 'Full-body mobility and strength exercise', 'From standing, bend at the waist and walk your hands out to a push-up position. Optionally perform a push-up. Walk hands back toward feet and stand up. Repeat.', false)
  returning id
)
insert into public.exercise_equipment (exercise_id, equipment_id) values
  ((select id from ex), get_equipment_id('Bodyweight Only'));
insert into public.exercise_muscles (exercise_id, muscle_id, role)
select e.id, get_muscle_id(m.name), m.role from public.exercises e,
  (values ('Abs', 'primary'), ('Chest', 'secondary'), ('Hamstrings', 'secondary')) as m(name, role)
where e.name = 'Inchworms';

-- Drop helper functions (used only for seeding)
drop function get_equipment_id;
drop function get_muscle_id;
