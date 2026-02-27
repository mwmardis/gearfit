-- Add custom equipment support
ALTER TABLE equipment ADD COLUMN is_custom BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE equipment ADD COLUMN created_by UUID REFERENCES profiles(id) ON DELETE CASCADE;

-- Drop the existing unique constraint on name (custom items may duplicate across users)
ALTER TABLE equipment DROP CONSTRAINT IF EXISTS equipment_name_key;

-- Add a unique constraint scoped to non-custom equipment
CREATE UNIQUE INDEX equipment_name_unique_builtin ON equipment (name) WHERE is_custom = false;

-- Update RLS: users can see built-in equipment + their own custom equipment
DROP POLICY IF EXISTS "Equipment is readable by authenticated users" ON equipment;
CREATE POLICY "Equipment is readable by authenticated users"
  ON equipment FOR SELECT TO authenticated
  USING (is_custom = false OR created_by = auth.uid());

-- Users can insert their own custom equipment
CREATE POLICY "Users can create custom equipment"
  ON equipment FOR INSERT TO authenticated
  WITH CHECK (is_custom = true AND created_by = auth.uid());

-- Users can delete their own custom equipment
CREATE POLICY "Users can delete custom equipment"
  ON equipment FOR DELETE TO authenticated
  USING (is_custom = true AND created_by = auth.uid());
