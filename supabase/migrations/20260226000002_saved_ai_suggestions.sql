CREATE TABLE saved_ai_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_name TEXT NOT NULL,
  exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL,
  primary_muscles TEXT[] NOT NULL DEFAULT '{}',
  secondary_muscles TEXT[] NOT NULL DEFAULT '{}',
  suggested_sets INT NOT NULL DEFAULT 3,
  suggested_reps INT NOT NULL DEFAULT 10,
  description TEXT,
  instructions TEXT,
  workout_type TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE saved_ai_suggestions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own saved suggestions"
  ON saved_ai_suggestions FOR SELECT TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own saved suggestions"
  ON saved_ai_suggestions FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own saved suggestions"
  ON saved_ai_suggestions FOR DELETE TO authenticated
  USING (user_id = auth.uid());
