-- ============================================================
-- ExRx Exercise Data Seed Migration
-- Generated: 2026-03-11T21:10:44.155Z
-- Muscles: 65, Equipment: 15, Exercises: 512
-- ============================================================

BEGIN;

-- Clear existing seed data (preserve custom user data)
DELETE FROM public.exercise_muscles WHERE exercise_id IN (SELECT id FROM public.exercises WHERE is_custom = false);
DELETE FROM public.exercise_equipment WHERE exercise_id IN (SELECT id FROM public.exercises WHERE is_custom = false);
DELETE FROM public.exercises WHERE is_custom = false;
DELETE FROM public.muscles;
DELETE FROM public.equipment WHERE is_custom = false;

-- ── Muscles ──────────────────────────────────────────────────
INSERT INTO public.muscles (name, muscle_group) VALUES
  ('Adductor Brevis', 'Adductors'),
  ('Adductor Longus', 'Adductors'),
  ('Adductor Magnus', 'Adductors'),
  ('Adductors, Hip', 'Adductors'),
  ('Biceps Brachii', 'Biceps'),
  ('Biceps Brachii, Short Head', 'Biceps'),
  ('Brachialis', 'Biceps'),
  ('Brachioradialis', 'Biceps'),
  ('Coracobrachialis', 'Biceps'),
  ('Deltoid, Anterior', 'Shoulders'),
  ('Deltoid, Lateral', 'Shoulders'),
  ('Deltoid, Posterior', 'Shoulders'),
  ('Erector Spinae', 'Back'),
  ('Erector Spinae, Cervicis & Capitis Fibers', 'Back'),
  ('Extensor Carpi Radialis', 'Forearms'),
  ('Extensor Carpi Ulnaris', 'Forearms'),
  ('Flexor Carpi Radialis', 'Forearms'),
  ('Flexor Carpi Ulnaris', 'Forearms'),
  ('Gastrocnemius', 'Calves'),
  ('Gluteus Maximus', 'Glutes'),
  ('Gluteus Maximus, Lower Fibers', 'Glutes'),
  ('Gluteus Medius', 'Glutes'),
  ('Gluteus Minimus', 'Glutes'),
  ('Gracilis', 'Adductors'),
  ('Hamstrings', 'Hamstrings'),
  ('Hip External Rotators', 'Hip Rotators'),
  ('Iliocostalis Lumborum', 'Back'),
  ('Iliocostalis Thoracis', 'Back'),
  ('Iliopsoas', 'Hip Flexors'),
  ('Infraspinatus', 'Shoulders'),
  ('Latissimus Dorsi', 'Back'),
  ('Levator Scapulae', 'Trapezius'),
  ('Obliques', 'Core'),
  ('Pectineus', 'Hip Flexors'),
  ('Pectoralis Major', 'Chest'),
  ('Pectoralis Major, Clavicular', 'Chest'),
  ('Pectoralis Major, Sternal', 'Chest'),
  ('Pectoralis Minor', 'Chest'),
  ('Piriformis', 'Hip Rotators'),
  ('Psoas Major', 'Hip Flexors'),
  ('Quadratus Lumborum', 'Core'),
  ('Quadriceps', 'Quadriceps'),
  ('Rectus Abdominis', 'Core'),
  ('Rectus Femoris', 'Quadriceps'),
  ('Rhomboids', 'Back'),
  ('Sartorius', 'Hip Flexors'),
  ('Serratus Anterior', 'Core'),
  ('Serratus Anterior, Inferior Digitations', 'Core'),
  ('Soleus', 'Calves'),
  ('Splenius', 'Neck'),
  ('Sternocleidomastoid', 'Neck'),
  ('Subscapularis', 'Shoulders'),
  ('Supraspinatus', 'Shoulders'),
  ('Tensor Fasciae Latae', 'Hip Flexors'),
  ('Teres Major', 'Back'),
  ('Teres Minor', 'Shoulders'),
  ('Tibialis Anterior', 'Calves'),
  ('Transverse Abdominis', 'Core'),
  ('Trapezius, Lower', 'Trapezius'),
  ('Trapezius, Middle', 'Trapezius'),
  ('Trapezius, Upper', 'Trapezius'),
  ('Triceps Brachii', 'Triceps'),
  ('Triceps Brachii, Long Head', 'Triceps'),
  ('Wrist Extensors', 'Forearms'),
  ('Wrist Flexors', 'Forearms');

-- ── Equipment ────────────────────────────────────────────────
INSERT INTO public.equipment (name, is_custom) VALUES
  ('Assisted', false),
  ('Band Resistive', false),
  ('Barbell', false),
  ('Bodyweight', false),
  ('Cable', false),
  ('Dumbbell', false),
  ('Isometric', false),
  ('Lever (plate loaded)', false),
  ('Lever (selectorized)', false),
  ('Self-assisted', false),
  ('Sled', false),
  ('Smith', false),
  ('Stretch', false),
  ('Suspended', false),
  ('Weighted', false);

-- Helper functions for lookups
CREATE OR REPLACE FUNCTION pg_temp.get_eq(eq_name text) RETURNS uuid AS $$
  SELECT id FROM public.equipment WHERE name = eq_name AND is_custom = false LIMIT 1;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION pg_temp.get_mu(m_name text) RETURNS uuid AS $$
  SELECT id FROM public.muscles WHERE name = m_name LIMIT 1;
$$ LANGUAGE sql STABLE;

-- ── Exercises ────────────────────────────────────────────────

-- Barbell Bent-over Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Bent-over Row', 'Bend knees slightly and bend over bar with back straight. Grasp bar with wide overhand grip.', 'Pull bar to upper waist. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BBBentOverRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Bent-over Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Underhand Bent-over Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Underhand Bent-over Row', 'Bend knees slightly and bend over bar with back straight. Grasp bar with underhand grip.', 'Pull bar to waist. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BBUnderhandBentOverRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Underhand Bent-over Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Bent-over Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Bent-over Row', 'Grasp cable stirrup. Step back away from pulley, with foot on same side as exercising arm, positioned out to side well behind forward foot. Bend over with hand on nearby bar or above knee for support. Keep back straight and knees slightly bent. Allow shoulder with stirrup to be pulled forward.', 'Pull cable attachment to side of torso, pulling shoulder back. Return until arm is extended and shoulder is stretched forward. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/BackGeneral/CBOneArmBentoverRow', 'Back', 'compound', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Obliques', 'stabilizer'), ('Psoas Major', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Iliocostalis Lumborum', 'stabilizer'), ('Iliocostalis Thoracis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Bent-over Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Straight Back Seated High Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Straight Back Seated High Row', 'Sit on seat or bench. Bend forward and grasp cable stirrup with one hand. Position torso upright allowing shoulder to be pulled forward under weight on cable.', 'Pull cable attachment to side of torso while pulling shoulder back, arching spine, and pushing chest forward. Return until arm is extended and shoulder is pulled forward. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/BackGeneral/CBOneArmStrBackHighRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Straight Back Seated High Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Seated Row', 'Sit slightly forward on seat or bench in order to grasp cable attachment. Place feet on vertical platform. Slide hips back positioning knees with slight bend.', 'Pull cable attachment to waist while straightening lower back. Pull shoulders back and push chest forward while arching back. Return until arms are extended, shoulders are stretched forward, and lower back is flexed forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/CBSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Straight Back Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Straight Back Seated Row', 'Sit slightly forward on bench with feet on foot bar or vertical platform. Grasp close grip cable attachment. Straighten torso upright and slide hips back so knees are slightly bent.', 'Pull cable attachment to waist. Pull shoulders back and lift chest by arching back. Return until arms are extended, back is straight, and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/CBStraightBackSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Straight Back Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Wide Grip Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Wide Grip Seated Row', 'Sit slightly forward on platform in order to grasp cable attachment with wider than shoulder width grip. Place feet on vertical platform and slide hips back positioning knees with slight bend.', 'Pull cable attachment to waist while pulling torso upright. Pull shoulders back and push chest forward while arching back. Return until arms are extended, shoulders are stretched forward, and lower back is flexed forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/CBWideGripSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'secondary'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Wide Grip Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Wide Grip Straight Back Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Wide Grip Straight Back Seated Row', 'Sit slightly forward on bench or platform in order to grasp cable bar attachment with wider than shoulder width overhand grip. Place feet on vertical platform. With torso upright, slide hips back positioning knees with slight bend.', 'Pull cable attachment to waist. Pull shoulders back and lift chest by arching back. Return until arms are extended, back is straight, and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/CBWideGripStrBackSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Wide Grip Straight Back Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Bent-over Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Bent-over Row', 'Kneel over side of bench by placing knee and hand of supporting arm on bench. Position foot of opposite leg slightly back to side. Grasp dumbbell from floor.', 'Pull dumbbell to up to side until it makes contact with ribs or until upper arm is just beyond horizontal. Return until arm is extended and shoulder is stretched downward. Repeat and continue with opposite arm.', 'https://exrx.net/WeightExercises/BackGeneral/DBBentOverRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;

-- Dumbbell Lying Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lying Row', 'Lie chest down on elevated bench. Grasp dumbbells below.', 'Pull dumbbells up to sides. Arch thoracic spine, pull shoulder blades back, and continue to pull until upper arms are just beyond height of back. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/DBLyingRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Dumbbell Lying Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Neutral Grip Incline Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Neutral Grip Incline Row (plate loaded)', 'Lie prone on inclined platform and place feet on foot rest. Grasp angled handles and lift lever out of support rack. Position lever directly under body with arms extended down.', 'Pull lever up. As lever approaches, hyperextend thoracic spine and squeeze shoulders back. Lower lever until arms are extended and shoulders are pulled downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVNeutralGripInclineRowPL', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Neutral Grip Incline Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Wide Grip Incline Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Wide Grip Incline Row (plate loaded)', 'Lie prone on inclined platform and place feet on foot rest. Grasp wide handles and lift lever out of support rack. Position lever directly under body with arms extended down.', 'Pull lever up. As lever approaches, hyperextend thoracic spine and squeeze shoulders back. Lower lever until arms are extended and shoulders are pulled downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVWideGripInclineRowPL', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Wide Grip Incline Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Wide Grip Seated Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Wide Grip Seated Row (plate loaded)', 'Sit on seat and position chest against pad. Grasp lever handles with underhand grip.', 'Pull levers back until elbows are behind back and shoulders are pulled back. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVWideLowGripSeatedRowH', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Wide Grip Seated Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever T-bar Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever T-bar Row (plate loaded)', 'Bend knees slightly and bend over lever handles with back straight. Grasp lever handles with shoulder width to wide overhand grip.', 'Pull lever up to torso. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVTBarRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever T-bar Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Close Grip T-bar Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Close Grip T-bar Row (plate loaded)', 'Bend knees slightly and bend over lever handles with back straight. Grasp narrow grip parallel lever handles.', 'Pull handles up to waist. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVCloseGripTBarRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Close Grip T-bar Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Row', 'Sit on seat and position chest against pad. Push foot lever if available. Grasp narrower parallel grip handles.', 'Pull lever back until elbows are behind back and shoulders are pulled back. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Wide Grip Seated Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Wide Grip Seated Row', 'Sit on seat and position chest against pad. Grasp outer lever handles with overhand grip.', 'Pull lever back until elbows are behind back and shoulders are pulled back. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVWideGripSeatedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Wide Grip Seated Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Row (no chest pad)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Row (no chest pad)', 'Sit on seat and grasp handles with each hand. Place feet on vertically angled platform. Slide hips back with knees slightly bent.', 'Pull handles to waist while straightening torso upright. Pull shoulders back and push chest forward while arching back. Return until arms are extended, shoulders are stretched forward, and lower back is flexed forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVSeatedRowNoPad', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Row (no chest pad)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Straight Back Seated Row (no chest pad)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Straight Back Seated Row (no chest pad)', 'Sit on seat with feet positioned on foot bar or platform. Grasp handles with each hand. Position torso upright with knees bent slightly.', 'Pull handles to body. Pull shoulders back and lift chest by arching back. Return until arms are extended, back is straight, and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/LVStraightBackSeatedRowNoPad', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Straight Back Seated Row (no chest pad)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Bent-over Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Bent-over Row', 'Bend knees slightly and bend over bar with back straight. Grasp bar with wide overhand grip. Disengage bar by rotating bar back.', 'Pull bar to upper waist. Return until arms are extended and shoulders are stretched downward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/SMBentOverRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Bent-over Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Inverted Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Inverted Row', 'Lay on back under fixed horizontal bar. Grasp bar with wide overhand grip. Place back of heels on elevated surface.', 'Keeping body straight, pull body up to bar. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/WTSupineRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Inverted Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Inverted Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Inverted Row', 'Lay on back under fixed horizontal bar. Grasp bar with wide overhand grip.', 'Keeping body straight, pull body up to bar. Pull shoulders back at top of movement with chest high. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BWSupineRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Inverted Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Inverted Row (feet elevated)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Inverted Row (feet elevated)', 'Lay on back under fixed horizontal bar. Grasp bar with wide overhand grip. Place back of heels on elevated surface.', 'Keeping body straight, pull body up to bar. Pull shoulders back at top of movement with chest high. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BWSupineRowFeetElevated', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Inverted Row (feet elevated)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Row (high bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Row (high bar)', 'Stand facing arms length away from waist to head height horizontal bar. Grasp bar with wide overhand grip. Position body under bar with legs, hips and spine straight. Arms should be straight, approximately perpendicular to body. Heels should make contact with floor.', 'Keeping body straight, pull body up to bar. Pull shoulders back at top of movement with chest high. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BWSupineRowHigh', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Row (high bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Inverted Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Inverted Row', 'Position suspension handles higher than arms'' length above floor. Sit on floor and grasp handles. Position body supine hanging from handles with arms straight, shoulders under handles, body straight, and back of heels on floor.', 'Pull body up so sides of chest make contact with handles while keeping body straight. Pull shoulders back at top of movement with chest high. Return until arms are extended straight and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/STInvertedRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Inverted Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Row', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body reclines back behind suspension handles. Position body and legs straight at desired angle, hanging from handles with arms straight.', 'Pull body up so sides of chest make contact with handles while keeping body and legs straight. Pull shoulders back at top of movement with chest high. Return until arms are extended straight and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/STRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended One Arm Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended One Arm Row', 'Grasp suspension handle and momentarily step back until arm is extended forward and straight. While keeping arm straight and shoulder back, step forward so body reclines back behind suspension handles. Position body and legs straight at desired angle, hanging from handle with arm straight. Place resting arm straight against side or front of thigh.', 'Pull body up so side of chest makes contact with handle while keeping body and legs straight. Return until arm is extended straight and shoulder is stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/STOneArmRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended One Arm Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Fixed Bar Back Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Fixed Bar Back Stretch', 'Stand facing stationary bar. Grasp stationary bar with one hand approximately waist height.', 'Bend over allowing hips to fall back. Slightly lean torso toward stretched arm. Hold stretch. Repeat with opposite side.', 'https://exrx.net/Stretches/BackGeneral/FixedBar', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Lever Back Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Back Stretch', 'Sit on seat in forward position with lower legs on shin pad, feet on foot rest. Place hands through wrist straps. Hold upper bar with arms crossed, overhand grip.', 'Push and lower seat back. Hold stretch. Repeat with opposite arm position.', 'https://exrx.net/Stretches/BackGeneral/PCCrossHand', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Inverted Biceps Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Inverted Biceps Row', 'Lay on back under fixed horizontal bar. Grasp bar with shoulder width underhand grip.', 'Keeping body straight, pull body up to bar. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/BackGeneral/BWUnderhandSupineRow', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Inverted Biceps Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Chin-up', 'Step up and grasp bar with underhand shoulder width grip. Kneel onto platform or step onto bar.', 'Pull body up until elbows are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsUnderhandChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Machine-assisted Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Pull-up (open-centered bar, standing)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Pull-up (open-centered bar, standing)', 'Step up and grasp bar with wide overhand grip. Step down onto assistance lever or platform.', 'Pull body up until neck reaches height of hands. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsPullupOpen', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Coracobrachialis', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Machine-assisted Pull-up (open-centered bar, standing)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Parallel Close Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Parallel Close Grip Pull-up', 'Step up and grasp parallel grips. Kneel on padded platform and lower body down with arm extended.', 'Pull body up until elbows are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsCloseGripChinupKneeling', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Machine-assisted Parallel Close Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Pullover
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Pullover', 'Lie upper back perpendicular on bench. Flex hips slightly. Grasp barbell from behind and position over chest with elbows bent slightly.', 'With elbows bent slightly, lower bar over and beyond head until shoulders are fully flexed or upper arms are approximately parallel to torso. Return and repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BBPullover', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Pullover' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Bent-over Pullover
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Bent-over Pullover', 'Face high pulley and grasp revolving cable attachment with arm slightly bent. Place one foot slightly back and bend over at hip until shoulder is fully flexed (upper arms at sides of head).', 'With elbows fixed approximately 30°, pull cable attachment down until upper arms are to sides. Return attachment overhead. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBBentoverPullover', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Bent-over Pullover' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Pulldown', 'Grasp cable bar with wide grip. Sit with thighs under supports.', 'Pull down cable bar to upper chest. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBFrontPulldown', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Parallel Grip Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Parallel Grip Pulldown', 'Grasp parallel cable attachment. Sit with thighs under supports.', 'Pull down cable attachment to upper chest. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBParallelGripPulldown', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Parallel Grip Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Chin-up', 'Place dip belt around waist. Kneel close to low pulley or lever and attach hook to dip belt chains. Step up and grasp bars with shoulder width underhand grip. Lift legs off of steps or floor.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBUnderhandChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Parallel Close Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Parallel Close Grip Pull-up', 'Place dip belt around waist. Kneel as close as possible to low pulley or lever and attach hook to dip belt in front between legs. Step up and grasp close grip p arallel bars with hands facing inward. Lift legs off of steps or floor.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBParallelCloseGripChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Parallel Close Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Parallel Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Parallel Grip Pull-up', 'Place dip belt around waist. Kneel as close as possible to low pulley or lever and attach hook to dip belt in front between legs. Step up and grasp parallel bars with hands facing inward. Lift legs off of steps or floor.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBParallelGripChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Parallel Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Pull-up', 'Place dip belt around waist. Kneel close to low pulley or lever and attach hook to dip belt. Step up and grasp bars with overhand wide grip. Lift legs off of steps or floor.', 'Pull body up until chin is above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Underhand Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Underhand Pulldown', 'Grasp cable bar with underhand grip. Sit with thighs under supports.', 'Pull down cable bar to upper chest until elbows are to sides. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/CBUnderhandPulldown', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Underhand Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Close Grip Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Close Grip Pulldown', 'Grasp parallel lever bars. Sit with thighs under supports.', 'Pull down handles to sides of chest while leaning back slightly. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/LVCloseGripPulldown', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Close Grip Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Front Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Front Pulldown', 'Grasp lever handles. Sit with thighs under supports.', 'Pull down lever to upper chest. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/LVFrontPulldown', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Front Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Pullover
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Pullover', 'Adjust seat height so lever is near shoulder axis. Sit on machine and push foot lever. Place elbows on pads and grasp bar from behind. Release foot lever and place feet on platform or to sides.', 'Pull lever forward and down until elbows are to sides. Return until shoulders are fully flexed, or upper arms are parallel to torso. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/LVPullover', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Pullover' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Chin-up', 'Step up and grasp bar with underhand shoulder width grip.', 'Pull body up until elbows are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/WtUnderhandChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Coracobrachialis', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Parallel Close Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Parallel Close Grip Pull-up', 'Step up and grasp close grip parallel bars.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/WtCloseGripChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Parallel Close Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Pull-up', 'Step up and grasp bar with overhand wide grip.', 'Pull body up until chin is above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/WtPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Archer Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Archer Pull-up', 'Loop either one band on center of bar as shown or two bands on each side of bar. Grab each side of hanging exercise band with both hands. Stretch exercise band down and step onto bottom inside of band with one foot. Stretch band down further by extending leg straight down. If second band is used, pull down and step into the other band. Reach up and grasp bar with overhand wide grip while keeping banded leg(s) straight.', 'Pull body up to one side while keeping far arm extended or only slightly bent. Point elbow forward and downward while pulling body toward pulling hand. As chin approaches and rises above pulling hand, position extended arm by pointing elbow back while extending hand over top of bar. Lower body by extending bent arm while keeping extended arm straight and reestablishing grip on bar. When hanging from bar with both arms extended, repeat movement to opposite side. Continue alternating movement between sides.', 'https://exrx.net/WeightExercises/LatissimusDorsi/ASArcherPullupBand', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Band-assisted Archer Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Chin-up', 'Grab each side of hanging exercise band with both hands. Stretch exercise band down and step onto bottom inside of band with one foot. Stretch band down further by extending leg straight down. Reach up and grasp bar with underhand shoulder width grip while keeping banded leg straight.', 'Pull body up until elbows are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/ASChinupBand', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Band-assisted Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Pull-up', 'Grab each side of hanging exercise band with both hands. Stretch exercise band down and step onto bottom inside of band with one foot. Stretch band down further by extending leg straight down. Reach up and grasp bar with overhand wide grip while keeping banded leg straight.', 'Pull body up until chin is above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/ASPullupBand', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Band-assisted Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Parallel Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Parallel Grip Pull-up', 'Grab each side of hanging exercise band with both hands. Stretch exercise band down and step onto bottom inside of band with one foot. Stretch band down further by extending leg straight down. Reach up and grasp parallel bars while keeping banded leg straight.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/ASParallelGripPullupBand', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Coracobrachialis', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Band-assisted Parallel Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Archer Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Archer Pull-up', 'Step up and grasp bar with overhand wide grip.', 'Pull body up to one side while keeping far arm extended or only slightly bent. Point elbow forward and downward while pulling body toward pulling hand. As chin approaches and rises above pulling hand, position extended arm by pointing elbow back while extending hand over top of bar. Lower body by extending bent arm while keeping extended arm straight and reestablishing grip on bar. When hanging from bar with both arms extended, repeat movement to opposite side. Continue alternating movement between sides.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BWArcherPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Triceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Archer Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Chin-up', 'Step up and grasp bar with underhand shoulder width grip.', 'Pull body up until elbows are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BWUnderhandChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- One Arm Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('One Arm Pull-up', 'Stand under bar with shoulder positioned 45° relative to bar angled toward working arm. Grasp bar with one hand using overhand shoulder width grip. Place other arm to side.', 'Pull body up while turning shoulders inward perpendicular to bar. Elbow travels forward then down to navel while head is raised above bar on same side of bar as working arm. Near top of pull, shoulder of resting arm is pulled toward bar. Lower body until arm is fully extended in original starting position. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BWOneArmPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'One Arm Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Parallel Close Grip Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Parallel Close Grip Pull-up', 'Step up and grasp parallel bars.', 'Pull body up until elbow are to sides. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BWCloseGripChinup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Parallel Close Grip Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Pull-up', 'Step up and grasp bar with overhand wide grip.', 'Pull body up until chin is above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/BWPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Partner-assisted Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Partner-assisted Chin-up', 'Step up and grasp bar with underhand shoulder width grip. Bend knees so partner can assist from behind.', 'Pull body up until elbows are to sides or chin is just above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsUnderhandChinupPartner', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Partner-assisted Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Partner-assisted Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Partner-assisted Pull-up', 'Step up and grasp bar with wide overhand grip. Bend knees so partner can assist from behind.', 'Pull body up until chin is just above bar. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsChinupPartner', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Partner-assisted Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Self-assisted Chin-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Self-assisted Chin-up', 'Stand facing fixed horizontal bar at neck height. Grasp bar with underhand grip shoulder width. Position feet forward on floor, slightly in front of bar.', 'Lower body under bar until arms and shoulders are fully extended. If necessary, use minimal assistance of lower body to control descent, allowing knees and hips to bend, keeping flat on floor. Pull body up until elbows are to sides, again with minimal assistance from lower body. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsUnderhandChinupSelf', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Self-assisted') FROM ex WHERE pg_temp.get_eq('Self-assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Self-assisted Chin-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Self-assisted Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Self-assisted Pull-up', 'Stand facing fixed horizontal bar at neck height. Grasp bar with wide overhand grip. Position feet forward on floor, slightly in front of bar.', 'Lower body under bar until arms and shoulders are fully extended. If necessary, use minimal assistance of lower body to control descent, allowing knees and hips to bend, keeping flat on floor. Pull body up until chin is just above bar, again with minimal assistance from legs. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/AsChinupSelf', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Self-assisted') FROM ex WHERE pg_temp.get_eq('Self-assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Self-assisted Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Pull-up', 'Grasp high suspension handles.', 'Pull body up until neck reaches height of hands. Lower body until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/STPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Coracobrachialis', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Suspended Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Self-assisted Pull-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Self-assisted Pull-up', 'Stand facing suspension handles placed at neck height. Grasp handles and position feet forward on floor, slightly in front of handles.', 'Lower body under handles until arms and shoulders are fully extended. If necessary, use minimal assistance of lower body to control descent, allowing knees and hips to bend, keeping flat on floor. Pull body up until chin is just above handles, again with minimal assistance from legs. Repeat.', 'https://exrx.net/WeightExercises/LatissimusDorsi/STSelfAssistedPullup', 'Back', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Pectoralis Minor', 'secondary')) AS m(name, role)
WHERE e.name = 'Suspended Self-assisted Pull-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Premium Content
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Premium Content', NULL, NULL, 'https://exrx.net/WeightExercises/HipFlexors/BWKneelingWheelRollout', 'Back', NULL, NULL, NULL, 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Premium Content' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Bar Lat Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Bar Lat Stretch', 'Standing distance facing bar approximately lower chest height. Grasp bar with both hands. Lean body forward so bar is behind/under bar and arms are to sides of head. Feet are keep away from bar.', 'Allow upper body to hang downward while keeping arms to sides of head. Hold stretch.', 'https://exrx.net/Stretches/LatissimusDorsi/Bar', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Bar Lat Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lat Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lat Stretch', 'Sit on seat in forward position with lower legs on shin pad, feet on foot rest. Place hands through wrist straps. Hold upper bar with underhand grip.', 'Push and lower seat back. Hold stretch.', 'https://exrx.net/Stretches/LatissimusDorsi/PCUnderhand', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Lat Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Overhead Lat Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Overhead Lat Stretch', 'Put one arm overhead. Grasp elbow or wrist overhead with other hand.', 'Pull elbow toward head and back or pull arm down toward opposite shoulder. Lean torso to side, away from direction of arm behind head. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/LatissimusDorsi/Overhead', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Overhead Lat Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Standing Side Reach Lat Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Standing Side Reach Lat Stretch', 'Stand with feet far apart. Place one arm on side of thigh. Put opposite arm overhead.', 'Lean and reach to side away from raised arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/LatissimusDorsi/StandingSideReach', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Standing Side Reach Lat Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Supine Lat Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Supine Lat Stretch', 'Lie supine on mat or floor. Position arms parallel to body pointing opposite direction of legs.', 'Pull arms toward floor and back sides of head. Hold stretch.', 'https://exrx.net/Stretches/LatissimusDorsi/Supine', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary')) AS m(name, role)
WHERE e.name = 'Supine Lat Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Shrug', 'Stand holding barbell with overhand or mixed grip; shoulder width or slightly wider.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/BBShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Trap Bar Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Trap Bar Shrug', 'Step into trap barbell and stand holding handles of trap bar to sides.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/TBShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Trap Bar Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Shrug', 'Stand facing low pulley and grasp cable bar with shoulder width or slightly wider overhand grip. Stand close to pulley.', 'With arms straight, elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/CBShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Shrug', 'Stand between two low pulleys and grasp stirrups to each side. Stand upright with arms straight down to each side.', 'With arms straight, elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/CBShrugStirrups', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Shrug', 'Stand holding dumbbells to sides.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/DBShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Shrug (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Shrug (plate loaded)', 'Sit on bench and grasp lower handles to each side. Sit upright.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/LVSeatedShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Shrug (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shrug (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shrug (plate loaded)', 'Stand between lever handles to sides. Squat down with feet flat on floor and grasp upper handles to sides. Stand upright by extending hips and knees to full extension.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/LVShrugH', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shrug (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shrug', 'Stand holding lever bar with shoulder width overhand or mixed grip.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/LVShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Gripless Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Gripless Shrug', 'Stand with shoulders under padded bar.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/SLXGripShrug', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Gripless Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Shrug', 'Stand grasping smith bar with shoulder width or slightly wider overhand grip. Disengage bar by rotating bar back.', 'Elevate shoulders as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/SMShrug', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Inverted Shrug (on parallel bars)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Inverted Shrug (on parallel bars)', 'Stand between parallel bars. Squat down and grasp parallel bars from above. Kick legs up inverting and balancing body upside down. Legs can be kept bent or straight, positioned vertically.', 'Raise body up a high as possible by pulling shoulders toward ears. Lower body to original position and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/BWInvertedShrugPB', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary')) AS m(name, role)
WHERE e.name = 'Inverted Shrug (on parallel bars)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Inverted Shrug
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Inverted Shrug', 'Grasp gymnastics rings, one in each hand. Sit on mat between parallel bars. Kick legs up inverting and balancing body upside down.', 'Raise body up a high as possible by pulling shoulders toward ears. Lower body to original position and repeat.', 'https://exrx.net/WeightExercises/TrapeziusUpper/BWInvertedShrugRings', 'Back', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary'), ('Trapezius, Middle', 'secondary'), ('Levator Scapulae', 'secondary')) AS m(name, role)
WHERE e.name = 'Suspended Inverted Shrug' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Upper Trapezius Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Upper Trapezius Stretch', 'Grasp wrist or hand from behind and pull arm to opposite side.', 'Tilt head away from lowered shoulder by positioning ear toward front of opposite shoulder. Hold stretch. Repeat to other side.', 'https://exrx.net/Stretches/TrapeziusUpper/Trap', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Trapezius, Upper', 'primary')) AS m(name, role)
WHERE e.name = 'Upper Trapezius Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Fixed Bar Rhomboids Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Fixed Bar Rhomboids Stretch', 'Stand facing very close to stationary bar. Grasp stationary bar with both hands just below chest height.', 'Lean back allowing body and hips to fall back and shoulders to be pulled forward. Hold stretch.', 'https://exrx.net/Stretches/Rhomboids/FixedBar', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rhomboids', 'primary')) AS m(name, role)
WHERE e.name = 'Fixed Bar Rhomboids Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Hugging Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Hugging Stretch', 'Cross both arms and place both hands behind shoulders of opposite arms.', 'Bring elbows closer together in front of body. Raise elbows slightly and hold stretch.', 'https://exrx.net/Stretches/Rhomboids/Hugging', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rhomboids', 'primary')) AS m(name, role)
WHERE e.name = 'Hugging Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Standing Shoulder External Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Standing Shoulder External Rotation', 'Stand with side to elbow height cable pulley. Grasp stirrup attachment with far arm. Position elbow against side and forearm across belly.', 'Pull cable attachment away from body as far as possible by externally rotating shoulder. Return and repeat. Turn around and continue with opposite arm.', 'https://exrx.net/WeightExercises/Infraspinatus/CBStandingExternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary'), ('Teres Minor', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Standing Shoulder External Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lying Shoulder External Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lying Shoulder External Rotation', 'Lie on side with legs separated for support. Grasp dumbbell and position elbow against side and forearm across belly.', 'Lift dumbbell by rotating shoulder. Return and repeat. Flip over and continue with opposite arm.', 'https://exrx.net/WeightExercises/Infraspinatus/DBLyingExternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary'), ('Teres Minor', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lying Shoulder External Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Upright Shoulder External Rotation (with support)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Upright Shoulder External Rotation (with support)', 'Stand or sit with side against chest height platform. With dumbbell in hand, position upper arm horizontally on platform, elbow bent so forearm is upright.', 'Lower dumbbell forward by rotating shoulder. Return and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Infraspinatus/DBUprightExternalRotationSupport', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Teres Minor', 'primary'), ('Infraspinatus', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Upright Shoulder External Rotation (with support)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shoulder External Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shoulder External Rotation', 'Place elbow on forearm pad and grasp handle with upper arm to side of body and forearm against body.', 'Pull lever away from body. Return and repeat. Adjust lever to opposite side and repeat with other arm.', 'https://exrx.net/WeightExercises/Infraspinatus/LVExternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary'), ('Teres Minor', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Trapezius, Lower', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shoulder External Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Broom Stick Infraspinatus Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Broom Stick Infraspinatus Stretch', 'Grasp pole at one end and position overhead with other end of pole behind opposite arm. Grasp other end of pole with hand positioned below elbow. Position elbow of lower arm close to height of shoulder.', 'Pull upper end of pole forward so shoulder is internally rotated. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/Infraspinatus/Broomstick', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary')) AS m(name, role)
WHERE e.name = 'Broom Stick Infraspinatus Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Lying Infraspinatus Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Lying Infraspinatus Stretch', 'Lie supine on mat or floor with knees bent approximately 90 degrees. Position hand under side of waist, palm down.', 'Allow legs and hips to fall to side of positioned arm. Hold stretch. Repeat on opposite side.', 'https://exrx.net/Stretches/Infraspinatus/SideLying', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary')) AS m(name, role)
WHERE e.name = 'Side Lying Infraspinatus Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Lying Teres Minor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Lying Teres Minor Stretch', 'Lie down on side on mat or floor. Position arm on floor with bent elbow positioned forward on mat and hand above elbow. With other hand, grasp back of wrist.', 'Keeping elbow bend at a right angle, push forearm downward toward floor. Hold stretch. Repeat on opposite side.', 'https://exrx.net/Stretches/Infraspinatus/SideLyingTeresMinor', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary')) AS m(name, role)
WHERE e.name = 'Side Lying Teres Minor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Shoulder External Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Shoulder External Rotation', 'Grasp suspension handles and position bent elbows to each sides of waist.

Step back until suspension straps are taut. While keeping bent elbows to side, step forward slightly so body reclines back behind suspension handles.', 'Pull handles apart from each side, while keeping fixed elbow position and body and legs straight throughout movement. Raise forward so handles are to each side of body. Return back until handles come back together in front of body. Repeat.', 'https://exrx.net/WeightExercises/Infraspinatus/STShoulderExternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Infraspinatus', 'primary'), ('Teres Minor', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Wrist Extensors', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Shoulder External Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Standing Shoulder Internal Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Standing Shoulder Internal Rotation', 'Stand with side to elbow height cable pulley. Grasp cable stirrup with near arm. Position elbow against side with elbow bent approximately 90°.', 'Pull cable stirrup toward body by internally rotating shoulder until forearm is across belly. Return and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Subscapularis/CBStandingInternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Subscapularis', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Pectoralis Minor', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Standing Shoulder Internal Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Shoulder Internal Rotation (on floor)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Shoulder Internal Rotation (on floor)', 'Hold dumbbell in one hand. Lie on mat with dumbbell in hand. Position upper arm on mat close to body. Bend elbow approximately 90° with dumbbell held upright above elbow.', 'Maintaining 90° bend in elbow, lower dumbbell toward floor until slight stretch is felt in shoulder. Lift dumbbell toward body by internally rotating shoulder until forearm is vertical and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Subscapularis/DBInternalRotationFloor', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Subscapularis', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Shoulder Internal Rotation (on floor)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shoulder Internal Rotation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shoulder Internal Rotation', 'Place elbow on forearm pad and grasp handle with upper arm to side of body and forearm away from body.', 'Pull lever toward from body. Return and repeat. Adjust lever to opposite side and repeat with other arm.', 'https://exrx.net/WeightExercises/Subscapularis/LVInternalRotation', 'Back', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Subscapularis', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shoulder Internal Rotation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Broom Stick Subscapularis Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Broom Stick Subscapularis Stretch', 'Grasp end of pole with one hand. Flip pole over upper arm. Position bent arm to side of body with other end of pole behind arm. Reach across body as far as possible with opposite arm and grasp lower end of pole. Position elbow at height of shoulder with pole positioned on back side of upper arm.', 'Pull lower end of pole forward and upward so shoulder is externally rotated. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/Subscapularis/Broomstick', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Subscapularis', 'primary')) AS m(name, role)
WHERE e.name = 'Broom Stick Subscapularis Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Doorway Subscapularis Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Doorway Subscapularis Stretch', 'Stand at end of wall or in doorway facing perpendicular to wall. Bent elbow and place inside of forearm on surface of wall. Position bent elbow just below height of shoulder. Place far leg forward and near leg back.', 'Bent over at hip while bending knees slightly. Hold stretch . Repeat with opposite arm.', 'https://exrx.net/Stretches/Subscapularis/Doorway', 'Back', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Subscapularis', 'primary')) AS m(name, role)
WHERE e.name = 'Doorway Subscapularis Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Standing Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Standing Leg Calf Raise', 'Set barbell on power rack upper chest height with calf block under barbell. Position back of shoulders under barbell with both hands to sides. Position toes and balls of feet on calf block with arches and heels extending off. Lean barbell against rack and raise from supports by extending knees and hips. Support barbell against verticals with both hands to sides.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/BBStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Barbell Standing Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Belt Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Belt Calf Raise', 'Place cable belt or dip belt around waist. Kneel before low pulley and attach belt to cable. Stand on calf block and grasp support bar for balance. Position toes and balls of feet on calf block with arches and heels extending off.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/CBStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Belt Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Single Leg Calf Raise', 'Stand facing low pulley with platform on floor. Bend over and grasp stirrup attachment with one hand. Stand on edge of platform and grasp support bar for balance. Position toes and balls of feet on platform with arches and heels extending off. Lift one leg up off of floor.', 'Raise heel by extending ankle as high as possible. Lower heel by bending ankle until calf is stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/CBOneArmSingleLegCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Standing Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Standing Calf Raise', 'Grasp dumbbell in one hand to side. Position toes and balls of feet on calf block with arches and heels extending off. Place hand on support for balance.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/DBStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Standing Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Single Leg Calf Raise', 'Grasp dumbbell in one hand to side. Position toes and balls of feet on calf block with arches and heels extending off. Place hand on support for balance. Lift other leg to rear by bending knee.', 'Raise heel by extending ankle as high as possible. Lower heel by bending ankle until calf is stretched. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Gastrocnemius/DBSingleLegCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever 45° Calf Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever 45° Calf Press (plate loaded)', 'Sit on seat with back on padded support. Place feet on platform. Grasp handles to sides and extend hips and knees. Place toes and balls of feet on lower portion of platform with heels and arches extending off.', 'Push platform by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LV45CalfPress', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever 45° Calf Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Calf Extension (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Calf Extension (plate loaded)', 'Sit on seat and position forefeet on lever platform. Grasp handles to sides and straighten knees.', 'Push lever by extending ankle as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVSeatedCalfExtensionHammer', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Calf Extension (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Standing Calf Raise (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Standing Calf Raise (plate loaded)', 'Place shoulders under padded lever. Position toes and balls of feet on calf block with arches and heels extending off. Grasp handles or sides of padded lever. Stand erect by extending hips and knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVStandingCalfRaisePL', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Standing Calf Raise (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever 45° Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever 45° Calf Raise', 'Sit on machine with low back against padding and grasp handles to sides. Position toes and balls of feet on lower portion of platform or foot bar with arches and heels extending off. Straighten knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LV45CalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever 45° Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Calf Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Calf Extension', 'Sit on seat and position forefeet on horizontal foot bar. Grasp handles to sides and straighten knees.', 'Push lever by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVSeatedCalfExtension', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Calf Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Donkey Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Donkey Calf Raise', 'Position lower back and hips under padded lever. Place forearms on supports. Position toes and balls of feet on calf block with arches and heels extending off. Straighten knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVDonkeyCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Donkey Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Calf Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Calf Press', 'Place seat away from platform. Sit on seat with lower back against back of seat. Place toes and balls of feet on lower portion of platform with heels and arches extending off. Grasp handles to sides and straighten knees.', 'Push lever by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVSeatedCalfPress', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Calf Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Standing Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Standing Calf Raise', 'Place shoulders under padded lever. Position toes and balls of feet on calf block with arches and heels extending off. Grasp handles or sides of padded lever. Stand erect by extending hips and knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/LVStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Standing Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled 45° Calf Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled 45° Calf Press', 'Sit on seat with back on padded support. Place feet on platform. Grasp handles to sides and extend hips and knees. Place toes and balls of feet on lower portion of platform with heels and arches extending off.', 'Push sled by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SL45CalfPress', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Sled 45° Calf Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled 45° Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled 45° Calf Raise', 'Sit on machine with lower back against padding and grasp handles to sides. Position toes and balls of feet on foot platform with arches and heels extending off. Straighten knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SL45CalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Sled 45° Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Donkey Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Donkey Calf Raise', 'Position lower back and hips under upper pad. Place forearms on supports. Position toes and balls of feet on calf block with arches and heels extending off. Straighten knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SLDonkeyCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Donkey Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Lying Calf Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Lying Calf Press', 'Position sled away from platform. Lie supine on sled with shoulders against pad and place feet on platform. Grasp handles to sides and straighten knees. Place toes and balls of feet on lower portion of platform with heels and arches extending off.', 'Push sled away from platform by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SLLyingCalfPress', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Sled Lying Calf Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Seated Calf Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Seated Calf Press', 'Place seat away from platform. Sit on seat and place feet on platform. Grasp handles to sides and extend hips and knees. Place toes and balls of feet on lower portion of platform with heels and arches extending off.', 'Push sled by extending ankles as far as possible. Return by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SLSeatedCalfPress', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Sled Seated Calf Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Standing Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Standing Calf Raise', 'Place shoulders under padded bars. Position toes and balls of feet on calf block with arches and heels extending off. Grasp handles or sides of padded bars. Stand erect by extending hips and knees.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SLStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Standing Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Standing Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Standing Leg Calf Raise', 'Position bar on upper chest height and place calf block under bar. Position back of shoulders under bar and grasp bar to sides. Position toes and balls of feet on calf block with arches and heels extending off. Disengage bar by rotating bar back. Stand erect by extending knees and hips.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/SMStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Standing Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Single Leg Calf Raise', 'Hang weight from dip belt around waist. Position toes and ball of foot on calf block end of platform with heel and arch extending off. Place hand or hands on support for balance. Lift other leg to rear by bending knee.', 'Raise heel by extending ankle as high as possible. Lower heel by bending ankle until calf is stretched. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Gastrocnemius/WTSingleLegCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Standing Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Standing Calf Raise', 'Position toes and balls of feet on calf block with arches and heels extending off. Place hand on support for balance.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Gastrocnemius/BWStandingCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Standing Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Single Leg Calf Raise', 'Position toes and balls of feet on calf block or elevation with heels and arches extending off. Place hand or hands on support for balance. Lift one leg to rear by bending knee.', 'Raise heel by extending ankle as high as possible. Lower heel by bending ankle until calf is stretched. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Gastrocnemius/BWSingleLegCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Self-assisted Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Self-assisted Single Leg Calf Raise', 'Position toes and balls of feet on calf block with heels and arches extending off. Place hands on support for assistance. Lift one leg to rear by bending knee.', 'Raise heel by extending ankle as high as possible, assisting with upper body as little as possible. Lower heel by bending ankle until calf is stretched. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Gastrocnemius/ASSingleLegCalfRaiseSelf', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Self-assisted') FROM ex WHERE pg_temp.get_eq('Self-assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Self-assisted Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Forward Angled Single Leg Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Forward Angled Single Leg Calf Raise', 'Stand facing suspension trainer handles positioned hip to waist high. Grasp handles with overhand grip. Step back so body is angled forward with arms extended approximately perpendicular to body. Feet should be pointed forward. Lift one leg forward by flexing at hip and knee.', 'Raise heel by extending ankle as high as possible. Allow body to travel forward and upward in same direction as body is orientated. Lower heel allowing foot to come back down flat on floor. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Gastrocnemius/STSingleLegForwardAngledCalfRaise', 'Calves', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gastrocnemius', 'primary'), ('Soleus', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer'), ('Hip External Rotators', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Forward Angled Single Leg Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Floor Board Straight Leg Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Floor Board Straight Leg Calf Stretch', 'Face wall with both knees slightly bent. Position fore foot on wall with heel on floor.', 'Straighten knees and lean body toward wall. Hold stretch . Repeat with opposite leg.', 'https://exrx.net/Stretches/Gastrocnemius/FloorBoard', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Pike Straight Leg Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Pike Straight Leg Calf Stretch', NULL, NULL, 'https://exrx.net/Stretches/Gastrocnemius/Bentover', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Step Straight Leg Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Step Straight Leg Calf Stretch', 'Position toes and balls of feet on stair step or calf block with arches and heels extending off. Use railing or wall for balance.', 'With knees straight, shift body weight to one foot. Hold stretch. Repeat with opposite leg.', 'https://exrx.net/Stretches/Gastrocnemius/Step', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Wall Straight Leg Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Straight Leg Calf Stretch', 'Place both hands on wall with arms extended. Lean against wall with one leg bent forward and other leg extended back with knee straight and foot positioned directly forward.', 'Push rear heal to floor and move hips slightly forward. Hold stretch. Repeat with opposite leg.', 'https://exrx.net/Stretches/Gastrocnemius/Wall', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Safety Bar Seated Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Safety Bar Seated Calf Raise', 'Place safety bar on rack approximately lower leg height with calf block slightly rear of safety bar. Sit on bench facing safety bar and place toes on lower portion of platform with heels extending off. Scoot forward to edge of bench and position lower thighs under safety bar. Grasp bar to sides and lift bar from rack by pushing heels up. Slide back to center of bench.', 'Lower heels by bending ankles until calves are stretched. Raise heels by extending ankles as high as possible. Repeat.', 'https://exrx.net/WeightExercises/Soleus/SBSeatedCalfRaise', 'Calves', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Safety Bar Seated Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Calf Raise (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Calf Raise (plate loaded)', 'Sit on seat facing lever. Place forefeet on platform with heels extending off. Position lower thighs under lever pads. Grasp handles if available or place hands on lever pad. Lift lever slightly by pushing heels up. Release support lever.', 'Lower heels by bending ankles until calves are stretched. Raise heels by extending ankles as high as possible. Repeat.', 'https://exrx.net/WeightExercises/Soleus/LVSeatedCalfRaiseH', 'Calves', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Calf Raise (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Calf Raise', 'Sit on seat facing lever. Reach forward and pull hand lever toward body. Place forefeet on platform with heels extending off. Position lower thighs under lever pads. Release hand lever by pushing away from body. Place hands on top of thigh pads.', 'Raise heels by extending ankles as high as possible. Lower heels by bending ankles until calves are stretched. Repeat.', 'https://exrx.net/WeightExercises/Soleus/LVSeatedCalfRaise', 'Calves', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Seated Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Seated Calf Raise', 'Position bar slightly higher than lower leg height. Wrap bar pad around center of bar. Place calf block under bar and bench near bar. Sit on bench facing bar and place toes on lower portion of platform with heels extending off. Grasp bar to sides and extend ankles to raise knees so lower thighs are under padded bar. Push heels further up. Disengage bar by rotating bar back.', 'Lower heels by bending ankles until calves are stretched. Raise heels by extending ankles as high as possible. Repeat.', 'https://exrx.net/WeightExercises/Soleus/SMSeatedCalfRaise', 'Calves', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Seated Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Floor Board Bent Knee Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Floor Board Bent Knee Calf Stretch', 'Face wall with both knees slightly bent. Position fore foot on wall with heel on floor.', 'Straighten knee of rear leg and lean body toward wall. Hold stretch. Repeat with opposite leg.', 'https://exrx.net/Stretches/Soleus/FloorBoard', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary')) AS m(name, role)
WHERE e.name = 'Floor Board Bent Knee Calf Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Seated Bent Leg Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Seated Bent Leg Calf Stretch', 'Sit on floor or mat. Place heel on floor or mat with bent knee upright. Grasp top of forefoot.', 'Pull forefoot toward shin. Repeat with opposite leg.', 'https://exrx.net/Stretches/Soleus/Seated', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary')) AS m(name, role)
WHERE e.name = 'Seated Bent Leg Calf Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Step Bent Knee Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Step Bent Knee Calf Stretch', 'Position toes and balls of feet on stair step or calf block with arches and heels extending off. Place support leg up to higher steps. Use railing or wall for balance. Bend rear knee.', 'Allow rear heel to lower below step. Hold stretch for 20 seconds. Repeat with opposite leg.', 'https://exrx.net/Stretches/Soleus/Step', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary')) AS m(name, role)
WHERE e.name = 'Step Bent Knee Calf Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Bent Knee Calf Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Bent Knee Calf Stretch', 'Place both hands on wall with arms extended. Lean against wall with one leg bent forward and other leg extended back. Bend rear knee slightly, positioned foot directly forward, and place heal to floor.', 'Lower knee until just before heel raises. Hold stretch for 20 seconds. Repeat with opposite leg.', 'https://exrx.net/Stretches/Soleus/Wall', 'Calves', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Soleus', 'primary')) AS m(name, role)
WHERE e.name = 'Wall Bent Knee Calf Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Safety Bar Reverse Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Safety Bar Reverse Calf Raise', 'Standing facing safety barbell on rack upper chest height and calf block on floor just below. Position heels on forward edge of calf block. Place hands on bar to each sides or on vertical rack bars. Position head in yoke with padded bar around shoulders. Dismount bar from rack by standing erect with safety bar, away yet close to rack.', 'Pull forefeet up toward body as far as possible. Return by extending feet until toes are pointed downward. Repeat.', 'https://exrx.net/WeightExercises/TibialisAnterior/SBReverseCalfRaise', 'Calves', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Tibialis Anterior', 'primary')) AS m(name, role)
WHERE e.name = 'Safety Bar Reverse Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Reverse Calf Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Reverse Calf Raise', 'Place cable belt or dip belt around waist. Kneel before low pulley and attach it to cable. Stand and position heels on forward edge of platform. Grasp support bar for balance.', 'Pull forefeet up toward body as far as possible. Return by extending feet until toes are pointed downward. Repeat.', 'https://exrx.net/WeightExercises/TibialisAnterior/CBReverseCalfRaise', 'Calves', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Tibialis Anterior', 'primary')) AS m(name, role)
WHERE e.name = 'Cable Reverse Calf Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Chest Dip', 'Mount [wide dip bar](../../WeightTraining/Tips#DipBar) with oblique grip (bar diagonal under palm), arms straight with shoulders above hands. Step down onto assistance lever with hips and knees bent.', 'Lower body by bending arms, allowing elbows to flare out to sides. When slight stretch is felt in chest or shoulders, push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/AsChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Machine-assisted Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Chest Dip (kneeling)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Chest Dip (kneeling)', 'Mount [wide dip bar](../../WeightTraining/Tips#DipBar) with oblique grip (bar diagonal under palm), arms straight with shoulders above hands. Kneel on padded platform, lowering it down slightly so hips are slightly bent.', 'Lower body by bending arms, allowing elbows to flare out to sides. When slight stretch is felt in chest or shoulders push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/AsChestDipKneeling', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Machine-assisted Chest Dip (kneeling)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Bench Press', 'Lie supine on bench. Dismount barbell from rack over upper chest using wide oblique overhand grip.', 'Lower weight to chest. Press bar upward until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BBBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Barbell Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Bench Press (power lift)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Bench Press (power lift)', 'Lie supine on bench. Grasp bar with overhand and slightly wider than shoulder width grip. Arch back, extend hips, and position feet back flat on floor. Dismount barbell from rack over chest.', 'Lower weight to lower chest. Press bar upward until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BBBenchPressPowerLift', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Bench Press (power lift)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Decline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Decline Bench Press', 'Lie supine on decline bench with feet under leg brace. Dismount barbell from rack over chest using wide oblique overhand grip.', 'Lower weight to chest. Press bar until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BBDeclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Barbell Decline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Standing Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Standing Chest Press', 'Stand between two shoulder height pulleys, facing away from cable columns. Grasp cable stirrups from each side. Position stirrups to sides of chest with elbows out to sides. Position forearms horizontally and parallel with hands elbow width. Step forward in lunging posture (one foot in front and other foot behind). Lean and step forward with one foot in front, bending forward leg.', 'Push stirrups forward until arms are straight and parallel to one another. Return stirrups to original position until slight stretch is felt in chest or shoulders. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/CBStandingChestPress', 'Chest', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Standing Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Bench Press', 'Sit down on bench with dumbbells resting on lower thigh. Kick weights to shoulder and lie back. Position dumbbells to sides of chest with bent arm under each dumbbell.', 'Press dumbbells up with elbows to sides until arms are extended. Lower weight to sides of chest until slight stretch is felt in chest or shoulder. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/DBBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Dumbbell Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Decline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Decline Bench Press', 'Sit down on decline bench with feet under leg brace and dumbbells resting on thigh. Lie back with dumbbells. Position dumbbells to sides of chest with bent arm under each dumbbell.', 'Press dumbbells up with elbows to sides until arms are extended. Lower weight to sides of chest until slight stretch is felt in chest or shoulder. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/DBDeclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Dumbbell Decline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Fly
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Fly', 'Grasp two dumbbells. Lie supine on bench. Support dumbbells above chest with arms fixed in slightly bent position. Internally rotate shoulders so elbows point out to sides.', 'Lower dumbbells to sides until chest muscles are stretched with elbows fixed in slightly bent position. Bring dumbbells together in wide hugging motion until dumbbells are nearly together. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/DBFly', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Biceps Brachii, Short Head', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Fly' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Pullover
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Pullover', 'Lie on upper back perpendicular to bench. Flex hips slightly. Grasp one dumbbell from behind or from side with both hands under inner plate of dumbbell. Position dumbbell over chest with elbows slightly bent.', 'Keeping elbows slightly bent throughout movement, lower dumbbell over and beyond head until upper arms are in-line with torso. Pull dumbbell up and over chest. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/DBPullover', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Pullover' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Chest Dip (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Chest Dip (plate loaded)', 'Sit on seat and grasp handles with oblique grip. If available, place handles in [wider position](../../WeightTraining/Tips#DipBar). Lean forward slightly.', 'Push lever down with elbows away from body. Return until chest is slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVChestDipH', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Chest Dip (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Decline Chest Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Decline Chest Press (plate loaded)', 'Sit on seat with lever grips lower chest height. Grasp grips with wide overhand grip; elbows out to sides just below shoulders.', 'Press lever until arms are extended. Return weight until chest muscles are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVDeclineChestPressPL', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Decline Chest Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Chest Dip', 'If possible, place handles in [wide position](../../WeightTraining/Tips#DipBar). Sit on seat and grasp handles with oblique grip. Lean forward slightly and allow elbows to flare out.', 'Push lever down by straightening arms. Return lever up with elbows flaring out until chest is slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Bench Press', 'Lie supine on bench with chest under lever bar. Grasp lever bar with wide oblique overhand grip.', 'Press bar until arms are extended. Lower weight to upp er chest. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Chest Press', 'Sit on seat with chest approximately height of horizontal handles. If available, push foot lever until lever is within grasping range. Grasp handles with wide overhand grip; elbows out to sides just below shoulders. Release foot lever.', 'Press lever until arms are extended. Return weight until chest muscles are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVChestPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Chest Press', 'Sit on seat with chest approximately height of handles. Grasp handles with wide overhand grip; elbows out to sides just below shoulders.', 'Press lever until arms are extended. Return weight until chest muscles are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/LVChestPressS', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Standing Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Standing Chest Dip', 'Stand between handles facing machine. Bend forward slightly and grasp parallel handles with oblique grip. Position elbows upward and outward. Bend knees just enough to raise selected weight up from remaining weight stack.', 'Push lever down by straightening arms. Return lever up with elbows flaring out until chest is slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/SLStandingChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Standing Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Bench Press', 'Lie supine on bench with chest under bar. Grasp bar with wide oblique overhand grip. Disengage bar by raising and rotating bar back.', 'Lower weight to chest. Press bar until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/SMBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Decline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Decline Bench Press', 'Lie supine on decline bench with feet under leg brace and lower chest under bar. Grasp bar with wide oblique overhand grip. Disengage bar by raising and rotating bar back.', 'Lower weight to lower chest. Press bar until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/SMDeclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Decline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Chest Dip', 'Place weight on dip belt around waist or place dumbbell between lower legs just above feet. Mount [wide dip bar](../../WeightTraining/Tips#DipBar) with oblique grip (bar diagonal under palm), arms straight with shoulders above hands. Keep hips and knees bent.', 'Lower body by bending arms, allowing elbows to flare out to sides. When slight stretch is felt in chest or shoulders, push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/WtChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Push-up', 'Lie prone on floor with hands slightly wider than shoulder width. Raise body up off floor by extending arms with body straight. Partner can place weight plate(s) on back if needed.', 'Keeping body straight, lower body to floor by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/WtPushup', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Chest Dip', 'Place one foot on middle of exercise band with ends looped on [wide dip bars](../../WeightTraining/Tips#DipBar). Push band down partially by extending leg. Mount dip bar with oblique grip (bar diagonal under palm), arms straight, and shoulders above hands. Place other foot on exercise band next to other foot. Bend knees and hips slightly.', 'Lower body by bending arms, allowing elbows to flare out to sides. When slight stretch is felt in chest or shoulders, push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/ASChestDipBand', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Band-assisted Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Chest Dip', 'Mount [wide dip bar](../../WeightTraining/Tips#DipBar) with oblique grip (bar diagonal under palm), arms straight with shoulders above hands. Bend knees and hips slightly.', 'Lower body by bending arms, allowing elbows to flare out to sides. When slight stretch is felt in chest or shoulders, push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BWChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Push-up', 'Lie prone with forefeet on floor and hands slightly wider than shoulder width. Raise body up off floor by extending arms with body straight.', 'Keeping body straight, lower body to floor by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BWPushup', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Archer Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Archer Push-up', 'Lie prone with forefeet on floor and hands pointed outward, one close to rib cage and other at arm''s length away. Position head facing toward extended arm.', 'Keeping extended arm and body reasonably straight, push body up with arm closest to body until arm is extended. Turn head head and lower body to opposite side. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BWArcherPushup', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Archer Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Push-up', 'Stand facing bench or sturdy elevated platform. Place hands on edge of bench or platform, slightly wider than shoulder width. Position forefoot back from bench or platform with arms and body straight. Arms should be perpendicular to body.', 'Keeping body straight, lower chest to edge of box or platform by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BWInclinePushup', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Gastrocnemius', 'stabilizer'), ('Soleus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Push-up (on knees)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Push-up (on knees)', 'Lie prone on floor with hands slightly wider than shoulder width. Bend knees and raise body up off floor by extending arms with body straight.', 'Keeping body straight and knees bent, lower body to floor by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/BWPushupKnee', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Push-up (on knees)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Self-assisted Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Self-assisted Chest Dip', 'Stand on bench or elevation between parallel bars. Mount [wide dip bar](../../WeightTraining/Tips#DipBar) with oblique grip (bar diagonal under palm), arms straight with shoulders above hands. Bend knees and hips slightly and place forefoot on bench or elevation below.', 'Lower body by bending arms, allowing elbows to flare out to sides. If necessary, use minimal assistance of lower body to control descent, allowing knees and hips to bend, keeping forefeet in contact with bench or elevation. When slight stretch is felt in chest or shoulders, push body up until arms are straight and repeat, again with minimal assistance from legs.', 'https://exrx.net/WeightExercises/PectoralSternal/AsChestDipSelf', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Self-assisted') FROM ex WHERE pg_temp.get_eq('Self-assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Self-assisted Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Self-assisted Chest Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Self-assisted Chest Dip', 'Stand between two suspension handles, approximately mid-thigh height. Grasp handles on each side and straighten arms with shoulders above hands. Hold position firmly and place portion of body weight on handles.', 'Lower body by bending arms back. If necessary, use minimal assistance of lower body to control descent, allowing knees to bend, keeping feet in contact with floor. When slight stretch is felt in chest or shoulders, push body up back up until arms are straight. Repeat with minimal assistance from legs.', 'https://exrx.net/WeightExercises/PectoralSternal/STSelfAssistedChestDip', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Self-assisted Chest Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Chest Press', 'Grasp handles and step forward between suspension trainers. Position arms downward and slightly forward, nearly parallel with suspension straps. Lean forward, placing upper body weight onto handles with arms straight, while stepping back onto forefeet so body is leaning forward at desired angle. Straighten body so torso is in-line with legs.', 'Lower body by bending arms while keeping body straight. Allow handles to come apart slightly to keep in-line with elbows flaring out. Stop descent once mild stretch is felt through shoulders or chest. Push body up to original position, allowing handles to travel inward to keep in line with elbows converging until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/STChestPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Sternal', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Gastrocnemius', 'stabilizer'), ('Soleus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Close Grip Pulldown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Close Grip Pulldown', 'Grasp parallel cable attachment. Sit with thighs under supports.', 'Pull down cable attachment to upper chest. Return until arms and shoulders are fully extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralSternal/STFly', 'Chest', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Latissimus Dorsi', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Teres Major', 'secondary'), ('Deltoid, Posterior', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Biceps Brachii', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Close Grip Pulldown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Behind Head Chest Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Behind Head Chest Stretch', 'Place hands behind head.', 'Pull elbows back further behind ears. Hold stretch.', 'https://exrx.net/Stretches/ChestGeneral/BehindHead', 'Chest', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Doorway Chest Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Doorway Chest Stretch', 'Stand at end of wall or in doorway facing perpendicular to wall. Place inside of bent arm on surface of wall. Position bent elbow shoulder height.', 'Turn body away from positioned arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/ChestGeneral/Doorway', 'Chest', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Straight Arm Chest Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Straight Arm Chest Stretch', 'With arm extended, position hand on fixed structure shoulder height.', 'Turn body away from positioned arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/ChestGeneral/StraightArm', 'Chest', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Doorway Modified Chest Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Doorway Modified Chest Stretch', 'Stand at end of wall or in doorway facing perpendicular to wall. Place front of shoulder and inside of bent arm on surface of wall. Position bent elbow around same height of shoulder. Position both feet back behind original stance.', 'Lean into wall allowing shoulder to be pushed back. Turn body away from positioned arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/PectoralisMinor/Doorway', 'Chest', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;

-- Barbell Incline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Incline Bench Press', 'Lie supine on incline bench. Dismount barbell from rack over upper chest using wide oblique overhand grip.', 'Lower weight to chest. Press bar until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/BBInclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary')) AS m(name, role)
WHERE e.name = 'Barbell Incline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Incline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Incline Bench Press', 'Sit down on incline bench with dumbbells resting on lower thigh. Kick weights to shoulders and lean back. Position dumbbells to sides of chest with upper arm under each dumbbell.', 'Press dumbbells up with elbows to sides until arms are extended. Lower weight to sides of upper chest until slight stretch is felt in chest or shoulder. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/DBInclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Dumbbell Incline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Incline Fly
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Incline Fly', 'Grasp two dumbbells. Lie supine on bench. Support dumbbells above upper chest with arms fixed in slightly bent position. Bend elbows slightly and internally rotate shoulders so elbows point out to sides.', 'Lower dumbbells outward to sides of shoulders. Keep elbows fixed in slightly bent position. When a stretch is felt in chest or shoulders, bring dumbbells back together in hugging motion above upper chest until dumbbells are nearly together. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/DBInclineFly', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Biceps Brachii, Short Head', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Incline Fly' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Incline Chest Press (on Hammer military press, plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Incline Chest Press (on Hammer military press, plate loaded)', 'Sit on seat with upper chest just above base of handles on lever. Grasp grips with wide overhand grip. Lift levers into starting position with elbows slightly low.', 'Press levers until arms are extended. Return weight until chest muscles are slightly stretched with elbows positioned out to sides. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/LVInclineChestPressOnHammerMilitaryPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Incline Chest Press (on Hammer military press, plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Incline Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Incline Chest Press', 'Sit on seat with upper chest just above grips on lever. If available, push foot lever until handles are within grasping range. Grasp handles with wide oblique overhand grip and position elbows out to sides. Release foot lever.', 'Press lever until arms are extended. Return weight until shoulders or chest feels slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/LVInclineChestPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Incline Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Incline Chest Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Incline Chest Press', 'Sit on seat with upper chest just above grips on lever. Grasp grips with wide overhand grip and position elbows out to sides.', 'Press lever until arms are extended. Return weight until chest muscles are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/LVInclineChestPressH', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Incline Chest Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Incline Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Incline Bench Press', 'Lie supine on incline bench with chest under bar. Grasp bar with wide oblique overhand grip. Disengage bar by raising and rotating bar back.', 'Lower weight to chest. Press bar until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/SMInclineBenchPress', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii, Short Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Incline Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Decline Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Decline Push-up', 'Kneel on floor with bench or elevation behind body. Position hands on floor slightly wider than shoulder width. Place feet on bench or elevation. Raise body in plank position with body straight and arms extended.', 'Keeping body straight, lower upper body to floor by bending arms. To allow for full descent, pull head back slightly without arching back. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/PectoralClavicular/BWDeclinePushup', 'Chest', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Major, Clavicular', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Decline Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Angel
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Angel', 'Position back against wall. Place feet away from wall, slightly bending hips and knees. Bend elbows and position back of arms against wall with elbows to sides.', 'Push shoulders and back of arms and hands into wall and slowly raise arms as high as possible. Still pushing shoulders arms, slowly lower arms to starting position.', 'https://exrx.net/Stretches/PectoralisMinor/Wall', 'Chest', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Minor', 'primary'), ('Deltoid, Posterior', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Infraspinatus', 'stabilizer'), ('Teres Minor', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Wall Angel' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Premium Content
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Premium Content', NULL, NULL, 'https://exrx.net/WeightExercises/Other/STAngle', 'Chest', NULL, NULL, NULL, 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Pectoralis Minor', 'primary')) AS m(name, role)
WHERE e.name = 'Premium Content' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Twisting Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Twisting Sit-up', 'Hook feet under foot or ankle brace and lie supine on incline bench with hips and knees bent. Place hands behind neck.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/SerratusAnterior/BBInclineShoulderRaise', 'Chest', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Twisting Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Incline Shoulder Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Incline Shoulder Raise', 'Sit down on incline bench with dumbbells resting on lower thigh. Kick weights to shoulders and lean back. Position dumbbells above shoulders with elbows extended.', 'Raise shoulders toward dumbbells as high as possible. Lower shoulders to bench and repeat.', 'https://exrx.net/WeightExercises/SerratusAnterior/DBInclineShoulderRaise', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Serratus Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Incline Shoulder Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Incline Shoulder Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Incline Shoulder Raise', 'Sit on lever chest press machine with shoulders aligned with lever grips. Grasp lever grips with shoulder width overhand grip. Push weight up so arms are straight.', 'Raise shoulders toward lever grips as far as possible. Lower shoulders to bench and repeat.', 'https://exrx.net/WeightExercises/SerratusAnterior/LVInclineShoulderRaise', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Serratus Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Incline Shoulder Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Incline Shoulder Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Incline Shoulder Raise', 'Lie supine on incline bench with shoulders under bar. Grasp bar with shoulder width overhand grip. Extend elbows. Disengage bar by rotating bar back.', 'Raise shoulders toward bar as high as possible. Lower shoulders to bench and repeat.', 'https://exrx.net/WeightExercises/SerratusAnterior/SMInclineShoulderRaise', 'Chest', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Serratus Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Incline Shoulder Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Push-up Plus
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Push-up Plus', 'Lie prone with forefeet on floor and hands slightly wider than shoulder width. Raise body up off floor by extending arms with body straight.', 'Keeping body straight, lower body to floor by bending arms. Push body up until arms are extended. Continue lifting body further up by pushing shoulders infront of chest. Repeat.', 'https://exrx.net/WeightExercises/SerratusAnterior/BWPushUpPlus', 'Chest', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Serratus Anterior', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Push-up Plus' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Reverse Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Reverse Curl', 'Grasp bar with shoulder width overhand grip.', 'With elbows to side, raise bar until forearms are vertical. Lower until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachioradialis/BBReverseCurl', 'Forearms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachioradialis', 'primary'), ('Brachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Reverse Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Reverse Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Reverse Curl', 'Grasp cable bar with shoulder width overhand grip.', 'With elbows to side, raise bar until forearms are vertical. Lower until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachioradialis/CBReverseCurl', 'Forearms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachioradialis', 'primary'), ('Brachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Reverse Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Hammer Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Hammer Curl', 'Position two dumbbells to sides, palms facing in, arms straight.', 'With elbows to sides, raise one dumbbell until forearm is vertical and thumb faces shoulder. Lower to original position and repeat with alternative arm.', 'https://exrx.net/WeightExercises/Brachioradialis/DBHammerCurl', 'Forearms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachioradialis', 'primary'), ('Brachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Flexor Carpi Radialis', 'stabilizer'), ('Extensor Carpi Radialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Hammer Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Standing Brachioradialis Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Standing Brachioradialis Stretch', 'Cross wrists, point thumbs downward, and clasp hands.', 'Straighten arms and externally rotate shoulders by back. Hold stretch.', 'https://exrx.net/Stretches/Brachioradialis/Standing', 'Forearms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachioradialis', 'primary')) AS m(name, role)
WHERE e.name = 'Standing Brachioradialis Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Wrist Curl', 'Sit and grasp bar with narrow to shoulder width underhand grip. Rest forearms on thighs with wrists just beyond knees.', 'Allow barbell to roll out of palms down to fingers. Raise barbell back up by gripping and pointing knuckles up as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/BBWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Barbell Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Wrist Curl', 'Sit and grasp cable bar with narrow to shoulder width underhand grip. Rest forearms on thighs with wrists just beyond knees.', 'Allow cable bar to roll out of palms down to fingers. Raise cable bar back up by gripping and pointing knuckles up as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/CBWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Cable Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Wrist Curl', 'Sit and grasp dumbbell with underhand grip. Rest forearm on thigh with wrist just beyond knee.', 'Allow dumbbell to roll out of palm down to fingers. Raise dumbbell back up by gripping and pointing knuckles up as high as possible. Lower and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/DBWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Dumbbell Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Grip (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Grip (plate loaded)', 'Sit on seat, straddling apparatus. Grasp lever handles on each side; fingers around lever handles and base of thumbs around stationary bars.', 'Squeeze bars together with both hands until lower lever makes contact with upper bars. Lower to original position and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/LVGripPL', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Grip (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Wrist Curl (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Wrist Curl (plate loaded)', 'Grasp bar with underhand grip. Place forearm on padded platform.', 'Raise bar up until wrist is fully flexed. Lower and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/LVWristCurlPL', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Wrist Curl (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled One Hand Grip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled One Hand Grip', 'Stand in front of apparatus. Grasp bar grips with one hand; fingers around far bar and base of thumb around near stationary bar.', 'Squeeze bar grips together until far bar makes contact with nearest bar. Release to original position and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/SLGrip', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Sled One Hand Grip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled One Hand Grip (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled One Hand Grip (plate loaded)', 'Bend over and grasp bar grips with one hand; fingers under lower bar and base of thumb over top stationary bar.', 'Squeeze bar grips together until lower bar makes contact with upper bar. Release to original position and repeat.', 'https://exrx.net/WeightExercises/WristFlexors/SLOneHandGripPlateLoaded', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Sled One Hand Grip (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Kneeling Wrist Flexor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Kneeling Wrist Flexor Stretch', 'Kneel on floor or mat. Place palms of hand on floor with fingers pointing toward knees.', 'Shift body back with elbows straight. Hold stretch.', 'https://exrx.net/Stretches/WristFlexors/Kneeling', 'Forearms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Kneeling Wrist Flexor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Seated Wrist Flexor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Seated Wrist Flexor Stretch', 'Sit on floor. Place palms on floor to sides, behind hips with fingers pointing to back.', 'Lean back with arms straight. Hold stretch.', 'https://exrx.net/Stretches/WristFlexors/Seated', 'Forearms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Flexors', 'primary')) AS m(name, role)
WHERE e.name = 'Seated Wrist Flexor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Reverse Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Reverse Wrist Curl', 'Sit and grasp bar with narrow to shoulder width overhand grip. Rest forearms on thighs with wrists just beyond knees.', 'Raise barbell by pointing knuckles upward as high as possible. Return until knuckles are pointing downward as far as possible. Repeat.', 'https://exrx.net/WeightExercises/WristExtensors/BBReverseWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Barbell Reverse Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Reverse Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Reverse Wrist Curl', 'Sit and grasp cable bar with narrow to shoulder width overhand grip. Rest forearms on thighs with wrists just beyond knees.', 'Raise stirrup by pointing knuckles upward as high as possible. Return until knuckles are pointing downward as far as possible. Repeat.', 'https://exrx.net/WeightExercises/WristExtensors/CBReverseWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Cable Reverse Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Reverse Wrist Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Reverse Wrist Curl', 'Sit and grip dumbbell with overhand grip. Rest forearm on thigh with wrist just beyond knee.', 'Raise dummbell by pointing knuckles upward as high as possible. Return until knuckles are pointing downward as far as possible. Repeat.', 'https://exrx.net/WeightExercises/WristExtensors/DBReverseWristCurl', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Dumbbell Reverse Wrist Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Reverse Wrist Curl (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Reverse Wrist Curl (plate loaded)', 'Grasp bar with overhand grip. Place forearm on padded platform.', 'Raise bar until wrist is fully hyperextended and return until wrist is fully flexed. Repeat.', 'https://exrx.net/WeightExercises/WristExtensors/LVReverseWristCurlPL', 'Forearms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Reverse Wrist Curl (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Kneeling Wrist Extensor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Kneeling Wrist Extensor Stretch', 'Kneel on floor or mat. Flex wrists and place tops of hand on floor with fingers pointing toward knees.', 'Lean against floor with elbows straight. Hold stretch for 20 seconds.', 'https://exrx.net/Stretches/WristExtensors/Kneeling', 'Forearms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Kneeling Wrist Extensor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Single Arm Wrist Extensor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Single Arm Wrist Extensor Stretch', 'With palm facing downward, pull wrist and fingers downward toward forearm.', 'Extend or straighten elbow. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/WristExtensors/Single', 'Forearms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Single Arm Wrist Extensor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Seated Pronation
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Seated Pronation', 'Sit next to elevated surface, approximately arm pit height. With hand of upper arm, grasp unilaterally loaded dumbbell; pinkie positioned near weighted side. Bend elbow approximately 90-degrees and place upperarm on elevated surface. Position thumb upward (supinated).', 'Rotate dumbbell so thumb turns downward (pronation). Return and repeat.', 'https://exrx.net/WeightExercises/Pronators/DBSeatedPronation', 'Forearms', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary')) AS m(name, role)
WHERE e.name = 'Dumbbell Seated Pronation' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Seated Supination
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Seated Supination', 'Sit next to elevated surface, approximately arm pit height. With hand of arm next to elevated surface, grasp unilaterally loaded dumbbell; thumb next to side with weight. Bend elbow approximately 90-degrees and place upperarm on elevated surface. Position thumb downward (pronated).', 'Rotate dumbbell so thumb turns upward (supination). Return and repeat.', 'https://exrx.net/WeightExercises/Supinators/DBSeatedSupination', 'Forearms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Wrist Extensors', 'primary'), ('Biceps Brachii', 'secondary')) AS m(name, role)
WHERE e.name = 'Dumbbell Seated Supination' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Bent Knee Good-morning
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Bent Knee Good-morning', 'Position barbell on back of shoulders and grasp bar to sides.', 'Keeping back straight, bend hips to lower torso forward until parallel to floor. Bend knees slightly during descent. Raise torso until hips are extended. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBBentKneeGoodMorning', 'Hips', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Bent Knee Good-morning' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Deadlift', 'With feet flat beneath bar squat down and grasp bar with shoulder width or slightly wider overhand or mixed grip.', 'Lift bar by extending hips and knees to full extension. Pull shoulders back at top of lift if rounded. Return weights to floor by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBDeadlift', 'Hips', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Stiff Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Stiff Leg Deadlift', 'Stand with shoulder width or narrower stance on 5" to 8" (13-20 cm) platform with feet flat beneath bar. Bend over and grasp barbell with shoulder width or slightly wider overhand or mixed grip.', 'With knees bent, lift bar by extending at hips until standing upright. Pull shoulders back at top of lift if rounded. Extend knees at top if desired. Lower bar to top of feet by bending hips. Bend knees slightly during descent and keep waist straight, flexing only slightly at bottom. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBStiffLegDeadlift', 'Hips', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Erector Spinae', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Stiff Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Straight-back Stiff-leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Straight-back Stiff-leg Deadlift', 'Grasp barbell from rack or [deadlift](../ErectorSpinae/BBDeadlift) from floor with shoulder width or slightly wider overhand or mixed grip. Stand with shoulder width or narrower stance.', 'With back straight, lower bar to top of feet by bending hips. Bend knees slightly during descent and keep waist straight. Place weight onto floor. With knees still bent, lift bar by straightening hips until standing upright. Pull shoulders back if rounded. Extend knees at top if desired. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBStrBackStiffLegDeadlift', 'Hips', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Straight-back Stiff-leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Hip Thrust
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Hip Thrust', 'Sit on floor with long side of bench behind back. Roll barbell back and center over hips. Position upper back on corner of bench. Place feet on floor approximately shoulder width with knees bent. Grasp bar to each side.', 'Raise bar upward by extending hips until straight. Lower and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBHipThrust', 'Hips', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Hip Thrust' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Lunge', '[Clean](../OlympicLifts/Clean) bar from floor or dismount bar from rack. From rack with barbell upper chest height, position bar on back of shoulders and grasp barbell to sides.', 'Lunge forward with first leg. Land on heel, then forefoot. Lower body by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by forcibly extending hip and knee of forward leg. Repeat by alternating lunge with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBLunge', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Tibialis Anterior', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Rear Lunge', 'From rack with barbell upper chest height, position bar on back of shoulders and grasp barbell to sides. Dismount bar from rack.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBRearLunge', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Single Leg Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Single Leg Split Squat', 'Stand facing away from bench. Position bar on back of shoulders and grasp barbell to sides. Extend leg back and place top of foot on bench.', 'Squat down by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBSingleLegSplitSquat', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Single Leg Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Single Leg Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Single Leg Squat', 'Stand with arms extended out in front holding barbell. Balance on one leg with opposite leg extended forward off of ground.', 'Squat down as far as possible while keeping leg elevated off of floor. Keep supporting knee pointed same direction as foot supporting. Raise body back up to original position until knee and hip of supporting leg is straight. Return and repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBSingleLegSquat', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Serratus Anterior, Inferior Digitations', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Single Leg Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Split Squat', 'Position barbell on back of shoulders and grasp barbell to sides. Stand with feet far apart; one foot forward and other foot behind.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBSplitSquat', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Squat (low bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Squat (low bar)', 'From rack with barbell at upper chest height, position bar low on back of shoulders. Grasp barbell to sides. Dismount bar from rack and stand with wide stance.', 'Squat down by bending hips back while allowing knees to bend forward slightly, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend hips and knees until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBSquat', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Squat (low bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Front Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Front Squat', 'From rack with barbell upper chest height, position bar in front of shoulders. Cross arms and place hands on top of barbell with upper arms parallel to floor. Dismount bar from rack.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBFrontSquat', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Supraspinatus', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Front Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Safety Barbell Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Safety Barbell Squat', 'Standing facing safety barbell on rack upper chest height. Position head in yoke with padded bar around shoulders. Hands can be placed on ends of yoke (as shown) or on safety bar out to sides. Dismount bar from rack and step back.', 'Squat down by bending hips back while allowing knees to bend slightly forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Stand by extending hips and knees until legs are straight. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/SBSquat', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Safety Barbell Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Step-up', 'Stand facing side of bench. Position bar on back of shoulders and grasp barbell to sides.', 'Place foot of first leg on bench. Stand on bench by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to floor. Repeat first step with opposite leg alternating first steps between legs.', 'https://exrx.net/WeightExercises/GluteusMaximus/BBStepUp', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Hamstrings', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer'), ('Rectus Abdominis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Glute Kickback
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Glute Kickback', 'Attach ankle cuff to low pulley. With cuff on one ankle, grasp ballet bar with both hands and step far back with other foot. Arms remain extended to support body leaning forward. Leg with ankle cuff attached is flexed at hip and knee.', 'Pull cable attachment back by extending hip and knee. Return leg to original position and repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBGluteKickback', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Obliques', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Glute Kickback' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Rear Lunge', 'Stand between two very low pulleys with shoulder width or narrower stance. Squat down and grasp stirrup attachments to each side. Stand upright with arms straight down to sides.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBRearLunge', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Split Squat', 'Stand between two very low cable pulleys. Grasp stirrup attachments with each hand. Place one leg far forward and opposite leg far back to rear.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original straddle position by extending hip and knee of forward leg. Repeat. Continue with legs in opposite position.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBLungeTwoArm', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Squat', 'Stand with feet shoulder width or slightly wider on platform between very low and close pulley cables. Squat down with knees slightly beyond foot and shoulder above feet. Grasp stirrups to each side with arms straight.', 'Keeping chest high and back straight, raise stirrups by extending knees and hips until legs are straight. Squat down by bending hips back while allowing knees to bend forward slightly, keeping back straight and knees pointed same direction as feet. Squat down until thighs are just past parallel to floor. Return and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBSquat', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Standing Hip Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Standing Hip Extension', 'Attach ankle cuff to low pulley. With cuff on one ankle, grasp ballet bar with both hands and step back with other foot. Elbows remain straight. Attached leg is straight and foot is slightly off floor.', 'Pull cable attachment back by extending hip. Return leg to original position. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBStandingHipExtension', 'Hips', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Hamstrings', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Rectus Abdominis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Standing Hip Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Bent-over Hip Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Bent-over Hip Extension', 'Attach ankle cuff to low pulley. With cuff on one ankle, grasp ballet bar with both hands and step far back with other foot. Arms remain extended to support body leaning forward. Leg with ankle cuff attached in slightly bent with foot off floor.', 'Pull cable attachment back by extending hip. Return leg to original position and repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBBentOverHipExtension', 'Hips', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Hamstrings', 'secondary'), ('Obliques', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Bent-over Hip Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Step-up', 'Stand behind elevated platform and low and close pulley cables to sides. Grasp stirrups at each side of platform. Stand upright with arms straight down at sides.', 'Place foot of first leg on elevated platform. Stand on elevated platform by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to lower position. Repeat first step with opposite leg alternating first steps between legs.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBStepUp', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Stiff Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Stiff Leg Deadlift', 'Stand on elevated platform between two very low pulleys with shoulder width or narrower stance. Squat down and grasp stirrup attachments to each side. Stand upright with arms straight down to sides.', 'Bow forward by bending hips. Bend knees slightly during descent and keep waist straight, flexing low back at bottom. With knees slightly bent, raise torso by extending at waist, then hips, gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBStiffLegDeadlift', 'Hips', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Erector Spinae', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Stiff Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Straight-back Stiff-leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Straight-back Stiff-leg Deadlift', 'Stand between two very low pulleys with shoulder width or narrower stance. Squat down and grasp stirrup attachments to each side. Stand upright with arms straight down to sides.', 'With back straight, bow forward by bending hips and bend knees slightly during descent. Raise torso by extending hips while gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/CBStrBackStiffLegDeadlift', 'Hips', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Straight-back Stiff-leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lunge', 'Stand with dumbbells grasped to sides.', 'Lunge forward with first leg. Land on heel then forefoot. Lower body by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by forcibly extending hip and knee of forward leg. Repeat by alternating lunge with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBLunge', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Tibialis Anterior', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Rear Lunge', 'Stand with dumbbells grasped to sides.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBRearLunge', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Split Squat', 'Stand with dumbbells grasped to sides. Stand with feet far apart; one foot forward and other foot behind.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBSplitSquat', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Squat', 'Stand with dumbbells grasped to sides.', 'Squat down by bending hips back while allowing knees to bend forward slightly, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBSquat', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Front Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Front Squat', 'Stand with dumbbells grasped to sides. Clean dumbbells up to shoulders so side of each dumbbell rests on top of each shoulder. Balance dumbbells on shoulder by holding on to dumbbells with elbows flaring outward. Position feet shoulder width or slightly narrower apart.', 'Squat down by bending hips back while allowing knees to bend forward slightly, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBFrontSquat', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Front Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Step-up', 'Stand with dumbbells grasped to sides facing side of bench.', 'Place foot of first leg on bench. Stand on bench by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to floor. Repeat first step with opposite leg, alternating first steps between legs.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBStepUp', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Step Down
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Step Down', 'Hold dumbbells in each hand down to sides and stand with one foot on bench. Position foot on bench to side, forward of straight knee.', 'Stand on bench by straightening leg and pushing body upward. Step down returning foot off of bench to floor and repeat. Continue with opposite position.', 'https://exrx.net/WeightExercises/GluteusMaximus/DBStepDown', 'Hips', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Step Down' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Deadlift (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Deadlift (plate loaded)', 'Stand between lever handles to sides. Squat down with feet flat and grasp handles to sides.', 'Lift lever by extending hips and knees to full extension. Pull shoulders back at top of lift if rounded. Return weight by bending hips back while allowing knees to bend forward slightly, keeping back straight and knees pointed same direction as feet. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/LVDeadlift', 'Hips', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Deadlift (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Stiff Leg Deadlift (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Stiff Leg Deadlift (plate loaded)', 'Stand between lever handles with shoulder width or narrower stance. Squat down and grasp handles to each side. Stand upright with arms straight down to sides.', 'Bow forward by bending hips. Bend knees slightly during descent and keep waist straight, flexing low back at bottom. With knees slightly bent, raise torso by extending at waist, then hips, gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/LVStiffLegDeadlift', 'Hips', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Erector Spinae', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Stiff Leg Deadlift (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Straight-back Stiff-leg Deadlift (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Straight-back Stiff-leg Deadlift (plate loaded)', 'Stand between lever handles with shoulder width or narrower stance. Squat down and grasp handles to each side. Stand upright with arms straight down to sides.', 'With back straight, bow forward by bending hips and bend knees slightly during descent. Raise torso by extending hips while gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/LVStrBackStiffLegDeadlift', 'Hips', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Straight-back Stiff-leg Deadlift (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever 45° Leg Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever 45° Leg Press (plate loaded)', 'Sit on machine with back on padded support. Place feet slightly high on platform. Extend hips and knees. Release dock lever and grasp handles to sides.', 'Flex hips and knees to lower lever until hips are completely flexed. Push platform by extending knees and hips. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/LV45LegPress', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever 45° Leg Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lying Leg Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lying Leg Press (plate loaded)', 'Climb up steps to top of machine. Lie supine on horizontal padded platform with shoulders against pad. Place feet equally spaced and slightly high on platform. Grip handles above shoulder pads.', 'Push lever platform away by extending hips and knees until knees are straight. Return lever platform by flexing hips and knees until knees are just short of complete flexion or until hips are completely flexed. Repeat.', 'https://exrx.net/WeightExercises/GluteusMaximus/LVLyingLegPressH', 'Hips', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Gluteus Maximus', 'primary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Lying Leg Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Neck Flexion', 'Sit on bench facing away from middle pulley. Place neck in harness cable attachment. Place arms on lower thighs for support.', 'Move head away from pulley by bending neck forward until chin touches upper chest. Return head by hyperextending neck and repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/CBNeckFlx', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Neck Flexion (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Neck Flexion (plate loaded)', 'Sit on seat in machine. Position padded lever on face. Position body so neck is in line with lever axis. Grasp handles for support.', 'Move head forward by flexing neck until chin touches upper chest. Return head by hyperextending neck and repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/LVNeckFlexionH', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Neck Flexion (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lateral Neck Flexion (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lateral Neck Flexion (plate loaded)', 'Sit on seat in machine with feet apart . Position padded lever on side of head. Center body so neck is in line with lever axis. Grasp handles for support.', 'Move head down to side by laterally flexing neck. Return head to opposite side and repeat. Sit in machine backwards and continue with opposite side.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/LVLateralNeckFlexionH', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Lateral Neck Flexion (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Neck Flexion', 'Sit on seat in machine. Position padded lever on face. Position body so neck is in line with lever axis. Grasp handles for support.', 'Move head forward by flexing neck until chin touches upper chest. Return head by hyperextending neck and repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/LVNeckFlx', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lateral Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lateral Neck Flexion', 'Sit on seat in machine with feet apart. Position side of head on padded lever. Center body so neck is in line with lever axis. Grasp handles for support.', 'Move head down to side by laterally flexing neck. Return head to opposite side and repeat. Sit in machine backwards and continue with opposite side.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/LVNeckLtrFlx', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Lateral Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Neck Flexion', 'Place folded towel on weight plate. Lie supine perpendicular on bench with low back and hips extending off and feet on floor. Place weight and towel on forehead. Place plates on forehead with towel placed in between for comfort.', 'Move head up by flexing neck until chin touches upper chest. Return by hyperextending neck and repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/WtNeckFlx', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Lateral Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Lateral Neck Flexion', 'Place folded towel on weight plate. Lie on bench on side with knees and hips bent and arm hanging over edge. Position weight and towel on side of upper head. Hold weight on side of head with hand of upper arm. Place hand of lower arm on floor for support.', 'Move head up to side by laterally flexing neck. Lower head to opposite side and repeat. Lie on other side and continue.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/WtNeckLateralFlex', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Splenius', 'secondary'), ('Erector Spinae', 'secondary'), ('Levator Scapulae', 'secondary'), ('Trapezius, Upper', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Lateral Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Front Neck Bridge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Front Neck Bridge', 'Place small or folded cushioned mat on wall or column approximately chest height. With hands supporting mat on each side, stand back so feet are away from wall or column with body leaning forward. Place top of forehead on mat. Fold hands behind low back or hips.', 'Roll down onto forehead until nose touches mat. Roll up onto top of head until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/BWWallFrontNeckBridge', 'Neck', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Splenius', 'secondary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Wall Front Neck Bridge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Side Neck Bridge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Side Neck Bridge', 'Place small or folded cushioned mat on column or at end of wall approximately shoulder height. With hands supporting mat, stand with side toward mat. Step far to side so feet are away from wall or column forward. Place side of head on mat with shoulder extending over end of adjacent side of column or wall so body leans to side. Fold hands behind low back or hips.', 'Push side of head into mat and roll onto top of head moving body away from mat. Return to original position by rolling back down to side of head while bringing shoulder back over end of column or wall. Repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/BWWallSideNeckBridge', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Wall Side Neck Bridge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Neck Retraction Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Neck Retraction Stretch', 'Stand or sit.', 'Pull head back as far possible while looking slightly down and hold stretch.', 'https://exrx.net/Stretches/Sternocleidomastoid/NeckRetraction', 'Neck', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary')) AS m(name, role)
WHERE e.name = 'Neck Retraction Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Neck Flexion', 'Place belt or strap around end of suspension trainer. Face away from suspension trainer with belt in hand. Place belt around head above ears and clamp belt snugly around head by tightly gripping ends close to back of mid-head. Step forward until suspension trainer is taut. Lean forward at angle against support of belt and suspension trainer by stepping back slightly while keeping head and body straight.', 'Increase angle of body by bowing head until chin touches upper chest. Lower angle of body by raising head. Repeat.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/STNeckFlexion', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Lateral Neck Flexion
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Lateral Neck Flexion', 'Place belt or strap around end of suspension trainer. Hold belt in hand and stand away from suspension trainer so it hangs to one side. Place belt around head above ears and clamp belt snugly around head by tightly gripping ends close to head above ear closest to suspension trainer. Step further away from suspension trainer until it is taut. Lean away at angle against support of belt and suspension trainer by positioning feet closer to side of suspension trainer while keeping head and body straight.', 'Lower angle of body by tilting head to side of suspension trainer. Increase angle of body by tilting head away from side of suspension trainer. Repeat and continue in opposite position.', 'https://exrx.net/WeightExercises/Sternocleidomastoid/STNeckLateralFlexion', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Sternocleidomastoid', 'primary')) AS m(name, role)
WHERE e.name = 'Suspended Lateral Neck Flexion' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Neck Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Neck Extension', 'Sit on bench facing pulley. Place neck in harness cable attachment. Place forearms on lower thighs for support.', 'Move head away from pulley by hyperextending neck. Return by bending neck forward until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Splenius/CBNeckExt', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Sternocleidomastoid', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Neck Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Neck Extension (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Neck Extension (plate loaded)', 'Sit on seat in machine. Place back of head under padded lever. Position body so neck is in line with lever axis. Grasp handles for support.', 'Move head back by hyperextending neck. Return by bending neck forward until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Splenius/LVNeckExtentionH', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Sternocleidomastoid', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Neck Extension (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Neck Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Neck Extension', 'Sit on seat in machine. Place back of head under padded lever. Position body so neck is in line with lever axis. Grasp handles for support.', 'Move head back by hyperextending neck. Return by bending neck forward until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Splenius/LVNeckExt', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Sternocleidomastoid', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Neck Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Seated Neck Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Seated Neck Extension', 'Place folded towel on weight plate. On bench or stool, sit bent over on thighs. With both hands, place plate(s) on back of head with towel placed in between for comfort.', 'Move head up by hyperextending neck up as high as possible. Return by bending neck down until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Splenius/WtNeckExt', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Sternocleidomastoid', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Seated Neck Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Neck Harness Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Neck Harness Extension', 'Sit on bench with weighted neck harness on head. Allow weight to dangle in front by bending over.', 'Move head up by hyperextending neck. Return by bending neck down until chin touches upper chest. Repeat.', 'https://exrx.net/WeightExercises/Splenius/WtNeckHarnessExt', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Erector Spinae, Cervicis & Capitis Fibers', 'secondary'), ('Sternocleidomastoid', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Neck Harness Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band Resistive Neck Retraction
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band Resistive Neck Retraction', NULL, NULL, 'https://exrx.net/WeightExercises/Splenius/BRNeckRetraction', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Erector Spinae, Cervicis & Capitis Fibers', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Band Resistive Neck Retraction' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Rear Neck Bridge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Rear Neck Bridge', 'Hold small or folded cushioned mat behind head. Facing away from wall or column position head and back of shoulders low on wall or column with mat between. Stand with feet far away from wall or column so body is angled back. Position hips and back straight and bend knees just slightly. Place arms to side or hold hands on abdomen.', 'Push head back into mat and roll head upward. Arch spine and straighten knees. Hyperextend neck so head is facing up. Return to original position by rolling head down while allowing low back to straighten and knees to bend slightly. Continue down until back of head and shoulders make contact with mat. Repeat.', 'https://exrx.net/WeightExercises/Splenius/BWWallRearNeckBridge', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Sternocleidomastoid', 'secondary'), ('Erector Spinae', 'secondary'), ('Quadriceps', 'secondary'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Wall Rear Neck Bridge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lying Neck Retraction Isometric
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lying Neck Retraction Isometric', NULL, NULL, 'https://exrx.net/WeightExercises/Splenius/LyingIsometricNeckRetr', 'Neck', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Isometric') FROM ex WHERE pg_temp.get_eq('Isometric') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Erector Spinae, Cervicis & Capitis Fibers', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lying Neck Retraction Isometric' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Neck Extensor Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Neck Extensor Stretch', 'Bow head forward with jaw shut. Depress chin into top of sternum.', 'Slightly turn head to one side. Hold stretch. Repeat to other side.', 'https://exrx.net/Stretches/Splenius/Neck', 'Neck', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary')) AS m(name, role)
WHERE e.name = 'Neck Extensor Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Neck Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Neck Extension', 'Place belt or strap around end of suspension trainer. Place belt around head above ears and clamp belt snugly around head by tightly gripping ends close to forehead. Step back facing direction of suspension trainer until it is taut. Lean back at angle against support of belt and suspension trainer by stepping forward slightly while keeping head and body straight.', 'Lower angle of body by bowing head until chin is near upper chest. Increase angle of body by raising head. Repeat.', 'https://exrx.net/WeightExercises/Splenius/STNeckExtension', 'Neck', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Splenius', 'primary'), ('Trapezius, Upper', 'secondary'), ('Levator Scapulae', 'secondary'), ('Sternocleidomastoid', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Neck Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Front Raise', 'Grasp barbell with overhand grip with elbows straight or slightly bent.', 'Raise barbell forward and upward until upper arms are above horizontal. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/BBFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Military Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Military Press', 'Grasp barbell from rack or [clean](../OlympicLifts/PowerClean) barbell from floor with overhand grip, slightly wider than shoulder width. Position bar in front of neck.', 'Press bar upward until arms are extended overhead. Lower to front of neck and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/BBMilitaryPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Military Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Seated Military Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Seated Military Press', 'Grasp barbell with slightly wider than shoulder width overhand grip from rack. Position bar near upper chest.', 'Press bar upward until arms are extended overhead. Return to upper chest and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/BBSeatedMilitaryPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Triceps Brachii, Long Head', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Seated Military Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Seated Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Seated Front Raise', 'Sit on seat above twin cable pulleys. Grasp stirrups on each side. Sit upright with arms straight down to each side with palms facing back.', 'Raise stirrups forward and upward until upper arms are well above horizontal. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/CBSeatedFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Seated Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Alternating Isolateral Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Alternating Isolateral Front Raise', 'Stand with low double pulleys behind. Grasp stirrup attachments, one in each hand. Stand away from pulley slightly with arms back somewhat at side and elbows straight or slightly bent.', 'Raise one stirrup forward and upward until upper arm is well above horizontal. Lower and repeat with opposite arm, alternating between arms.', 'https://exrx.net/WeightExercises/DeltoidAnterior/CBAlternatingFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Alternating Isolateral Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Front Raise', 'Grasp stirrup attachment. Stand away from pulley slightly with arm back somewhat at side and elbow straight or slightly bent.', 'Raise stirrup forward and upward until upper arm is well above horizontal. Lower and repeat. Repeat with opposite arm.', 'https://exrx.net/WeightExercises/DeltoidAnterior/CBFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Shoulder Press', 'Sit on seat and grasp stirrups from low to medium low position from each side. Position stirrups to each side of shoulders with elbows down to sides and stirrups above or slightly narrower than elbows.', 'Push stirrups upward until arms are extended overhead. Return stirrups to sides of shoulders and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/CBShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Arnold Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Arnold Press', 'Stand with two dumbbells position in front of shoulders, palms facing body and elbows under wrists.', 'Initiate movement by bringing elbows out to sides. Continue to raise elbows outward while pressing dumbbells overhead until arms are straight. Lower to front of shoulders in opposite pattern and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/DBArnoldPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Arnold Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Front Raise', 'Grasp dumbbells in both hands. Position dumbbells in front of upper legs with elbows straight or slightly bent.', 'Raise dumbbells forward and upward until upper arms are above horizontal. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/DBFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Alternating Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Alternating Front Raise', 'Grasp dumbbells in both hands. Position dumbbells in front of upper legs with elbows straight or slightly bent.', 'Raise one dumbbell forward and upward with palms positioned downward until upper arm is above horizontal. Lower and repeat with opposite arm, alternating between arms.', 'https://exrx.net/WeightExercises/DeltoidAnterior/DBAlternatingFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Alternating Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Shoulder Press', 'Position dumbbells to each side of shoulders with elbows below wrists.', 'Press dumbbells upward until arms are extended overhead. Lower to sides of shoulders and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/DBShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell One Arm Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell One Arm Shoulder Press', 'Stand with dumbbells positioned near shoulder with elbow below wrists.', 'Press dumbbell upward until arm is extended overhead. Lower to side of shoulder and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/DBOneArmShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Coracobrachialis', 'secondary'), ('Obliques', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell One Arm Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Reclined Shoulder Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Reclined Shoulder Press (plate loaded)', 'Lie on back pad facing up. Grasp lever handles on each side with overhand grip.', 'Press lever until arms are extended. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/LVReclinedShoulderPressPL', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Reclined Shoulder Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shoulder Press', 'Set and grasp lever handles to each side with overhand grip.', 'Press lever upward until arms are extended overhead. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/LVShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Shoulder Press (parallel grip)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Shoulder Press (parallel grip)', 'Sit on seat and grasp parallel bar grips in front of shoulders on each side.', 'Press lever upward until arms are extended overhead. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/LVShoulderPressParGrip', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Shoulder Press (parallel grip)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Shoulder Press', 'Set and grasp lever handles to each side with overhand grip.', 'Press handles upward until arms are extended overhead. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/SLShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Shoulder Press', 'Sit on bench with bar positioned in front of shoulders. Grasp bar with wide overhand grip. Disengage bar by raising and rotating bar back.', 'Press bar upward until arms are extended overhead. Lower bar to front of shoulders and repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/SMShoulderPress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Pike Press (between benches)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Pike Press (between benches)', 'Kneel on two benches positioned side by side slightly apart at end nearest head. Place hands on ends of benches. With forefeet on opposite ends of bench, raise rear end high up with arms, back, and knees straight. Adjust feet so they are somewhat close to hands while keeping back and legs straight.', 'Lower head between ends of benches by bending arms. Push body back up to original position by extending arms. Repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/BWPikePress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Pike Press (between benches)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Elevated Pike Press (between benches)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Elevated Pike Press (between benches)', 'Stand between two incline benches positioned side by side slightly apart at end nearest head. Place hands on ends of benches and straighten arms. Position forefeet on opposite ends of bench. Raise rear end high up with arms, back, and knees straight.', 'Lower head between ends of benches by bending arms. Push body back up to original position by extending arms. Repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/BWDeclinePikePress', 'Shoulders', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Triceps Brachii', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Elevated Pike Press (between benches)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Front Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Front Raise', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body reclines back behind suspension handles. Position body and legs straight at desired angle, hanging from handles with arms straight and palms facing downward.', 'Raise arms upward overhead by flexing shoulders with arms straight. Return and lower body back until arms are extended straight forward in original position. Repeat.', 'https://exrx.net/WeightExercises/DeltoidAnterior/STFrontRaise', 'Shoulders', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Front Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Doorway Front Deltoid Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Doorway Front Deltoid Stretch', 'Stand at end of wall or in doorway facing perpendicular to wall. Position palm on surface of wall slightly lower than shoulder. Bend elbow slightly.', 'Turn body away from positioned arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/DeltoidAnterior/Doorway', 'Shoulders', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary')) AS m(name, role)
WHERE e.name = 'Doorway Front Deltoid Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Wall Front Deltoid Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Wall Front Deltoid Stretch', 'Face away from wall. Bend over and place hands slightly wider than shoulder width as high as possible on wall with fingers positioned upward.', 'Bring rear end and back toward wall and squat down. Hold stretch for 20 seconds.', 'https://exrx.net/Stretches/DeltoidAnterior/Wall', 'Shoulders', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary')) AS m(name, role)
WHERE e.name = 'Wall Front Deltoid Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Upright Row', 'Grasp bar with shoulder width or slightly narrower overhand grip.', 'Pull bar to neck with elbows leading. Allow wrists to flex as bar rises. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/BBUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Lateral Raise', 'With low pulleys to each side, grasp left stirrup with right hand and right stirrup with left hand. Stand upright.', 'With elbows slightly bent, raise arms to sides until elbows are shoulder height. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/CBLateralRaise', 'Shoulders', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Lateral Raise', 'Grasp stirrup cable attachment. Stand facing with side of resting arm toward low pulley. Grasp ballet bar if available.', 'With elbow slightly bent, raise arm to side away from low pulley until elbow is shoulder height. Lower and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/DeltoidLateral/CBOneArmLateralRaise', 'Shoulders', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Upright Row', 'Grasp cable bar with shoulder width or slightly narrower overhand grip. Stand close to pulley.', 'Pull bar to neck with elbows leading. Allow wrists to flex as bar rises. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/CBUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Upright Row', 'Grasp stirrup on low pulley with overhand grip. Stand with side of arm with stirrup away from pulley machine, arm against front of body. Place other hand on ballet bar or side of pulley column for support.', 'Pull stirrup to front side of chest with elbow leading. Allow wrist to flex as stirrup is lifted. Lower and repeat. Position body in opposite orientation and continue with other arm.', 'https://exrx.net/WeightExercises/DeltoidLateral/CBOneArmUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Upright Row (with rope attachment)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Upright Row (with rope attachment)', 'Grasp each side of rope with overhand grip, just under rope ends. Stand close to pulley.', 'Pull rope ends to front of shoulders with elbows leading. Allow wrists to flex as stirrups are lifted. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/CBUprightRowRope', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Upright Row (with rope attachment)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Incline Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Incline Lateral Raise', 'Grasp dumbbell in one hand. Lie on 30° to 45° incline bench with opposite side of body on incline, arm over top of bench, lower leg positioned on front side of seat, and upper leg on back side of seat. Position dumbbell inside of lower leg, just in front of upper leg.', 'Raise dumbbell from until upper arm is perpendicular to torso. Maintain slight fixed bend in elbow throughout exercise. Lower dumbbell to front of upper leg and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/DBInclineLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Posterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Wrist Extensors', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Incline Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lateral Raise', 'Grasp dumbbells in front of thighs with elbows slightly bent. Bend over slightly with hips and knees bent slightly.', 'Raise upper arms to sides until slightly bent elbows are shoulder height while maintaining elbows'' height above or equal to wrists. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/DBLateralRaise', 'Shoulders', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lying Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lying Lateral Raise', 'Lie on side with legs separated for support. Grasp dumbbell in front of thigh.', 'Raise dumbbell from floor until arm is vertical. Maintain fixed elbow position (10° to 30° angle) throughout exercise. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/DBLyingLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Posterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Wrist Extensors', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lying Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Upright Row', 'Grasp dumbbells and stand with palms facing front of thighs.', 'Pull dumbbells to front of shoulders or front sides of chest with elbows leading out to sides. Allow wrists to flex as dumbbells rise upward. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/DBUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell One Arm Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell One Arm Upright Row', 'Grasp dumbbells with palms facing front of thighs. Position other hand for support.', 'Pull dumbbell to front side of chest with elbow leading. Allow wrist to flex as dumbbell rises upward. Lower and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/DeltoidLateral/DBOneArmUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell One Arm Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Lateral Raise', 'Sit in machine. Situate bent arms between padded lever and sides of body. Grasp handles if available.', 'Raise arms to sides until upper arms are horizontal. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/LVLateralRaise2', 'Shoulders', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Upright Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Upright Row', 'Stand behind bar mid-thigh height. Grasp bar with shoulder width or slightly narrower overhand grip. Disengage bar by rotating bar back and stand upright.', 'Pull bar to neck with elbows leading. Allow wrists to flex as bar rises. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/SMUprightRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Upright Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Deltoid Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Deltoid Stretch', 'Position arm across chest. Place opposite hand on elbow.', 'Push elbow toward chest. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/DeltoidLateral/SideDelt', 'Shoulders', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary')) AS m(name, role)
WHERE e.name = 'Side Deltoid Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Y Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Y Lateral Raise', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body reclines back behind suspension handles. Position body and legs straight at desired angle hanging from handles with arms straight and palms angled inward.', 'Raise arms upward and outward in shape of a Y while keeping arms straight. Return and lower body back in opposite motion until arms are extended straight forward in original position. Repeat.', 'https://exrx.net/WeightExercises/DeltoidLateral/STYShoulderRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Lateral', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Teres Minor', 'secondary'), ('Infraspinatus', 'secondary'), ('Coracobrachialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Y Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Rear Delt Row', 'Bend knees slightly and bend over bar with back straight, approximately horizontal. Grasp bar with wide overhand grip.', 'Keeping upper arm perpendicular to torso, pull barbell up toward upper chest until upper arms are just beyond horizontal. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/BBRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Rear Delt Row', 'Sit slightly forward on bench or platform in order to grasp cable bar attachment. With elbow width overhand grip, straighten torso upright and slide hips back until knees are only slightly bent.', 'Pull cable attachment toward upper chest, just below neck, with elbows up out to sides until elbows travel slightly behind back. Keep upper arms horizontal, perpendicular to trunk. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/CBRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Standing Rear Delt Row (with rope)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Standing Rear Delt Row (with rope)', 'Stand facing rope attachment on pulley cable positioned head height or slightly higher. Grasp each end of rope just above enlarged ends. Step back with one foot so arms and shoulders are positioned straight forward with cable taut. Lean back slightly and point elbows outward.', 'Pull rope to upper chest or neck, keeping elbows at shoulder height until elbows travel slightly behind back. Keep upper arms perpendicular to trunk. Return until arms are extended forward. Repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/CBStandingRearDeltRowRope', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Standing Rear Delt Row (with rope)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Standing Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Standing Rear Delt Row', 'Stand facing twin pulley cables positioned shoulder height. Grasp stirrup cable attachment in each hand. Step back with one foot so arms and shoulders are positioned straight forward with cable taut. Point elbows outward.', 'Pull stirrups out to sides, keeping elbows at shoulder height until elbows travel slightly behind back. Allow wrists to follow elbows. Keep upper arms horizontal, perpendicular to trunk. Return until arms are extended and shoulders are stretched forward. Repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/CBStandingRearDeltRowStirrups', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Standing Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Rear Delt Row', 'Kneel over side of bench with arm and leg to side. Grasp dumbbell.', 'Pull dumbbell up out to side with upper arm perpendicular to trunk until upper arm is just beyond horizontal. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/DBRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Rhomboids', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Obliques', 'stabilizer'), ('Psoas Major', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Iliocostalis Lumborum', 'stabilizer'), ('Iliocostalis Thoracis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Rear Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Rear Lateral Raise', 'Grasp dumbbells to each side. Bend knees and bend over through hips with back flat, close to horizontal. Position elbows with slight bend and palms facing together.', 'Raise upper arms to sides until elbows are shoulder height. Maintain upper arms perpendicular to torso and fixed elbow position (10° to 30° angle) throughout exercise. Maintain height of elbows above wrists by raising "pinkie finger" side up. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/DBRearLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Wrist Extensors', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Rear Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Seated Rear Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Seated Rear Lateral Raise', 'Sit on edge of bench with feet placed beyond knees. Bend over and rest torso on thighs. Grasp dumbbells with each hand under legs. Position elbows with slight bend with palms facing together behind ankles (as shown) or just to sides of ankles.', 'Raise upper arms to sides until elbows are shoulder height. Maintain upper arms perpendicular to torso and fixed elbow position (10° to 30° angle) throughout exercise. Maintain elbows height above wrists by raising "pinkie finger" side up. Lower and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/DBSeatedRearLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Triceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Seated Rear Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Rear Delt Row (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Rear Delt Row (plate loaded)', 'Place seat at low position. Sit on seat with chest against pad and grasp upper handles.', 'Pull lever with elbows up out to sides until upper arms are just beyond parallel, keeping upper arm horizontal, perpendicular to torso. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/LVRearDeltRowC', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Deltoid, Lateral', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Rear Delt Row (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Rear Delt Row', 'Place seat at low position. Sit on seat with chest against pad and grasp upper handles.', 'Pull lever with elbows up out to sides until upper arms are just beyond parallel, keeping upper arm horizontal, perpendicular to torso. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/LVRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Biceps Brachii', 'secondary'), ('Deltoid, Lateral', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Seated Reverse Fly (pronated parallel grip)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Seated Reverse Fly (pronated parallel grip)', 'Sit in machine with chest against pad. Grasp parallel handles from inside with thumbs down at shoulder height.', 'Keeping elbows pointed high, pull handles apart and to rear until elbows are just behind back. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/LVReverseFlyPronated', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Triceps Brachii', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Seated Reverse Fly (pronated parallel grip)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Rear Delt Row', 'Stand near low smith bar. Bend knees and bend over bar with back straight. Grasp bar with wide overhand grip. Disengage bar by rotating bar back.', 'Keeping upper arm perpendicular to torso, pull bar up toward upper chest until upper arms are just beyond parallel to floor. Return and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/SMRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Rhomboids', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Rear Delt Inverted Row (high bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Rear Delt Inverted Row (high bar)', 'Stand facing horizontal bar positioned lower to upper chest height. Step toward bar so chest makes contact. Grasp bar with wide overhand grip. Raise elbows up to shoulder height. Place feet forward on floor so body is reclined back with legs, hips and spine straight.', 'Lower body while keeping body straight, elbows high, and upper arms perpendicular to torso, until arms are extended straight. Pull shoulders toward bar while keeping elbows up high until upper arms are parallel to one another, or just beyond. Repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/BWRearDeltInvertedRowHigh', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Rear Delt Inverted Row (high bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Rear Delt Row
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Rear Delt Row', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body reclines back behind suspension handles.  
Position body and legs straight at desired angle hanging from handles with arms straight. Internally rotate shoulders so elbows are positioned directly outwards.', 'Pull body up while keeping elbows pointed directly out to each side and body and legs straight. Pull until elbows are directly lateral to each side without allowing elbows to drop. Return until arms are extended straight and shoulders are stretched forward, maintaining high elbow position. Repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/STRearDeltRow', 'Shoulders', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Rear Delt Row' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Reverse Fly
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Reverse Fly', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body reclines back behind suspension handles. Position body and legs straight at desired angle hanging from handles with arms straight. Internally rotate shoulders so elbows are positioned directly outwards with arms straight or slightly bent. Shoulder should be positioned approximately 90° relative to torso position.', 'Pull handles out to sides while keeping stiff elbow position and maintaining shoulder at 90° plane to torso throughout exercise. Raise up until upper arms are in-line to one another. Return to original position in same plane and repeat.', 'https://exrx.net/WeightExercises/DeltoidPosterior/STReverseFly', 'Shoulders', 'compound', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary'), ('Infraspinatus', 'secondary'), ('Teres Minor', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Rhomboids', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Reverse Fly' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Rear Deltoid Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Rear Deltoid Stretch', 'Position arm across neck. Place opposite hand on elbow.', 'Push elbow toward neck. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/DeltoidPosterior/RearDelt', 'Shoulders', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Posterior', 'primary')) AS m(name, role)
WHERE e.name = 'Rear Deltoid Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Front Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Front Lateral Raise', 'Grasp dumbbell cable attachment. Stand facing side with resting arm toward low pulley. Grasp ballet bar if available for support. Internally rotate shoulders so elbows point out to sides.', 'With elbow straight or slightly bent, raise upper arm away from low pulley to side, slightly to front (30°) until upper arm is shoulder height. Lower and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Supraspinatus/CBFrontLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Supraspinatus', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Front Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Front Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Front Lateral Raise', 'Grasp dumbbell and position in front of thigh with arm straight. Turn pinkie finger side outward.', 'Raise arms to side, slightly to front until shoulder height or slightly higher. Lower and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Supraspinatus/DBFrontLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Supraspinatus', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Front Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Full Can Lateral Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Full Can Lateral Raise', 'Grasp dumbbells with each hand with palms facing forward.', 'Raise arms to side with thumb side up. Lower and repeat.', 'https://exrx.net/WeightExercises/Supraspinatus/DBFullCanLateralRaise', 'Shoulders', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Supraspinatus', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Full Can Lateral Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Lunge', '[Clean](../OlympicLifts/Clean) bar from floor or dismount bar from rack. From rack with barbell upper chest height, position bar on back of shoulders and grasp barbell to sides.', 'Lunge forward with first leg. Land on heel, then forefoot. Lower body by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by forcibly extending hip and knee of forward leg. Repeat by alternating lunge with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/BBLunge', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Tibialis Anterior', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Rear Lunge', 'From rack with barbell upper chest height, position bar on back of shoulders and grasp barbell to sides. Dismount bar from rack.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/Quadriceps/BBRearLunge', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Single Leg Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Single Leg Split Squat', 'Stand facing away from bench. Position bar on back of shoulders and grasp barbell to sides. Extend leg back and place top of foot on bench.', 'Squat down by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/BBSingleLegSplitSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Single Leg Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Split Squat', 'Position barbell on back of shoulders and grasp barbell to sides. Stand with feet far apart; one foot forward and other foot behind.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/BBSplitSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Squat', 'From rack with barbell at upper chest height, position bar high on back of shoulders and grasp barbell to sides. Dismount bar from rack and stand with shoulder width stance.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/BBSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Front Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Front Squat', 'From rack with barbell upper chest height, position bar in front of shoulders. Cross arms and place hands on top of barbell with upper arms parallel to floor. Dismount bar from rack.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/BBFrontSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Supraspinatus', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Front Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Trap Bar Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Trap Bar Squat', 'Stand on platform under loaded trap bar. Squat down until thighs are just past parallel to floor with knees pointed same direction as feet and feet flat on platform. Grasp handles to sides. Posture chest up with back arched tightly.', 'Lift weight upward by extending knees and hips until straight. Pull shoulders back at top of lift if rounded. Return weights to floor by bending hips back while allowing knees to bend forward. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/TBSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Trap Bar Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Step-up', 'Stand facing side of bench. Position bar on back of shoulders and grasp barbell to sides.', 'Place foot of first leg on bench. Stand on bench by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to floor. Repeat first step with opposite leg, alternating first steps between legs.', 'https://exrx.net/WeightExercises/Quadriceps/BBStepUp', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Rear Lunge', 'Stand between two very low pulleys with shoulder width or narrower stance. Squat down and grasp stirrup attachments to each side. Stand upright with arms straight down to sides.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/Quadriceps/CBRearLunge', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Split Squat', 'Stand between two very low cable pulleys. Grasp stirrup attachments with each hand. Place one leg forward and opposite leg back to rear.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original straddle position by extending hip and knee of forward leg. Repeat. Continue with legs in opposite position.', 'https://exrx.net/WeightExercises/Quadriceps/CBLungeTwoArm', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Squat', 'Stand with feet shoulder width or slightly wider on platform between very low and close pulley cables. Squat down with knees slightly beyond foot, hips bent back behind, back straight, knees pointed same direction as feet, and shoulder above feet. Grasp stirrups to each side with arms straight.', 'Keeping chest high and back straight, raise stirrups by extending knees and hips until legs are straight. Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Squat down until thighs are just past parallel to floor. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/CBSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Step Down
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Step Down', 'Grasp cable stirrup(s) with both hands. Place one foot on elevated platform positioned near or between low pulleys.', 'Raise body by extending knee and hip on platform until leg is straight. Return until foot of lower leg makes contact with lower platform or floor and repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/CBSingleLegSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Step Down' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Step-up', 'Stand behind elevated platform and low and close pulley cables to sides. Grasp stirrups at each side of platform. Stand upright with arms straight down at sides.', 'Place foot of first leg on elevated platform. Stand on elevated platform by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to lower position. Repeat first step with opposite leg, alternating first steps between legs.', 'https://exrx.net/WeightExercises/Quadriceps/CBStepUp', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lunge', 'Stand with dumbbells grasped to sides.', 'Lunge forward with first leg. Land on heel, then forefoot. Lower body by flexing knee and hip of front leg until knee of rear leg is almost in contact with floor. Return to original standing position by forcibly extending hip and knee of forward leg. Repeat by alternating lunge with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/DBLunge', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Tibialis Anterior', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Rear Lunge
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Rear Lunge', 'Stand with dumbbells grasped to sides.', 'Step back with one leg while bending supporting leg. Plant forefoot far back on floor. Lower body by flexing knee and hip of supporting leg until knee of rear leg is almost in contact with floor. Return to original standing position by extending hip and knee of forward supporting leg and return rear leg next to supporting leg. Repeat movement with opposite legs alternating between sides.', 'https://exrx.net/WeightExercises/Quadriceps/DBRearLunge', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Rear Lunge' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Split Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Split Squat', 'Stand with dumbbells grasped to sides. Position feet far apart; one foot forward and other foot behind.', 'Squat down by flexing knee and hip of front leg. Allow heel of rear foot to rise up while knee of rear leg bends slightly until it almost makes contact with floor. Return to original standing position by extending hip and knee of forward leg. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/DBSplitSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Split Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Squat', 'Stand with dumbbells grasped to sides.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/DBSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Front Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Front Squat', 'Stand with dumbbells grasped to sides. Clean dumbbells up to shoulders so side of each dumbbell rests on top of each shoulder. Balance dumbbells on shoulder by holding on to dumbbells with elbows flaring outward. Position feet shoulder width or slightly narrower apart.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/DBFrontSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Front Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Step-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Step-up', 'Stand with dumbbells grasped to sides facing side of bench.', 'Place foot of first leg on bench. Stand on bench by extending hip and knee of first leg and place foot of second leg on bench. Step down with second leg by flexing hip and knee of first leg. Return to original standing position by placing foot of first leg to floor. Repeat first step with opposite leg alternating first steps between legs.', 'https://exrx.net/WeightExercises/Quadriceps/DBStepUp', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Hamstrings', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer'), ('Rectus Abdominis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Step-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Step Down
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Step Down', 'Hold dumbbells in each hand down to sides and stand with one foot on bench. Position foot on bench to side slightly forward of straight knee.', 'Stand on bench by straightening leg and pushing body upward. Step down returning foot off of bench to floor and repeat. Continue with opposite position.', 'https://exrx.net/WeightExercises/Quadriceps/DBStepDown', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Step Down' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Premium Content
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Premium Content', NULL, NULL, 'https://exrx.net/WeightExercises/Quadriceps/LVLegExtensionH', 'Thighs', NULL, NULL, NULL, 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary')) AS m(name, role)
WHERE e.name = 'Premium Content' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever 45° Leg Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever 45° Leg Press (plate loaded)', 'Sit on machine with back on padded support. Place feet on platform. Extend hips and knees. Release dock lever and grasp handles to sides.', 'Lower platform by flexing hips and knees until hips are completely flexed. Return by extending knees and hips. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LV45LegPress', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever 45° Leg Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lying Leg Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lying Leg Press (plate loaded)', 'Climb up steps to top of machine. Lie supine on horizontal padded platform with shoulders against pad. Place feet equally spaced on platform. Grip handles above shoulder pads.', 'Push lever platform away by extending hips and knees until knees are straight. Return lever platform by flexing hips and knees until knees are just short of complete flexion or until hips are completely flexed. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVLyingLegPressH', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Lying Leg Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Leg Press (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Leg Press (plate loaded)', 'Sit on machine with back on padded support. Place feet on platform. Grasp handles to sides.', 'Push platform(s) away by extending knees and hips until knees are fully extended. Return until hips are completely flexed. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVSeatedLegPressH', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Leg Press (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Single Leg Squat (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Single Leg Squat (plate loaded)', 'Stand between handles facing away from fulcrum. Grasp both handles to sides and stand upright. Cross lower leg above knee of supporting leg.', 'Bend knees forward slightly while allowing hips to bend back behind, keeping back straight and knees pointed same direction as feet. Squat down as low as possible. Extend knee and hip until leg is straight. Return and repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/LVSingleLegSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Hamstrings', 'secondary'), ('Gastrocnemius', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Single Leg Squat (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Split Squat (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Split Squat (plate loaded)', 'Stand between lever handles to sides. Place forefoot of one foot on floor to rear and other foot slightly forward. Squat down and grasp handles to sides.', 'With chest high, lift lever by extending hips and knees to full extension. Return until knee of rear leg is almost in contact with floor. Repeat. Continue with opposite leg.', 'https://exrx.net/WeightExercises/Quadriceps/LVSplitSquat', 'Thighs', 'compound', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Split Squat (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Squat (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Squat (plate loaded)', 'Squat down to place shoulders under padded lever. Place feet shoulder width apart directly under shoulders. Extend knees and hips until legs are straight. Release support lever.', 'Lower lever by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Lift lever up by extending knees and hips until legs are straight. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVSquatPL', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Squat (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Barbell Squat (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Barbell Squat (plate loaded)', 'With bar upper chest height, position bar on back of shoulders and grasp bar to sides. Place feet under bar. Disengage bar by rotating bar back.', 'Squat down by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Extend knees and hips until legs are straight. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVBBSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Barbell Squat (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Leg Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Leg Extension', 'Sit on apparatus with back against padded back support. Place front of lower legs under padded lever. Position knee articulation at same axis as lever fulcrum. Grasp handles to sides for support.', 'Move lever forward and upward by extending knees until legs are straight. Return lever to original position by bending knees. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVLegExtension', 'Thighs', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Brachioradialis', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Biceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Leg Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Leg Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Leg Press', 'Sit on machine with back on padded support. Place feet on platform. Grasp handles to sides.', 'Push platform away by extending knees and hips. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVSeatedLegPress', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Leg Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Squat', 'Squat down to place shoulders under padded lever. Place feet shoulder width apart directly under shoulders.', 'Lift lever up by extending knees and hips until legs are straight. Lower lever by bending hips back while allowing knees to bend forward, keeping back straight and knees pointed same direction as feet. Descend until thighs are just past parallel to floor. Return and repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever V-Squat
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever V-Squat', 'Position shoulders under shoulder pads with back against back pad. Place feet on platform, shoulder or hip width apart. Squeeze hand lever. Keeping hand lever squeezed, squat down by bending hips and knees until knees or hips are just short of complete flexion. Release hand lever and raise up on sled just slightly until weight stack is engaged (click is heard).', 'Raise sled by extending knees and hips until legs are straight. Squat down with knees pointed same direction as feet. Descend until knees or hips are near complete flexion. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/LVVSquat', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever V-Squat' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled 45° Leg Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled 45° Leg Press', 'Sit on machine with back on padded support. Place feet on platform. Extend hips and knees. Release dock lever and grasp handles to sides.', 'Lower sled by flexing hips and knees until knees are just short of complete flexion. Return by extending knees and hips. Repeat.', 'https://exrx.net/WeightExercises/Quadriceps/SL45LegPress', 'Thighs', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Quadriceps', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Soleus', 'secondary')) AS m(name, role)
WHERE e.name = 'Sled 45° Leg Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Triceps Dip', 'Mount [shoulder width dip bar](../../WeightTraining/Tips#DipBar), arms straight with shoulders above hands. Step down onto assistance lever. Keep hips and knees straight.', 'Lower body until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/ASTriDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Machine-assisted Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Machine-assisted Triceps Dip (kneeling)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Machine-assisted Triceps Dip (kneeling)', 'Mount [shoulder width dip bar](../../WeightTraining/Tips#DipBar), arms straight with shoulders above hands. Kneel on padded platform, lowering it down slightly so hips are slightly bent.', 'Lower body until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/ASTriDipKneeling', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Assisted') FROM ex WHERE pg_temp.get_eq('Assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Machine-assisted Triceps Dip (kneeling)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Close Grip Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Close Grip Bench Press', 'Lie on bench and grasp barbell from rack with shoulder width grip.', 'Lower weight to chest with elbows close to body. Push barbell back up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BBCloseGripBenchPress', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary')) AS m(name, role)
WHERE e.name = 'Barbell Close Grip Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Lying Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Lying Triceps Extension', 'Lie on bench with narrow overhand grip on barbell. Position barbell over forehead with arms extended.', 'Lower bar by bending elbows. As bar nears head, move elbows slightly back just enough to allow bar to clear around curvature of head. Extend arms. As bar clears head, reposition elbows to their former position until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BBLyingTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Lying Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Lying Triceps Extension "Skull Crusher"
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Lying Triceps Extension "Skull Crusher"', 'Lie on bench with narrow overhand grip on barbell. Position barbell over shoulders with arms extended.', 'Lower bar to forehead by bending elbows. Extend arms and repeat.', 'https://exrx.net/WeightExercises/Triceps/BBLyingTriExtSC', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Lying Triceps Extension "Skull Crusher"' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Triceps Extension', 'Sit on utility weight bench with barbell. Position barbell overhead with narrow overhand grip.', 'Lower barbell behind upper shoulders by flexing elbows allowing forearms to travel behind upper arms with elbows remaining overhead. Raise barbell overhead by extending elbows until arms are positioned straight and vertical. Lower and repeat.', 'https://exrx.net/WeightExercises/Triceps/BBTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Bent-over Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Bent-over Triceps Extension', 'Grasp cable bar from medium-high pulley with narrow or shoulder width overhand grip. Turn body away from pulley apparatus and position turned cable bar behind neck. Bend over downward with cable bar positioned behind neck, gripped at each side. Lunge forward with one leg. Allow elbows to be pulled back under cable resistance.', 'Extend forearms forward until elbows are straight. Allow cable bar to return back over neck. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBBentoverTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Bent-over Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Lying Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Lying Triceps Extension', 'Lie on bench and grasp bar with narrow overhand grip. With arms extended, position bar over face.', 'Lower bar by bending elbow. As bar nears head, move elbows slightly back just enough to allow bar to clear around curvature of head. Extend arm. As bar clears head, reposition elbows to its former position until arm is fully extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBLyingTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Lying Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Pushdown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Pushdown', 'Face high pulley and grasp cable attachment with narrow overhand grip. Position elbows to side.', 'Extend arms down. Return until forearm is close to upper arm. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBPushdown', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Pushdown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Pushdown
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Pushdown', 'Grasp dumbbell cable attachment with underhand grip. Position elbow to side.', 'Extend arm down. Return until forearm is close to upper arm. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Triceps/CBOneArmPushdown', 'Upper Arms', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Obliques', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Wrist Extensors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Pushdown' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Pushdown (with back support)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Pushdown (with back support)', 'Place back against vertical back support. Grasp cable attachment from high pulley with narrow overhand grip. Position elbows to side.', 'Extend arms down. Return until forearm is close to upper arm. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBPushdownSupport', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Pushdown (with back support)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Pushdown (with V-bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Pushdown (with V-bar)', 'Face high pulley and grasp V-bar attachment with narrow overhand grip. Position elbows to side.', 'Extend arms down. Return until forearm is close to upper arm. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBPushdownVBar', 'Upper Arms', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Pushdown (with V-bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Triceps Dip', 'Step between [shoulder width dip bars](../../WeightTraining/Tips#DipBar) with dip belt around waist. Kneel as close to low pulley and attach cable to dip belt. Stand up and mount dip bar, arms straight with shoulders above hands. Keep hips straight.', 'Lower body by bending arms until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBTriDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Triceps Extension', 'Stand or sit on bench or seat with back support just below shoulders. Position cable bar behind neck or shoulders with narrow overhand grip. Position elbows overhead.', 'Raise cable bar overhead by extending elbows until arms are positioned straight and vertical. Lower cable bar behind neck by flexing elbows allowing forearms to travel behind upper arms with elbows remaining overhead. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Triceps Extension (with rope)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Triceps Extension (with rope)', 'From low pulley cable, grasp ends of rope attachment just under enlarged ends. Raise one arm over head while turning body away from pulley. Face away from pulley with feet staggered. Position ends of ropes behind head or neck and elbows upward over head.', 'Raise ends of rope overhead by extending forearms until arms are straight. Lower rope attachment until forearms are against upper arms. Repeat.', 'https://exrx.net/WeightExercises/Triceps/CBStandingTricepsExtensionRope', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Triceps Extension (with rope)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Kickback
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Kickback', 'Kneel over bench with arm supporting body. Grasp dumbbell. Position upper arm parallel to floor.', 'Extend arm until it is straight. Return and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Triceps/DBKickback', 'Upper Arms', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Extensor Carpi Ulnaris', 'stabilizer'), ('Flexor Carpi Ulnaris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Kickback' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Lying Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Lying Triceps Extension', 'Lie on bench and position dumbbells over head with arms extended.', 'Lower dumbbells by bending elbow until they are to sides of head. Extend arm. Repeat.', 'https://exrx.net/WeightExercises/Triceps/DBLyingTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Extensor Carpi Ulnaris', 'stabilizer'), ('Flexor Carpi Ulnaris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Lying Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell One Arm Triceps Extension (on bench)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell One Arm Triceps Extension (on bench)', 'Position dumbbell behind neck with elbow positioned upward.', 'Extend arm until straight while maintaining upper arm''s vertical position throughout exercise. Return until dumbbell is behind neck or shoulder and repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Triceps/DBOneArmTriExtBench', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Wrist Extensors', 'stabilizer'), ('Flexor Carpi Ulnaris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell One Arm Triceps Extension (on bench)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Triceps Extension', 'Position one dumbbell over head with both hands under inner plate (heart shaped grip).', 'With elbows over head, lower forearm behind upper arm by flexing elbows. Flex wrists at bottom to avoid hitting dumbbell on back of neck. Raise dumbbell over head by extending elbows while hyperextending wrists. Return and repeat.', 'https://exrx.net/WeightExercises/Triceps/DBTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Dip (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Dip (plate loaded)', 'Sit upright on seat. If possible, place handles in narrow position. Grasp handles.', 'Push levers down with elbows pointing back. Allow lever bar to raise until shoulders are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriDipH', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Dip (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Extension (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Extension (plate loaded)', 'Sit on seat. Place forearms on lever pad and back of upper arms, parallel on padding with elbows in line with lever''s fulcrum.', 'Push lever down until arms are fully extended. Return and repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriExtGripless', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Extension (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Dip', 'If possible, place handles in narrow position. Sit on seat with back against pad. Grasp handles and position elbows back.', 'Push levers down by straightening arms downward. Allow lever bar to raise with elbows pointing back until shoulders are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Dip', 'If possible, place handles in narrow position. Sit on seat with legs under pads. Grasp handles and position elbows back.', 'Push levers down by straightening arms downward. Allow lever bar to raise with elbows pointing back until shoulders are slightly stretched. Repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriDip2', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Extension', 'Sit on seat. Grasp handles and place back of upper arms parallel on padding with elbows approximately in line with lever''s fulcrum.', 'Push lever down until arms are fully extended. Return until forearms contact upper arms. Repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriExt', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Extensor Carpi Ulnaris', 'stabilizer'), ('Flexor Carpi Ulnaris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Triceps Extension (with preacher pad)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Triceps Extension (with preacher pad)', 'Sit on seat. Grasp handles and place back of upper arms parallel on padding with elbows approximately in line with lever''s fulcrum.', 'Push lever down until arms are fully extended. Return until forearms contact upper arms. Repeat.', 'https://exrx.net/WeightExercises/Triceps/LVTriExtPreacherPad', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Extensor Carpi Ulnaris', 'stabilizer'), ('Flexor Carpi Ulnaris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Triceps Extension (with preacher pad)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Standing Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Standing Triceps Dip', 'Stand between handles facing machine. Grasp parallel handles and position elbows back. Squat down slightly by bending hips and knees, just enough to raise selected weight up from remaining weight stack.', 'Push levers down by straightening arms downward. Allow lever bar to raise with elbows pointing back until slight stretch is felt in shoulders. Repeat.', 'https://exrx.net/WeightExercises/Triceps/SLStandingTricepsDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Standing Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Close Grip Bench Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Close Grip Bench Press', 'Lie on bench with bar above chest and grasp bar with shoulder width or slightly narrower grip. Disengage bar by rotating bar back.', 'Lower weight to chest with elbows close to body. Push bar back up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/SMCloseGripBenchPress', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary')) AS m(name, role)
WHERE e.name = 'Smith Close Grip Bench Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Bench Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Bench Dip', 'Sit on inside of one of two benches placed parallel, slightly less than leg''s length away. Place hands on edge of bench. Straighten arms, slide rear end off of edge of bench and position heels on adjacent bench with legs straight. Have assistant place weight on lap near hips.', 'Lower body by bending arms until slight stretch is felt in chest or shoulder, or rear end touches floor. Raise body and repeat.', 'https://exrx.net/WeightExercises/Triceps/WtBenchDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Bench Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Triceps Dip', 'Place weight on dip belt around waist or place dumbbell between lower legs just above feet. Mount [shoulder width dip bar](../../WeightTraining/Tips#DipBar), arms straight with shoulders above hands. Keep hips straight.', 'Lower body until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/WtTriDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Band-assisted Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Band-assisted Triceps Dip', 'Place one foot on middle of exercise band with ends looped on [shoulder width dip bars](../../WeightTraining/Tips#DipBar). Push band down partially by extending leg. Mount dip bar with arms straight and shoulders above hands. Place other foot on exercise band next to other foot. Keep hips straight.', 'Lower body until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/ASTricepsDipBand', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Band Resistive') FROM ex WHERE pg_temp.get_eq('Band Resistive') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Band-assisted Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Bench Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Bench Dip', 'Sit on inside of one of two benches placed parallel, slightly less than leg''s length away. Place hands on edge of bench, straighten arms, slide rear end off of bench, and position heels on adjacent bench with legs straight.', 'Lower body by bending arms until slight stretch is felt in chest or shoulder, or rear end touches floor. Raise body and repeat.', 'https://exrx.net/WeightExercises/Triceps/BWBenchDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Bench Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Bench Dip (heels on floor)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Bench Dip (heels on floor)', 'Sit on side of bench. Place hands on edge of bench. Position feet away from bench. Straighten arms, slide rear end off of edge of bench, and rest heels on floor with legs straight.', 'Lower body by bending arms until slight stretch is felt in chest or shoulder, or rear end touches floor. Raise your body and repeat.', 'https://exrx.net/WeightExercises/Triceps/BWBenchDipFloor', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Bench Dip (heels on floor)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Close Grip Push-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Close Grip Push-up', 'Lie prone with forefeet on floor and hands under shoulders or slightly narrower. Position body up off floor with extended arms and body straight.', 'Keeping body straight, lower body to floor by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BWCloseGripPushup', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Close Grip Push-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Close Grip Incline Push-up (on bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Close Grip Incline Push-up (on bar)', 'Grasp horizontal bar (lower than chest height) with hands shoulder width or slightly narrower. Position forefeet back from bar with arms and body straight. Arms should be perpendicular to body.', 'Keeping body straight, lower chest to bar by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BWCloseGripInclinePushupBar', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Gastrocnemius', 'stabilizer'), ('Soleus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Close Grip Incline Push-up (on bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Close Grip Push-up (on knees)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Close Grip Push-up (on knees)', 'Lie prone on floor with hands under shoulders or slightly narrower. Position body up off floor with extended arms and body straight.', 'Keeping body straight, lower body to floor by bending arms. Push body up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BWCloseGripPushupKnees', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Coracobrachialis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Close Grip Push-up (on knees)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Triceps Dip', 'Mount [shoulder width dip bar](../../WeightTraining/Tips#DipBar), arms straight with shoulders above hands. Keep hips straight.', 'Lower body until slight stretch is felt in shoulders. Push body up until arms are straight. Repeat.', 'https://exrx.net/WeightExercises/Triceps/BWTriDip', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Triceps Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Triceps Extension', 'Grasp handles and step forward between suspension trainers. Position arms downward and slightly forward, nearly parallel with suspension straps. Lean forward, placing upper body weight onto handles with arms straight, while stepping back onto forefeet so body is leaning forward at desired angle. Straighten body, so torso is in-line with legs.', 'Lower body by bending elbows, allowing head to travel between suspension handles. Raise body up and back up until arms are extended. Repeat.', 'https://exrx.net/WeightExercises/Triceps/STTricepsExtension', 'Upper Arms', 'isolated', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Gastrocnemius', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Triceps Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Self-assisted Triceps Dip
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Self-assisted Triceps Dip', 'Stand on bench or elevation between parallel bars. Mount [shoulder width dip bar](../../WeightTraining/Tips#DipBar), arms straight with shoulders above hands. Bend knees and place toes on bench or elevation behind and below body.', 'Lower body by bending arms back. If necessary, use minimal assistance of lower body to control descent, allowing knees to bend, keeping toes in contact with bench or elevation. When slight stretch is felt in chest or shoulders push body up until arms are straight. Repeat with minimal assistance from legs.', 'https://exrx.net/WeightExercises/Triceps/ASTricepsDipSelf', 'Upper Arms', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Self-assisted') FROM ex WHERE pg_temp.get_eq('Self-assisted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary'), ('Deltoid, Anterior', 'secondary'), ('Pectoralis Major, Sternal', 'secondary'), ('Pectoralis Major, Clavicular', 'secondary'), ('Pectoralis Minor', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Self-assisted Triceps Dip' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Overhead Triceps Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Overhead Triceps Stretch', 'Put one arm overhead. Position forearm as close as possible to upper arm. Grasp elbow overhead with other hand.', 'Pull elbow back and toward head. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/Triceps/Overhead', 'Upper Arms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary')) AS m(name, role)
WHERE e.name = 'Overhead Triceps Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Towel Triceps Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Towel Triceps Stretch', 'Grasp near end of towel or rope. Position towel behind head so towel dangles down behind body. Reach behind back or waist with opposite hand and grasp opposite end of towel. Position upper arm close to back side of head.', 'Pull towel downward with lower arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/Triceps/Towel', 'Upper Arms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Triceps Brachii', 'primary')) AS m(name, role)
WHERE e.name = 'Towel Triceps Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Curl', 'Grasp bar with shoulder width underhand grip.', 'With elbows to side, raise bar until forearms are vertical. Lower until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Biceps/BBCurl', 'Upper Arms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Curl', 'Grasp low pulley cable bar with shoulder width underhand grip. Stand close to pulley.', 'With elbows to side, raise bar until forearms are vertical. Lower until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Biceps/CBCurl', 'Upper Arms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Curl', 'Stand between or facing double low pulleys. Grasp stirrups to each side, palms facing forward.', 'Pull stirrups forward and upward toward shoulders while keeping elbows stationary. Return until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Biceps/CBCurlStirrups', 'Upper Arms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable One Arm Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable One Arm Curl', 'Face low pulley and grasp stirrup cable attachment to one side with underhand grip.', 'With elbow to side, raise bar until forearms are vertical. Lower until arms are fully extended. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Biceps/CBOneArmCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable One Arm Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Curl', 'Position two dumbbells to sides, palms facing in, arms straight.', 'With elbows to sides, raise one dumbbell and rotate forearm until forearm is vertical and palm faces shoulder. Lower to original position and repeat with opposite arm. Continue to alternate between sides.', 'https://exrx.net/WeightExercises/Biceps/DBCurl', 'Upper Arms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Incline Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Incline Curl', 'Sit back on 45-60 degree incline bench. With arms hanging down straight, position two dumbbells with palms facing inward.', 'With elbows back to sides, raise one dumbbell and rotate forearm until forearm is vertical and palm faces shoulder. Lower to original position and repeat with opposite arm. Continue to alternate between sides.', 'https://exrx.net/WeightExercises/Biceps/DBInclineCurl', 'Upper Arms', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Incline Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Doorway Biceps Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Doorway Biceps Stretch', 'Stand at end of wall or in doorway facing perpendicular to wall. Position front of straight arm and palm on surface of wall. Situate arm around same height of shoulder with elbow positioned away from wall.', 'Turn body away from positioned arm. Hold stretch. Repeat with opposite arm.', 'https://exrx.net/Stretches/Biceps/Doorway', 'Upper Arms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary')) AS m(name, role)
WHERE e.name = 'Doorway Biceps Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Seated Biceps Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Seated Biceps Stretch', 'Sit on floor or mat. Lean back and place hands flat on floor close together behind body with fingers positioned away from body.', 'Scoot hips forward away from hands. Hold stretch.', 'https://exrx.net/Stretches/Biceps/Seated', 'Upper Arms', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Biceps Brachii', 'primary')) AS m(name, role)
WHERE e.name = 'Seated Biceps Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Preacher Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Preacher Curl', 'Sit on preacher bench placing back of arms on pad. Grasp curl bar with shoulder width underhand grip.', 'Raise bar until forearms are vertical. Lower barbell until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/BBPreacherCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Preacher Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Prone Incline Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Prone Incline Curl', 'Lie prone on incline bench with shoulders near top of incline. Knees can rest on seat or legs can be straddled to sides. From low rack or partner, grasp curl bar with shoulder width underhand grip.', 'Raise bar until arms are flexed. Lower barbell until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/BBProneInclineCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Prone Incline Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Concentration Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Concentration Curl', 'Facing low pulley cable, sit on seat or bench with legs apart to each side. Grasp stirrup attachment. Place upper arm against inner thigh.', 'Pull stirrup to front of shoulder until elbow is completely flexed. Lower stirrup until arm is fully extended. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Brachialis/CBConcentrationCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Obliques', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Concentration Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Preacher Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Preacher Curl', 'Sit on preacher bench placing back of arms on pad. Grasp cable bar with shoulder width underhand grip.', 'Raise cable bar toward shoulders. Lower cable bar until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/CBPreacherCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Preacher Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Preacher Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Preacher Curl', 'Grasp cable stirrups with each hand. Sit on preacher bench placing back of arms on pad with palms up.', 'Raise both stirrups upward toward shoulders. Lower stirrups until arm is fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/CBPreacherCurlStirrups', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Preacher Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Preacher Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Preacher Curl', 'Grasp dumbbell and sit on preacher bench. With arm bent and palm facing shoulder, place back of arm down on pad.', 'Lower dumbbell until arm is fully extended. Raise dumbbell until forearm is vertical. Repeat. Continue with opposite arm.', 'https://exrx.net/WeightExercises/Brachialis/DBPreacherCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Preacher Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Isolateral Preacher Curl (arms high, plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Isolateral Preacher Curl (arms high, plate loaded)', 'Sit on curl machine. Grasp lever handles with underhand grip. Align elbows near same pivot point as fulcrum of lever while placing back of arms up on pads.', 'Pull lever handles toward shoulders. Return handles until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/LVPreacherCurlHighPL', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Isolateral Preacher Curl (arms high, plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Preacher Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Preacher Curl', 'Sit on curl machine placing back of arms on pad. Grasp lever handles with underhand grip. Align elbows near same pivot point as fulcrum of lever.', 'Raise lever handles toward shoulders. Lower handles until arms are fully extended. Repeat.', 'https://exrx.net/WeightExercises/Brachialis/LVPreacherCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Wrist Flexors', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Preacher Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Arm Curl
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Arm Curl', 'Grasp suspension handles and momentarily step back until arms are extended forward and straight. While keeping arms straight and shoulders back, step forward so body is reclined back. Position palms up or slightly inward.', 'Keeping body straight, bring handles toward top of shoulders by flexing arms, while keeping elbows pointed forward. Return by straightening arms and repeat.', 'https://exrx.net/WeightExercises/Brachialis/STArmCurl', 'Upper Arms', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Brachialis', 'primary'), ('Biceps Brachii', 'secondary'), ('Brachioradialis', 'secondary'), ('Erector Spinae', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Hamstrings', 'stabilizer'), ('Wrist Flexors', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Arm Curl' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Push Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Push Crunch', 'Position feet under foot pad and lie supine on steep incline bench. Pull barbell from floor or grasp from rack behind with overhand grip. Position barbell over chest with shoulder width or slightly wider grip.', 'Flex waist to raise upper torso from bench, keeping low back on bench. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BBPushCrunch', 'Waist', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Push Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Kneeling Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Kneeling Crunch', 'Kneel below high pulley. Grasp cable rope attachment with both hands. Place wrists against head. Position hips back and flex hips, allowing resistance on cable pulley to lift torso upward so spine is hyperextended.', 'With hips stationary, flex waist so elbows travel toward middle of thighs. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/CBKneelingCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Rectus Femoris', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Kneeling Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Seated Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Seated Crunch', 'Sit with back support away from medium high pulley. Grasp cable rope attachment with both hands and place securely over both shoulders. Allow weight to lift chest up with spine arched back slightly.', 'With hips stationary, flex waist so elbows travel toward hips. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/CBSeatedCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Cable Seated Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Standing Overhead Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Standing Overhead Crunch', 'Stand below high pulley. Grasp cable rope attachment and place wrists against head. Squat down slightly with hips flexed, allowing resistance on cable pulley to lift torso upward so spine is hyperextended.', 'With knees and hips stationary, flex waist so elbows travel toward middle of thighs. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/CBStandingOverheadCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Rectus Femoris', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Standing Overhead Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Push Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Push Crunch', 'With dumbbells in each hand, position feet under foot pad and lie supine on steep incline bench. Position dumbbells straight over shoulders.', 'Flex waist to raise upper torso from bench, keeping low back on bench. Return until back of shoulders contact padded incline bench. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/DBPushCrunch', 'Waist', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Push Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Lying Crunch (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Lying Crunch (plate loaded)', 'Lie on machine with feet on foot bar. Place forearms on bars at sides or grasp handles above to each side.', 'With hips stationary, raise upper back pad by flexing waist. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVLyingCrunchPL', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Lying Crunch (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Leg Raise Crunch (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Leg Raise Crunch (plate loaded)', 'Sit on machine with back against back support and lower legs under padded bar. Grasp handles above to each side.', 'Pull handles down while pulling lower leg bar up by flexing waist and pelvis. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVSeatedLegRaiseCrunchPL', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Tensor Fasciae Latae', 'stabilizer'), ('Rectus Femoris', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Leg Raise Crunch (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Crunch', 'Sit on machine with back and hips against back supports. If available, place lower legs under pads or on platform. Grasp handles above and position back of arm against pads to each side.', 'With hips stationary, flex waist so elbows travel downward. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVSeatedCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Crunch (arm bar)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Crunch (arm bar)', 'Sit on machine with back and hips against padded supports. Place feet on floor or feet bars so thigh is approximately horizontal. Grasp handles and position forearms on bars or pads.', 'With hips stationary, flex waist so arms and upper torso travel forward and downward. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVSeatedCrunchArmBar', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Crunch (arm bar)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Crunch (arm pad)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Crunch (arm pad)', 'Position seat so shoulders are same height of padded lever. Sit on machine and place arms over lever pad. Push padded lever down slightly until shoulder is fixed at approximately 90º or slightly greater.', 'With hips stationary, flex waist in "C" shape so elbows point downward. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVSeatedCrunchArmPad', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Crunch (arm pad)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Leg Hip Raise (ab coaster)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Leg Hip Raise (ab coaster)', 'Straddle machine facing handles. Grasp handles on each side and place forearms on pads. Place shins on padded sled with knees forward and feet hanging off of back end. Sit back toward heels without bending over.', 'Slide forward and up by pulling knees up high. Deliberately attempt to flex waist in a "C" shape. Return sled down and back arching spine in opposite direction while keeping hips bent. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/SLLegHipRaise', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Femoris', 'secondary'), ('Obliques', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Leg Hip Raise (ab coaster)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Crunch', 'Lie supine on bench with head hanging off and knees and hips bent. Hold plate behind neck.', 'Flex waist to raise upper torso from bench. Keep low back on bench and raise torso up as high as possible. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Crunch (plate on chest)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Crunch (plate on chest)', 'Lie supine on mat with lower legs on bench. Hold plate on chest with both hands.', 'Flex waist to raise upper torso from mat. Keep low back on mat and raise torso up as high as possible. Return until back of shoulders contact mat. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Crunch (plate on chest)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Crunch (on stability ball)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Crunch (on stability ball)', 'Sit on exercise ball. Walk forward on ball and lie back on ball with shoulders and head hanging off and knees and hips bent. Gently hyperextend back to contour of ball. Hold plate behind neck or on chest with both hands or use no weight.', 'Flex waist to raise upper torso. Return to original position. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtBallCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Crunch (on stability ball)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Crunch', 'Hook feet under support and lie supine on incline bench with hips bent. Hold plate behind neck or clasp hands behind neck with no weight.', 'Flex waist to raise upper torso from bench. Keep low back on bench and raise torso up as high as possible. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtInclineCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Crunch (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Crunch (arms crossed)', 'Hook feet under foot brace and lie supine on incline board with hips bent. Hold plate on chest with both hands or use no weight.', 'Flex waist to raise upper torso from bench. Keep low back on bench and raise torso up as high as possible. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtInclineCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Crunch (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Sit-up', 'Hook feet under support and lie supine on incline bench with hips bent. Hold plate behind neck or clasp hands behind neck with no weight.', 'Raise torso from bench by bending waist and hips. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtInclineSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Sit-up (arms crossed)', 'Hook feet under foot brace and lie supine on incline board with hips bent. Hold plate on chest with both hands or use no weight.', 'Raise torso from bench by bending waist and hips. Return until back of shoulders contact padded incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtInclineSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Sit-up', 'Hook feet under support and lie supine on floor or mat with hips bent. Hold plate behind neck.', 'Raise torso from floor by bending waist and hips. Return until back of shoulders contact with floor or mat. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Sit-up (arms crossed)', 'Hook feet under support and lie supine on floor or mat with hips and knees bent. With both hands, hold plate on chest with forearms crossed or use no weight.', 'Raise torso from floor by bending waist and hips. Return until back of shoulders contact with floor or mat. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/WtSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Twisting Leg Raise Crunch (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Twisting Leg Raise Crunch (plate loaded)', 'Sit on machine with position back against back support and lower legs under padded bar. Grasp handles above to each side.', 'Pull handles down while pulling lower leg bar up and over to one side by flexing and twisting waist and pelvis. Return and repeat movement to opposite side. Continue alternating between sides.', 'https://exrx.net/WeightExercises/Obliques/LVSeatedTwistingLegRaiseCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Tensor Fasciae Latae', 'stabilizer'), ('Rectus Femoris', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Twisting Leg Raise Crunch (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Twisting Crunch (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Twisting Crunch (arms crossed)', 'Hook feet under padding and lie supine on incline bench with hips bent. Hold plate on upper chest with both hands or use no weight.', 'Flex and twist waist to raise upper torso from bench to one side. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtInclineTwistingCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Twisting Crunch (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Side Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Side Crunch', 'Lie upper back supine on floor or mat. With both legs together, knees and hips bent, position outside of leg down to side. Use no weight or hold weight to opposite side of head or across upper chest.', 'Flex waist, raising upper torso off surface. Return until back of shoulders return to surface. Repeat and continue with movement in opposite position.', 'https://exrx.net/WeightExercises/Obliques/WtSideCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Side Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Twisting Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Twisting Crunch', 'Lie supine on floor or bench with knees and hips bent. Hold plate behind neck or on chest with both hands.', 'Flex and twist waist to raise upper torso off surface to one side. Return until back of shoulders return to surface. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtTwistingCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Twisting Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Twisting Crunch (on stability ball)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Twisting Crunch (on stability ball)', 'Sit on exercise ball. Walk forward on ball and lie back on ball with shoulders and head hanging off and knees and hips bent. Gently hyperextend back to contour of ball. Hold plate behind neck or on chest with both hands or use no weight.', 'Flex waist to raise upper torso. Return to original position and repeat.', 'https://exrx.net/WeightExercises/Obliques/WtTwistingBallCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary')) AS m(name, role)
WHERE e.name = 'Weighted Twisting Crunch (on stability ball)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Twisting Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Twisting Sit-up', 'Hook feet under foot or ankle brace and lie supine on incline bench with hips and knees bent. Hold plate behind neck with both hands.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact padded incline board. Repeat to opposite side, alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtInclineTwistingSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Twisting Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Incline Twisting Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Incline Twisting Sit-up (arms crossed)', 'Hook feet under foot brace and lie supine on incline board with hips and knees bent. Hold plate on chest with both hands or use no weight.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtInclineTwistingSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Incline Twisting Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Twisting Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Twisting Sit-up', 'Place feet under low overhanging stationary object. Lie supine on floor or mat with hips and knees bent. Hold plate behind neck with both hands.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact floor or mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtTwistingSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Twisting Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Twisting Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Twisting Sit-up (arms crossed)', 'Place feet under low overhanging stationary object. Lie supine on floor or mat with hips and knees bent. With both hands, hold plate on chest with forearms crossed.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact floor or mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/WtTwistingSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Weighted Twisting Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Crunch', 'Lie supine on mat with lower legs on bench. Place hands behind neck or head.', 'Flex waist to raise upper torso from mat. Keep low back on mat and raise torso up as high as possible. Return until back of shoulders contact mat. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Crunch (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Crunch (arms crossed)', 'Lie supine on mat with lower legs on bench. Cross wrists on chest.', 'Flex waist to raise upper torso from mat. Keep low back on mat and raise torso up as high as possible. Return until back of shoulders contact mat. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Crunch (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Crunch (arms down)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Crunch (arms down)', 'Lie supine on mat or bench. Bend knees and hips and place feet on floor. Extend arms down to sides.', 'Flex waist to raise upper torso from mat or bench. Keep low back on floor or mat and raise torso up as high as possible. Extend hands toward sides of heels. Return until back of shoulders contact mat or bench. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWCrunchAD', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Crunch (arms down)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Crunch', 'Hook feet under foot brace and lie supine on incline board with hips bent. Place hands behind neck or head.', 'Flex waist to raise upper torso from bench. Keep low back on bench and raise torso up as high as possible. Return until back of shoulders contact incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWInclineCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Crunch (arms down)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Crunch (arms down)', 'Hook feet under foot brace and lie supine on incline board with hips bent. Extend arms down to sides.', 'Flex waist to raise upper torso from bench. Keep low back on bench and raise torso up as high as possible. Return until back of shoulders contact incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWInclineCrunchDown', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Crunch (arms down)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Reclined Shoulder Press
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Reclined Shoulder Press', 'Lie on back pad facing up. Grasp lever handles to each side with overhand grip.', 'Press lever until arms are extended. Lower and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWBallCrunch', 'Waist', 'compound', 'push', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Deltoid, Anterior', 'primary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Triceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Reclined Shoulder Press' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Crunch (on stability ball, arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Crunch (on stability ball, arms crossed)', 'Sit on exercise ball. Walk forward on ball and lie back on ball with shoulders and head hanging off and knees and hips bent. Gently hyperextend back on contour of ball. Cross arms on chest.', 'Flex waist to raise upper torso. Return to original position. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWBallCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Crunch (on stability ball, arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Hanging Leg-Hip Raise (with ab straps)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Hanging Leg-Hip Raise (with ab straps)', 'Stand below ab straps hanging from high bar. Place upper arms in straps and grasp straps above.', 'Raise legs by flexing hips and knees until hips are fully flexed. Continue to raise knees toward shoulders by flexing waist. Return until waist, hips, and knees are extended downward. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWHangingLegHipRaiseAbStrap', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Pectineus', 'secondary'), ('Sartorius', 'secondary'), ('Adductor Longus', 'secondary'), ('Adductor Brevis', 'secondary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Hanging Leg-Hip Raise (with ab straps)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Sit-up', 'Hook feet under support and lie supine on incline bench with hips bent. Place hands behind neck or on side of neck.', 'Raise torso from bench by bending waist and hips. Return until back of shoulders contact incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWInclineSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Sit-up (arms crossed)', 'Hook feet under foot brace and lie supine on incline board with hips bent. Cross arms on chest.', 'Raise torso from bench by bending waist and hips. Raise crossed arms over knees at top. Return until back of shoulders contact incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWInclineSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sit-up', 'Hook feet under foot brace or secure low overhang. Lie supine on floor or bench with hips bent. Place hands behind neck or on side of neck.', 'Raise torso from bench by bending waist and hips. Return until back of shoulders contact incline board. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sit-up (arms crossed)', 'Hook feet under foot brace or secure low overhang. Lie supine on mat or bench with hips bent. Cross arms and place hands in front of shoulders.', 'Raise torso from mat or bench by bending waist and hips. Raise crossed arms over knees at top. Return until back of shoulders contact mat or bench. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sit-up (arms down)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sit-up (arms down)', 'Lie supine on mat or bench with hips bent and feet on floor or bench. Hook feet under foot brace or secure low overhang if required to keep feet down. Extend arms down to sides.', 'Raise torso from mat or bench by bending waist and hips. Extend hands toward sides of heels. Return until back of shoulders contact mat or bench. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWSitUpAD', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Obliques', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sit-up (arms down)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Jack-knife
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Jack-knife', 'Sit on floor facing suspension trainer loops in low position. Place right foot in left lower loop. Cross left leg over right leg placed in right lower loop. Turn body to right and place hands on floor, shoulder width apart. Turn body to kneel on hands and knees. Reposition hands squared with desired distance from suspension trainer, shoulder width or slightly wider. With arms straight, raise knees from ground so body is supported by arms and suspension trainer.', 'Pull legs under torso by bending hips and knees. Pull knees toward chest hips and knees until completely flexed. Return by extending hips and knees to original position. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/STJackknife', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Pectineus', 'secondary'), ('Sartorius', 'secondary'), ('Adductor Longus', 'secondary'), ('Adductor Brevis', 'secondary'), ('Pectoralis Major', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Jack-knife' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Pull Through
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Pull Through', 'Sit on floor with feet under suspension trainer loops in low position. If loops cannot be extended down close to floor, sit on bench near hanging suspension trainer, positioned perpendicular to body where hands will be placed. Place heels in loops with soles contacting handles (or ankles through loops as shown). Extend legs out straight. Sit up and place hands on floor or bench to sides at desired distance from suspension trainer. Raise hips from floor or bench by supporting upper body with arms extended.', 'Pull hips back while flexing spine in C shape. Raise hips up high by straightening spine and hips until straight. Repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/STPullThrough', 'Waist', 'compound', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Sartorius', 'secondary'), ('Pectoralis Minor', 'stabilizer'), ('Pectoralis Major', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Triceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Pull Through' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Front Plank
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Front Plank', 'Lie prone on mat. Place forearms on mat, elbows under shoulders. Place legs together with forefeet on floor.', 'Raise body upward by straightening body in straight line. Hold position.', 'https://exrx.net/WeightExercises/RectusAbdominis/BWFrontPlank', 'Waist', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Isometric') FROM ex WHERE pg_temp.get_eq('Isometric') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'stabilizer'), ('Iliopsoas', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Quadriceps', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Pectoralis Major', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Pectoralis Minor', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Front Plank' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lying (prone) Abdominal Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lying (prone) Abdominal Stretch', 'Lie prone on mat or floor. Position hands on floor to sides of shoulders.', 'Push torso up keeping pelvis on floor. Hold stretch.', 'https://exrx.net/Stretches/RectusAbdominis/Prone', 'Waist', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary')) AS m(name, role)
WHERE e.name = 'Lying (prone) Abdominal Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Standing Abdominal Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Standing Abdominal Stretch', 'Stand with arms extended overhead.', 'Arch back by lift chest up and bringing arms back as far as possible. Hold stretch.', 'https://exrx.net/Stretches/RectusAbdominis/Standing', 'Waist', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary')) AS m(name, role)
WHERE e.name = 'Standing Abdominal Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Abdominal Vacuum
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Abdominal Vacuum', 'Sit, kneel, lie, or stand.', 'Pull navel into spine and hold.', 'https://exrx.net/WeightExercises/TransverseAbdominis/AbdominalVacuum', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
SELECT 1 FROM ex; -- no equipment
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Transverse Abdominis', 'primary')) AS m(name, role)
WHERE e.name = 'Abdominal Vacuum' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Side Bend
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Side Bend', 'With side to low pulley, grasp stirrup attachment with near arm. Stand with arm straight.', 'Pull stirrup by bending sideways through waist so torso moves away from pulley. Lower stirrup by leaning torso toward pulley. Repeat. Continue with opposite side.', 'https://exrx.net/WeightExercises/Obliques/CBSideBend', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Side Bend' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Side Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Side Crunch', 'With side close to high pulley, grasp stirrup attachment with near hand. Position stirrup at side of shoulder, palm orientated inward, and elbow down to side.', 'Pull stirrup downward by bending toward cable column through waist so torso moves toward base of cable column. Bend in opposite direction by leaning torso away from cable column, allowing stirrup to rise upward. Repeat. Continue with opposite side.', 'https://exrx.net/WeightExercises/Obliques/CBSideCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Brachioradialis', 'stabilizer'), ('Biceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Side Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Seated Twist
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Seated Twist', 'Grasp stirrup and straddle bench orientated with side facing medium height cable pulley. Sit with feet on floor. Hold onto stirrup with both hands with arms extending out straight toward stirrup.', 'Keeping arms straight, rotate torso to opposite side until cable makes contact with shoulder. Return to original position and repeat. Continue with opposite side.', 'https://exrx.net/WeightExercises/Obliques/CBSeatedTwist', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Adductors, Hip', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Seated Twist' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Twist
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Twist', 'Grasp stirrup from shoulder height cable pulley with both hands. Step and turn lower body away from pulley until near arm is horizontal and straight. Position feet wide apart facing away from pulley, furthest foot further away from pulley. Raise heel of nearest foot off floor. Bend knees of both legs slightly. Place far hand over other hand or interlace fingers.', 'Keeping arms straight, rotate torso to opposite side until cable makes contact with shoulder. Return to original position and repeat. Continue with opposite side.', 'https://exrx.net/WeightExercises/Obliques/CBTwist', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Tensor Fasciae Latae', 'secondary'), ('Gluteus Medius', 'secondary'), ('Gluteus Minimus', 'secondary'), ('Adductors, Hip', 'secondary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Erector Spinae', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Deltoid, Lateral', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Twist' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell Side Bend
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell Side Bend', 'Grasp dumbbell with arm straight to side.', 'Bend waist to opposite side of dumbbell until slight stretch is felt. Lower to opposite side, same distance, and repeat. Continue with opposite side.', 'https://exrx.net/WeightExercises/Obliques/DBSideBend', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Trapezius, Upper', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell Side Bend' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Side Leg Raise Crunch (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Side Leg Raise Crunch (plate loaded)', 'Sit on machine with seat turned to one side. Position back against back support and lower legs under padded bar. Grasp handles above to each side.', 'Pull handles down while pulling lower leg bar up by flexing waist and pelvis. Return and repeat. Turn seat to opposite side and repeat.', 'https://exrx.net/WeightExercises/Obliques/LVSeatedSideLegRaiseCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Tensor Fasciae Latae', 'stabilizer'), ('Rectus Femoris', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Sartorius', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Side Leg Raise Crunch (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Kneeling Twist
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Kneeling Twist', 'Adjust range of motion setting on machine to one side. Kneel on padded stool with both knees between leg pads. Place torso against upper pads and grasp handles.', 'Rotate lower body through waist to opposite side. Return and repeat. Adjust range of motion setting to opposite side and repeat in opposite direction.', 'https://exrx.net/WeightExercises/Obliques/LVKneelingTwist', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Gluteus Maximus', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Kneeling Twist' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Twist
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Twist', 'Adjust range of motion setting on machine to one side. Sit with legs against padding. Place torso against pad and grasp handles.', 'Rotate torso through waist to opposite side. Return and repeat. Adjust range of motion setting to opposite side and repeat in opposite direction.', 'https://exrx.net/WeightExercises/Obliques/LVTwist', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Adductors, Hip', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Twist' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Twist
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Twist', 'Adjust range of motion setting on machine to one side. Sit with legs against padding. Place torso against pad and grasp handles.', 'Rotate lower body through waist to opposite side. Return and repeat. Adjust range of motion setting to opposite side and repeat in opposite direction.', 'https://exrx.net/WeightExercises/Obliques/LVTwistLower', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Adductors, Hip', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Twist' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Twist (gripless)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Twist (gripless)', 'Adjust range of motion setting on seat to one side. Sit with legs straddled against padding. Wrap arms behind and under padded bars around each side.', 'Rotate torso through waist to opposite side. Return and repeat. Adjust range of motion setting to opposite side and repeat in opposite direction.', 'https://exrx.net/WeightExercises/Obliques/LVTwistGripless', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Psoas Major', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Adductors, Hip', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Seated Twist (gripless)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Sled Side Leg Hip Raise (ab coaster)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Sled Side Leg Hip Raise (ab coaster)', 'Straddle machine facing handles with seat turned to one side. Grasp handles on each side and place forearms on pads. Place shins on padded sled with knees in front of turned seat and feet hanging off of back end. Sit back toward heels without bending over.', 'Slide forward and up by pulling knees up high. Deliberately attempt to flex waist in a "C" shape. Return sled down and back arching spine in opposite direction while keeping hips bent. Repeat. Turn seat to opposite side and repeat.', 'https://exrx.net/WeightExercises/Obliques/SLSideHipRaiseAbCoaster', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Sled') FROM ex WHERE pg_temp.get_eq('Sled') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Femoris', 'secondary'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Sled Side Leg Hip Raise (ab coaster)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Isolateral Push Pull
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Isolateral Push Pull', 'Stand between high and low pulleys, facing low pulley. Place one foot back and grasp high pulley stirrup from behind with hand on same side as rear foot. Position stirrup to side of chest and grasp low pulley stirrup with opposite hand (same side as forward foot) with arm extended straight. Face low pulley with hips turned out approximately 45 degrees.', 'Pull low pulley stirrup back to side of ribcage while pushing high pulley stirrup forward until arm is extended, allowing torso to rotate to opposite side. Return to starting position and repeat.', 'https://exrx.net/WeightExercises/Power/CBPushPull', 'Waist', 'compound', 'push', NULL, 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary')) AS m(name, role)
WHERE e.name = 'Cable Isolateral Push Pull' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Dumbbell One Arm Straight Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Dumbbell One Arm Straight Leg Deadlift', 'Stand with shoulder width or wide stance. Grasp dumbbell to side. Place opposite hand to side or behind low back.', 'With knees straight, lower dumbbell between feet by bending hips and twisting waist, so shoulder of weighted side is turned forward. Allow hips to fall back and waist to bend as dumbbell approaches floor. Lift dumbbell upward and back to side by extending hips and waist until standing upright. Pull shoulder back if rounded. Repeat. Perform exercise with opposite arm.', 'https://exrx.net/WeightExercises/ErectorSpinae/DBOneArmStraightLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Dumbbell') FROM ex WHERE pg_temp.get_eq('Dumbbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Obliques', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Hamstrings', 'secondary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Dumbbell One Arm Straight Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Landmine Power Twist (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Landmine Power Twist (plate loaded)', 'Stand to one side, near loaded end of barbell, opposite of landmine lever. Squat down and grasp end of barbell with one hand near end and other hand just below, thumbs facing back (toward nearest end of barbell). Lift end of barbell up to one side, upper thigh level. Stand with feet apart with each foot equal distance from landmine. Orientate foot and leg nearest to bar about 45 degrees toward (under) bar. Bend legs and raise heel of opposite leg (rear leg) so forefoot remains on floor.', 'Move end of barbell upward, across, and downward to opposite side while shifting stance to opposite orientation by pivoting on forefeet and planting new forward foot. Immediately return to opposite side in same pattern and repeat.', 'https://exrx.net/WeightExercises/Power/LVPowerTwist', 'Waist', 'compound', 'push', NULL, 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary')) AS m(name, role)
WHERE e.name = 'Lever Landmine Power Twist (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- 45° Side Bend
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('45° Side Bend', 'Position side of thigh on upper padded surface and lower leg under lower padded bar. Place both hands behind head.', 'Raise torso upward by lateral flexing waist. Lower torso by bending waist downward. Repeat. Position body facing opposite side and continue same movement with opposite side.', 'https://exrx.net/WeightExercises/Obliques/BW45SideBendHandsBehindHead', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer')) AS m(name, role)
WHERE e.name = '45° Side Bend' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Bend (on stability ball, hand behind head)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Bend (on stability ball, hand behind head)', 'Lie on stability ball on side of torso, waist, and hip. Position legs outward with feet on floor or against floor board, one foot slightly forward and other behind. Place lower arm across abdomen and hand of upper arm behind or side of head.', 'Raise torso up by lateral flexing waist. Lower torso back onto ball and repeat. Lay with other side of body on ball and repeat movement.', 'https://exrx.net/WeightExercises/Obliques/BWBallSideBend', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary')) AS m(name, role)
WHERE e.name = 'Side Bend (on stability ball, hand behind head)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Hanging Twisting Leg Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Hanging Twisting Leg Raise', 'Grasp and hang from high bar with shoulder width or slightly wider overhand grip.', 'Raise legs to one side by flexing hips and knees until hips are completely flexed or knees are well above hips. Return until hips and knees are extended downward. Raise legs to opposite side in same manner. Continue by bending and lifting legs, alternating between sides.', 'https://exrx.net/WeightExercises/Obliques/BWHangingTwistingLegRaise', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Pectineus', 'secondary'), ('Sartorius', 'secondary'), ('Adductor Longus', 'secondary'), ('Adductor Brevis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Rectus Femoris', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Hanging Twisting Leg Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Hanging Twisting Leg Hip Raise
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Hanging Twisting Leg Hip Raise', 'Grasp and hang from high bar with shoulder width or slightly wider overhand grip.', 'Raise legs to one side by flexing hips and knees until hips are completely flexed or knees are well above hips. Continue to raise knees toward shoulder by flexing waist toward one side. Return until waist, hips, and knees are extended downward. Raise legs to opposite side in same manner. Continue by bending legs and lifting knees high to each side until spine is full flexed to one side, alternating between sides.', 'https://exrx.net/WeightExercises/Obliques/BWHangingTwistingLegHipRaise', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Pectineus', 'secondary'), ('Sartorius', 'secondary'), ('Adductor Longus', 'secondary'), ('Adductor Brevis', 'secondary'), ('Rectus Femoris', 'secondary')) AS m(name, role)
WHERE e.name = 'Hanging Twisting Leg Hip Raise' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Twisting Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Twisting Sit-up (arms crossed)', 'Hook feet under foot or ankle brace and lie supine on incline bench with hips and knees bent. Cross arms on chest.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Raise crossed arm over opposite knees at top. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWInclineTwistingSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Twisting Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Twisting Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Twisting Sit-up', 'Place feet under foot bar or low overhanging stationary object. Lie supine on floor, mat, or sit-up bench with hips and knees bent. Place hands behind neck.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact floor or mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWTwistingSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Twisting Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Twisting Sit-up (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Twisting Sit-up (arms crossed)', 'Place feet under foot bar or low overhanging stationary object. Lie supine on floor, mat, or sit-up bench with hips and knees bent. Cross arms on chest.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact floor or mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWTwistingSitUpX', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Twisting Sit-up (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Twisting Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Twisting Crunch', 'Hook feet under foot bar and lie supine on incline bench with hips bent. Place hands behind neck.', 'Flex and twist waist to raise upper torso from bench to one side. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWInclineTwistingCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Twisting Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Twisting Crunch (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Twisting Crunch (arms crossed)', 'Hook feet under foot bar and lie supine on incline bench with hips bent. Cross arms on chest.', 'Flex and twist waist to raise upper torso from bench to one side. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWInclineTwistingCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Twisting Crunch (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Crunch', 'Lie upper back supine on floor or mat. With both legs together, knees and hips bent, position outside of leg down to side. Place one hand base on of neck or place arms across upper chest.', 'Flex waist, raising upper torso off mat or floor. Return until back of shoulders return to mat or floor. Repeat and continue with movement in opposite position.', 'https://exrx.net/WeightExercises/Obliques/BWSideCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary')) AS m(name, role)
WHERE e.name = 'Side Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Twisting Crunch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Twisting Crunch', 'Lie supine on mat with lower legs on bench. Place hands behind neck or head.', 'Flex and twist waist to raise upper torso from mat to one side. Return until back of shoulders contact mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWTwistingCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary')) AS m(name, role)
WHERE e.name = 'Twisting Crunch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Twisting Crunch (arms crossed)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Twisting Crunch (arms crossed)', 'Lie supine on mat with lower legs on bench. Cross arms on chest.', 'Flex and twist waist to raise upper torso from mat to one side. Return until back of shoulders contact mat. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWTwistingCrunchX', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary'), ('Psoas Major', 'secondary')) AS m(name, role)
WHERE e.name = 'Twisting Crunch (arms crossed)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Twisting Crunch (on stability ball)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Twisting Crunch (on stability ball)', 'Sit on exercise ball. Walk forward on ball and lie back on ball with shoulders and head hanging off, and knees and hips bent. Gently hyperextend back to contour of ball. Hold plate behind neck or on chest with both hands or use no weight.', 'Flex waist to raise upper torso. Return to original position. Repeat.', 'https://exrx.net/WeightExercises/Obliques/BWTwistingBallCrunch', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Rectus Abdominis', 'secondary')) AS m(name, role)
WHERE e.name = 'Twisting Crunch (on stability ball)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Side Bend
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Side Bend', 'Grasp handles, step away, and face body to one side of suspension trainer anchor. Hold handles above head with arms bent. Stand far enough away to make suspension trainer straps taut. Step in just enough to achieve desired lean of body, while keeping tension on suspension trainer straps.', 'Lower hips away from direction of suspension trainer anchor by laterally flexing spine. Return to original upright position and repeat. Reposition body facing opposite direction. Continue with other side.', 'https://exrx.net/WeightExercises/Obliques/STSideBend', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Quadratus Lumborum', 'secondary'), ('Psoas Major', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Gluteus Medius', 'secondary'), ('Gluteus Minimus', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Adductors, Hip', 'secondary'), ('Pectineus', 'secondary'), ('Gracilis', 'secondary'), ('Gluteus Maximus, Lower Fibers', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Supraspinatus', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Serratus Anterior, Inferior Digitations', 'secondary'), ('Brachialis', 'secondary'), ('Brachioradialis', 'secondary'), ('Biceps Brachii', 'secondary'), ('Coracobrachialis', 'secondary'), ('Wrist Flexors', 'secondary'), ('Latissimus Dorsi', 'secondary'), ('Teres Major', 'secondary'), ('Rhomboids', 'secondary'), ('Levator Scapulae', 'secondary'), ('Triceps Brachii, Long Head', 'secondary')) AS m(name, role)
WHERE e.name = 'Suspended Side Bend' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Suspended Twisting Jack-knife
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Suspended Twisting Jack-knife', 'Sit on floor facing suspension trainer loops in low position. Place right foot in left lower loop. Cross left leg over right leg placed in right lower loop. Turn body to right and place hands on floor, shoulder width apart. Turn body to kneel on hands and knees. Reposition hands (shoulder width or slightly wider) at desired distance from suspension trainer so that body is square with suspension trainer straps. With arms straight, raise knees from ground so body is supported by arms and suspension trainer.', 'Pull knees toward one elbow by bending hips a nd knees to one side. Twist legs to one side, until hips and knees are completely flexed. Return by extending hips and knees to original straight position. Perform movement to opposite side. Continue by alternating each side.', 'https://exrx.net/WeightExercises/Obliques/STTwistingJackknife', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Suspended') FROM ex WHERE pg_temp.get_eq('Suspended') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Sartorius', 'secondary'), ('Pectineus', 'secondary'), ('Adductor Longus', 'secondary'), ('Adductor Brevis', 'secondary'), ('Quadratus Lumborum', 'secondary'), ('Iliocostalis Lumborum', 'secondary'), ('Iliocostalis Thoracis', 'secondary'), ('Rectus Abdominis', 'stabilizer'), ('Pectoralis Major', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Deltoid, Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Suspended Twisting Jack-knife' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Side Plank
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Side Plank', 'Lie on side on mat. Place forearm on mat under shoulder perpendicular to body. Place upper leg directly on top of lower leg and straighten knees and hips.', 'Raise body upward by straightening waist so body is ridged. Hold position. Repeat with opposite side.', 'https://exrx.net/WeightExercises/Obliques/BWSidePlank', 'Waist', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Isometric') FROM ex WHERE pg_temp.get_eq('Isometric') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Psoas Major', 'stabilizer'), ('Iliocostalis Lumborum', 'stabilizer'), ('Iliocostalis Thoracis', 'stabilizer'), ('Adductors, Hip', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Gracilis', 'stabilizer'), ('Gluteus Maximus, Lower Fibers', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Pectoralis Major', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Side Plank' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Bent Knee Side Plank
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Bent Knee Side Plank', 'Lie on side on mat. Place forearm on mat under shoulder perpendicular to body. Bend knees at a right angle. Place upper leg directly on top of lower leg and straighten hips.', 'Raise body upward by straightening waist so hips and waist are ridged. Hold position. Repeat with opposite side.', 'https://exrx.net/WeightExercises/Obliques/BWBentKneeSidePlank', 'Waist', 'isolated', 'push', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Isometric') FROM ex WHERE pg_temp.get_eq('Isometric') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Tensor Fasciae Latae', 'stabilizer'), ('Quadratus Lumborum', 'stabilizer'), ('Psoas Major', 'stabilizer'), ('Iliocostalis Lumborum', 'stabilizer'), ('Iliocostalis Thoracis', 'stabilizer'), ('Adductors, Hip', 'stabilizer'), ('Pectineus', 'stabilizer'), ('Gluteus Maximus, Lower Fibers', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Pectoralis Major', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Levator Scapulae', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Bent Knee Side Plank' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lying Crossover Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lying Crossover Stretch', 'On floor or mat, lie supine with arms extended to sides. Lift one leg straight up.', 'Lower leg to opposite side toward hand. Hold stretch. Repeat with opposite side.', 'https://exrx.net/Stretches/Obliques/LyingCrossover', 'Waist', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary')) AS m(name, role)
WHERE e.name = 'Lying Crossover Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Pretzel Stretch
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Pretzel Stretch', 'Sit on floor or mat with knees straight. Place one foot on floor to outside of other knee. Turn torso toward side of bent knee supporting body with extended arm behind. Place elbow of opposite arm to outside of bent knee.', 'Turn torso further around by pushing side of knee with elbow. Hold stretch. Repeat with opposite side.', 'https://exrx.net/Stretches/Obliques/Pretzel', 'Waist', NULL, NULL, NULL, 'stretch', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Stretch') FROM ex WHERE pg_temp.get_eq('Stretch') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary')) AS m(name, role)
WHERE e.name = 'Pretzel Stretch' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Bent Knee Good-morning
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Bent Knee Good-morning', 'Position barbell on back of shoulders and grasp bar to sides.', 'Bend hips to lower torso forward until parallel to floor. Bend knees slightly during descent. Raise torso until hips are extended. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BBBentKneeGoodMorning', 'Waist', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Bent Knee Good-morning' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Deadlift', 'With feet flat beneath bar, squat down and grasp bar with shoulder width or slightly wider overhand or mixed grip.', 'Lift bar by extending hips and knees to full extension. Pull shoulders back at top of lift if rounded. Return and repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BBDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Quadriceps', 'secondary'), ('Hamstrings', 'secondary'), ('Soleus', 'secondary'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Seated Crunch (chest pad)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Seated Crunch (chest pad)', 'Position seat so chest is same height of padded lever. Sit on machine with back of hips against hip pad. Place hands on outside of lever pad.', 'With hips stationary, flex waist in "C" shape so shoulders travel forward and downward. Return and repeat.', 'https://exrx.net/WeightExercises/RectusAbdominis/LVSeatedCrunchChestPad', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Rectus Abdominis', 'primary'), ('Obliques', 'secondary')) AS m(name, role)
WHERE e.name = 'Lever Seated Crunch (chest pad)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Incline Twisting Sit-up
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Incline Twisting Sit-up', 'Hook feet under foot or ankle brace and lie supine on incline bench with hips and knees bent. Place hands behind neck.', 'Flex and twist waist to one direction while raising torso from bench by bending hips. Return until back of shoulders contact padded incline board. Repeat to opposite side alternating twists.', 'https://exrx.net/WeightExercises/Obliques/BWInclineTwistingSitUp', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Obliques', 'primary'), ('Iliopsoas', 'secondary'), ('Tensor Fasciae Latae', 'secondary'), ('Rectus Femoris', 'secondary'), ('Sartorius', 'secondary'), ('Rectus Abdominis', 'secondary'), ('Tibialis Anterior', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Incline Twisting Sit-up' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Stiff Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Stiff Leg Deadlift', 'Stand with shoulder width or narrower stance on shallow platform with feet flat beneath bar. Bend your knees and bend over with lower back straight. Grasp barbell with shoulder width overhand or mixed grip, shoulder width or slightly wider. Lift weight to standing position.', 'Lower bar to top of feet by bending hips. Bend knees slightly during descent and keep waist straight, flexing only slightly at bottom. With knees bent, lift bar by extending at hips until standing upright. Pull shoulders back slightly if rounded. Extend knees at top if desired. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BBStiffLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Stiff Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Straight Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Straight Leg Deadlift', 'Stand with shoulder width or narrower stance on shallow platform with feet flat beneath bar. Bend knees and bend over with lower back straight. Grasp barbell with shoulder width overhand or mixed grip, shoulder width or slightly wider. Lift weight to standing position.', 'With knees straight, lower bar toward top of feet by bending hips and waist. Lift bar by extending waist and hip until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BBStraightLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Hamstrings', 'secondary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Straight Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell Hyperextension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell Hyperextension', 'Position thighs prone on large pad and lower legs under padded brace. Place barbell on back of shoulders and grasp bar to sides.', 'Raise upper body until hips and waist are fully extended. Lower body by bending hips and waist until mild stretch is felt or torso is vertical. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BBHyperextension', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Brachioradialis', 'stabilizer'), ('Biceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell Hyperextension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Barbell 45° Hyperextension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Barbell 45° Hyperextension', 'Position thighs prone on padding. Hook heels on platform lip or under padded brace. Place barbell on back of shoulders and grasp bar to sides.', 'Raise upper body until hips and waist are fully extended. Lower body by bending hips and waist until mild stretch is felt or torso is approximately perpendicular to legs. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BB45Hyperextension', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Barbell') FROM ex WHERE pg_temp.get_eq('Barbell') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Latissimus Dorsi', 'stabilizer'), ('Teres Major', 'stabilizer'), ('Deltoid, Posterior', 'stabilizer'), ('Triceps Brachii, Long Head', 'stabilizer'), ('Brachialis', 'stabilizer'), ('Brachioradialis', 'stabilizer'), ('Biceps Brachii', 'stabilizer'), ('Coracobrachialis', 'stabilizer'), ('Trapezius, Lower', 'stabilizer'), ('Pectoralis Minor', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Barbell 45° Hyperextension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Cable Stiff Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Cable Stiff Leg Deadlift', 'Stand between two very low pulleys with shoulder width or narrower stance. Squat down and grasp stirrup attachments to each side. Stand upright with arms straight down to sides.', 'Bow forward by bending hips. Bend knees slightly during descent and keep waist straight, flexing low back at bottom. With knees slightly bent, raise torso by extending at waist, then hips, gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/CBStiffLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Cable') FROM ex WHERE pg_temp.get_eq('Cable') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Cable Stiff Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Deadlift (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Deadlift (plate loaded)', 'Stand in between lever handles. Squat down with feet flat and grasp handles to sides.', 'Lift lever by extending hips and knees to full extension. Pull shoulders back at top of lift if rounded. Return and repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/LVDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Quadriceps', 'secondary'), ('Soleus', 'secondary'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Deadlift (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Stiff Leg Deadlift (plate loaded)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Stiff Leg Deadlift (plate loaded)', 'Stand between lever handles with shoulder width or narrower stance. Squat down and grasp handles to each side. Stand upright with arms straight down to sides.', 'Bow forward by bending hips. Bend knees slightly during descent and keep waist straight, flexing low back at bottom. With knees slightly bent, raise torso by extending at waist, then hips, gradually extending knees until standing upright. Pull shoulders back slightly if rounded. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/LVStiffLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (plate loaded)') FROM ex WHERE pg_temp.get_eq('Lever (plate loaded)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Stiff Leg Deadlift (plate loaded)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Back Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Back Extension', 'Sit on machine with back against padded lever. Push hips back against back of seat by pushing feet against platform. Arch back in "C" shape.', 'Extend spine until hyperextended. Return and repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/LVBackExtensionN', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Quadriceps', 'stabilizer'), ('Gluteus Maximus', 'stabilizer'), ('Adductor Magnus', 'stabilizer'), ('Hamstrings', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Back Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Lever Back Extension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Lever Back Extension', 'Sit in machine with feet on platform, back under padded lever, and hips against back of seat.', 'Extend lower hips and low back until extended. Return and repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/LVBackExtension', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Lever (selectorized)') FROM ex WHERE pg_temp.get_eq('Lever (selectorized)') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Lever Back Extension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Bent Knee Good-morning
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Bent Knee Good-morning', 'Position bar on back of shoulders. Grasp bar to sides. Disengage bar by rotating bar back.', 'Bend hips to lower torso forward until parallel to floor. Bend knees slightly during descent. Raise torso until hips are extended. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/SMBentKneeGoodMorning', 'Waist', 'isolated', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Quadriceps', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Bent Knee Good-morning' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Deadlift', 'Stand with shoulder width or narrower stance with feet flat beneath bar. Grasp bar with shoulder width or slightly wider mixed grip or slightly wider. Disengage bar by rotating bar back.', 'Squat down to lower bar by bending hips and knees. Lift bar by extending hips and knees to full extension. Pull shoulders back at top of lift if rounded. Return and repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/SMDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Quadriceps', 'secondary'), ('Adductor Magnus', 'secondary'), ('Hamstrings', 'secondary'), ('Soleus', 'secondary'), ('Trapezius, Middle', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Rhomboids', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Smith Stiff Leg Deadlift
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Smith Stiff Leg Deadlift', 'Stand with shoulder width or narrower stance on elevated platform with thigh against bar. Grasp bar with shoulder width or slightly wider overhand grip. Disengage bar by rotating bar back.', 'With knees slightly bent, lower bar toward top of feet by bending hips. Keep waist straight, flexing only slightly at bottom. Lift bar by extending at hips until standing upright. Pull shoulders back slightly if rounded. Extend knees at top if desired. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/SMStiffLegDeadlift', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Smith') FROM ex WHERE pg_temp.get_eq('Smith') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary'), ('Quadriceps', 'stabilizer'), ('Trapezius, Middle', 'stabilizer'), ('Rhomboids', 'stabilizer'), ('Latissimus Dorsi', 'stabilizer'), ('Trapezius, Upper', 'stabilizer'), ('Levator Scapulae', 'stabilizer'), ('Trapezius, Lower', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Smith Stiff Leg Deadlift' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted Hyperextension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted Hyperextension', 'Position thighs prone on large pad and lower legs under padded brace. Hold weight to chest or behind neck.', 'Raise upper body until hips and waist are fully extended. Lower body by bending hips and waist until mild stretch is felt or torso is vertical. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/WtHyperextension', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary')) AS m(name, role)
WHERE e.name = 'Weighted Hyperextension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Weighted 45° Hyperextension
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Weighted 45° Hyperextension', 'Position thighs prone on padding. Hook heels on platform lip or under padded brace. Hold weight to chest or behind neck.', 'Raise upper body until hips and waist are fully extended. Lower body by bending hips and waist until mild stretch is felt or torso is approximately perpendicular to legs. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/Wt45Hyperextension', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Weighted') FROM ex WHERE pg_temp.get_eq('Weighted') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary')) AS m(name, role)
WHERE e.name = 'Weighted 45° Hyperextension' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Back Extension (on stability ball, arms down)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Back Extension (on stability ball, arms down)', 'Lie prone on ball with feet against base of wall. Place arms to sides or clasp hands behind hips or low back.', 'Raise torso off of ball by hyperextending spine. Lower torso onto ball allowing spine to flex. Repeat.', 'https://exrx.net/WeightExercises/ErectorSpinae/BWHyperextensionBall', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Adductor Magnus', 'secondary')) AS m(name, role)
WHERE e.name = 'Back Extension (on stability ball, arms down)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Bird Dog
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Bird Dog', 'Kneel on mat on all fours with legs and hands slightly apart.', 'Raise arm out straight beside head while raising and extending leg on opposite side up out behind body. Lower arm and leg to floor to original position and repeat. Perform movement with opposite arm and leg.', 'https://exrx.net/WeightExercises/ErectorSpinae/BWBirdDog', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Piriformis', 'stabilizer'), ('Hip External Rotators', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Bird Dog' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Alternating Bird Dog
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Alternating Bird Dog', 'Kneel on mat on all fours with legs and hands slightly apart.', 'Raise left arm out straight beside head while raising and extending right leg up out behind body. Lower arm and leg to floor to original position. Repeat by raising and lowering right arm and left leg in same manner. Repeat by alternating between opposite sides.', 'https://exrx.net/WeightExercises/ErectorSpinae/BWAlternatingBirdDog', 'Waist', 'isolated', 'pull', 'auxiliary', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Trapezius, Lower', 'secondary'), ('Trapezius, Middle', 'secondary'), ('Deltoid, Anterior', 'secondary'), ('Deltoid, Lateral', 'secondary'), ('Coracobrachialis', 'secondary'), ('Hamstrings', 'secondary'), ('Gluteus Medius', 'stabilizer'), ('Gluteus Minimus', 'stabilizer'), ('Piriformis', 'stabilizer'), ('Hip External Rotators', 'stabilizer'), ('Pectoralis Major, Sternal', 'stabilizer'), ('Pectoralis Major, Clavicular', 'stabilizer'), ('Serratus Anterior', 'stabilizer'), ('Triceps Brachii', 'stabilizer'), ('Rectus Abdominis', 'stabilizer'), ('Obliques', 'stabilizer')) AS m(name, role)
WHERE e.name = 'Alternating Bird Dog' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

-- Hyperextension (45°)
WITH ex AS (
  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES
  ('Hyperextension (45°)', 'Position thighs prone on padding. Hook heels on platform lip or under padded brace. Clasp hands behind hips or low back.', 'Raise upper body until hips and waist are extended. Lower body by bending hips and waist until mild stretch is felt or torso is approximately perpendicular to legs. Repeat.

### Comments

Position pad high enough to evenly distribute body weight on thigh but not so high that range of motion is limited; abdomen should not press on top side of pad when upper body is lowered. Do not lower weight beyond mild stretch throughout hamstrings and low back. Full range of motion will vary from person to person.

Begin with arms in low position and gradually position arms in higher position to allow lower back adequate [adaptation](../../ExInfo/AdaptationCriteria). See [Arm Position During Waist Exercises](../../WeightTraining/Tips#ArmPosition).', 'https://exrx.net/WeightExercises/ErectorSpinae/BW45HyperextensionHips', 'Waist', 'compound', 'pull', 'basic', 'strength', false)
  RETURNING id
)
INSERT INTO public.exercise_equipment (exercise_id, equipment_id)
SELECT ex.id, pg_temp.get_eq('Bodyweight') FROM ex WHERE pg_temp.get_eq('Bodyweight') IS NOT NULL;
INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)
SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,
  (VALUES ('Erector Spinae', 'primary'), ('Gluteus Maximus', 'secondary'), ('Hamstrings', 'secondary'), ('Adductor Magnus', 'secondary')) AS m(name, role)
WHERE e.name = 'Hyperextension (45°)' AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;

COMMIT;
