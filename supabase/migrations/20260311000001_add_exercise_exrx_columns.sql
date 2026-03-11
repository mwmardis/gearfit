-- Add ExRx metadata columns to exercises table
ALTER TABLE public.exercises ADD COLUMN url text;
ALTER TABLE public.exercises ADD COLUMN body_region text;
ALTER TABLE public.exercises ADD COLUMN mechanics text;
ALTER TABLE public.exercises ADD COLUMN force text;
ALTER TABLE public.exercises ADD COLUMN utility text;
ALTER TABLE public.exercises ADD COLUMN category text;

-- Update exercise_muscles role check to allow 'stabilizer'
ALTER TABLE public.exercise_muscles DROP CONSTRAINT IF EXISTS exercise_muscles_role_check;
ALTER TABLE public.exercise_muscles ADD CONSTRAINT exercise_muscles_role_check
  CHECK (role IN ('primary', 'secondary', 'stabilizer'));
