/**
 * Generate the SQL seed migration from normalized ExRx data.
 * Outputs: supabase/migrations/20260311000002_seed_exrx_data.sql
 */
import { readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_DIR = join(__dirname, "..", "data", "exrx-normalized");
const OUT_FILE = join(
  __dirname,
  "..",
  "supabase",
  "migrations",
  "20260311000002_seed_exrx_data.sql"
);

const muscles = JSON.parse(readFileSync(join(DATA_DIR, "muscles.json"), "utf-8"));
const equipment = JSON.parse(readFileSync(join(DATA_DIR, "equipment.json"), "utf-8"));
const exercises = JSON.parse(readFileSync(join(DATA_DIR, "exercises.json"), "utf-8"));

function esc(str) {
  if (str === null || str === undefined) return "NULL";
  return "'" + str.replace(/'/g, "''") + "'";
}

const lines = [];

lines.push("-- ============================================================");
lines.push("-- ExRx Exercise Data Seed Migration");
lines.push(`-- Generated: ${new Date().toISOString()}`);
lines.push(`-- Muscles: ${muscles.length}, Equipment: ${equipment.length}, Exercises: ${exercises.length}`);
lines.push("-- ============================================================");
lines.push("");
lines.push("BEGIN;");
lines.push("");

// ── Delete existing seed data ────────────────────────────────
lines.push("-- Clear existing seed data (preserve custom user data)");
lines.push("DELETE FROM public.exercise_muscles WHERE exercise_id IN (SELECT id FROM public.exercises WHERE is_custom = false);");
lines.push("DELETE FROM public.exercise_equipment WHERE exercise_id IN (SELECT id FROM public.exercises WHERE is_custom = false);");
lines.push("DELETE FROM public.exercises WHERE is_custom = false;");
lines.push("DELETE FROM public.muscles;");
lines.push("DELETE FROM public.equipment WHERE is_custom = false;");
lines.push("");

// ── Insert muscles ───────────────────────────────────────────
lines.push("-- ── Muscles ──────────────────────────────────────────────────");
lines.push("INSERT INTO public.muscles (name, muscle_group) VALUES");
const muscleValues = muscles.map(
  (m) => `  (${esc(m.name)}, ${esc(m.muscleGroup)})`
);
lines.push(muscleValues.join(",\n") + ";");
lines.push("");

// ── Insert equipment ─────────────────────────────────────────
lines.push("-- ── Equipment ────────────────────────────────────────────────");
lines.push("INSERT INTO public.equipment (name, is_custom) VALUES");
const equipValues = equipment.map((e) => `  (${esc(e.name)}, false)`);
lines.push(equipValues.join(",\n") + ";");
lines.push("");

// ── Helper functions ─────────────────────────────────────────
lines.push("-- Helper functions for lookups");
lines.push("CREATE OR REPLACE FUNCTION pg_temp.get_eq(eq_name text) RETURNS uuid AS $$");
lines.push("  SELECT id FROM public.equipment WHERE name = eq_name AND is_custom = false LIMIT 1;");
lines.push("$$ LANGUAGE sql STABLE;");
lines.push("");
lines.push("CREATE OR REPLACE FUNCTION pg_temp.get_mu(m_name text) RETURNS uuid AS $$");
lines.push("  SELECT id FROM public.muscles WHERE name = m_name LIMIT 1;");
lines.push("$$ LANGUAGE sql STABLE;");
lines.push("");

// ── Insert exercises with relationships ──────────────────────
lines.push("-- ── Exercises ────────────────────────────────────────────────");

for (const ex of exercises) {
  lines.push("");
  lines.push(`-- ${ex.name}`);

  // Build description from preparation, instructions from execution
  const description = ex.preparation;
  const instructions = ex.execution;

  lines.push("WITH ex AS (");
  lines.push("  INSERT INTO public.exercises (name, description, instructions, url, body_region, mechanics, force, utility, category, is_custom) VALUES");
  lines.push(`  (${esc(ex.name)}, ${esc(description)}, ${esc(instructions)}, ${esc(ex.url)}, ${esc(ex.bodyRegion)}, ${esc(ex.mechanics)}, ${esc(ex.force)}, ${esc(ex.utility)}, ${esc(ex.category)}, false)`);
  lines.push("  RETURNING id");
  lines.push(")");

  // Equipment junction
  if (ex.equipment) {
    lines.push("INSERT INTO public.exercise_equipment (exercise_id, equipment_id)");
    lines.push(`SELECT ex.id, pg_temp.get_eq(${esc(ex.equipment)}) FROM ex WHERE pg_temp.get_eq(${esc(ex.equipment)}) IS NOT NULL;`);
  } else {
    lines.push("SELECT 1 FROM ex; -- no equipment");
  }

  // Muscle junctions: collect all muscles with roles, deduplicate
  const muscleRoles = new Map();

  if (ex.targetMuscle) {
    muscleRoles.set(ex.targetMuscle, "primary");
  }
  for (const m of ex.synergists || []) {
    if (!muscleRoles.has(m)) muscleRoles.set(m, "secondary");
  }
  for (const m of ex.stabilizers || []) {
    if (!muscleRoles.has(m)) muscleRoles.set(m, "stabilizer");
  }

  if (muscleRoles.size > 0) {
    lines.push("INSERT INTO public.exercise_muscles (exercise_id, muscle_id, role)");
    lines.push("SELECT e.id, pg_temp.get_mu(m.name), m.role FROM public.exercises e,");
    const muscleEntries = [...muscleRoles.entries()].map(
      ([name, role]) => `(${esc(name)}, ${esc(role)})`
    );
    lines.push(`  (VALUES ${muscleEntries.join(", ")}) AS m(name, role)`);
    lines.push(`WHERE e.name = ${esc(ex.name)} AND e.is_custom = false AND pg_temp.get_mu(m.name) IS NOT NULL;`);
  }
}

lines.push("");
lines.push("COMMIT;");

writeFileSync(OUT_FILE, lines.join("\n") + "\n");
console.log(`Written: ${OUT_FILE}`);
console.log(`Total lines: ${lines.length}`);
