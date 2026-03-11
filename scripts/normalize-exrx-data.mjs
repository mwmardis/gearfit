/**
 * Normalize ExRx crawl data: apply muscle/equipment name normalizations,
 * map muscles to groups, and output clean JSON files for migration generation.
 */
import { readFileSync, writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const RAW_DIR = join(__dirname, "..", "data", "exrx-raw");
const OUT_DIR = join(__dirname, "..", "data", "exrx-normalized");

mkdirSync(OUT_DIR, { recursive: true });

// ── Muscle name normalization map ────────────────────────────
const MUSCLE_NORM = {
  "**Gluteus medius**": "Gluteus Medius",
  "**Gluteus minimus**": "Gluteus Minimus",
  "Anterior Deltoid": "Deltoid, Anterior",
  "Gluteus medius": "Gluteus Medius",
  "Gluteus minimus": "Gluteus Minimus",
  "Gluteus minimus, anterior fibers": "Gluteus Minimus",
  "Iliocastalis lumborum": "Iliocostalis Lumborum",
  "Iliocastalis thoracis": "Iliocostalis Thoracis",
  "Lateral Deltoid": "Deltoid, Lateral",
  "Latissimus dorsi": "Latissimus Dorsi",
  "Major, Clavicular": "Pectoralis Major, Clavicular",
  "Obturator externus": "Hip External Rotators",
  Pectoralis: "Pectoralis Major",
  "Pectoralis major": "Pectoralis Major",
  "Pectoralis minor": "Pectoralis Minor",
  "Posterior Deltoid": "Deltoid, Posterior",
  "Psoas major": "Psoas Major",
  "Quadratus lumborum": "Quadratus Lumborum",
  "Sternocleidomastoid, Posterior Fibers": "Sternocleidomastoid",
  "Tensor fasciae latae": "Tensor Fasciae Latae",
  "Trapezius, Upper Fibers": "Trapezius, Upper",
  Triceps: "Triceps Brachii",
  "Triceps, Long Head": "Triceps Brachii, Long Head",
};

// Handle the multiline "Pectoralis\n  Major, Clavicular" case
function normalizeMuscle(raw) {
  if (!raw) return null;
  // Fix multiline entries
  let name = raw.replace(/\s*\n\s*/g, " ").trim();
  // Strip markdown bold
  name = name.replace(/\*\*/g, "");
  // Apply direct mapping
  if (MUSCLE_NORM[raw]) return MUSCLE_NORM[raw];
  if (MUSCLE_NORM[name]) return MUSCLE_NORM[name];
  return name;
}

// ── Equipment normalization map ──────────────────────────────
const EQUIP_NORM = {
  "Assisted (machine)": "Assisted",
  "Assisted (partner)": "Assisted",
  "Band-assisted": "Band Resistive",
  "Body Weight": "Bodyweight",
  "Sled (plate loaded)": "Sled",
  "Sled (selectorized)": "Sled",
  Suspension: "Suspended",
};

function normalizeEquipment(raw) {
  if (!raw) return null;
  const name = raw.trim();
  return EQUIP_NORM[name] || name;
}

// ── Muscle group mapping (two-tier) ──────────────────────────
const MUSCLE_TO_GROUP = {
  "Adductor Brevis": "Adductors",
  "Adductor Longus": "Adductors",
  "Adductor Magnus": "Adductors",
  "Adductors, Hip": "Adductors",
  Gracilis: "Adductors",
  "Latissimus Dorsi": "Back",
  Rhomboids: "Back",
  "Teres Major": "Back",
  "Erector Spinae": "Back",
  "Erector Spinae, Cervicis & Capitis Fibers": "Back",
  "Iliocostalis Lumborum": "Back",
  "Iliocostalis Thoracis": "Back",
  "Biceps Brachii": "Biceps",
  "Biceps Brachii, Short Head": "Biceps",
  Brachialis: "Biceps",
  Brachioradialis: "Biceps",
  Coracobrachialis: "Biceps",
  Gastrocnemius: "Calves",
  Soleus: "Calves",
  "Tibialis Anterior": "Calves",
  "Pectoralis Major": "Chest",
  "Pectoralis Major, Clavicular": "Chest",
  "Pectoralis Major, Sternal": "Chest",
  "Pectoralis Minor": "Chest",
  "Rectus Abdominis": "Core",
  Obliques: "Core",
  "Transverse Abdominis": "Core",
  "Quadratus Lumborum": "Core",
  "Serratus Anterior": "Core",
  "Serratus Anterior, Inferior Digitations": "Core",
  "Wrist Flexors": "Forearms",
  "Wrist Extensors": "Forearms",
  "Flexor Carpi Radialis": "Forearms",
  "Flexor Carpi Ulnaris": "Forearms",
  "Extensor Carpi Radialis": "Forearms",
  "Extensor Carpi Ulnaris": "Forearms",
  "Gluteus Maximus": "Glutes",
  "Gluteus Maximus, Lower Fibers": "Glutes",
  "Gluteus Medius": "Glutes",
  "Gluteus Minimus": "Glutes",
  Hamstrings: "Hamstrings",
  Iliopsoas: "Hip Flexors",
  "Psoas Major": "Hip Flexors",
  "Tensor Fasciae Latae": "Hip Flexors",
  Sartorius: "Hip Flexors",
  Pectineus: "Hip Flexors",
  "Hip External Rotators": "Hip Rotators",
  Piriformis: "Hip Rotators",
  Sternocleidomastoid: "Neck",
  Splenius: "Neck",
  Quadriceps: "Quadriceps",
  "Rectus Femoris": "Quadriceps",
  "Deltoid, Anterior": "Shoulders",
  "Deltoid, Lateral": "Shoulders",
  "Deltoid, Posterior": "Shoulders",
  Supraspinatus: "Shoulders",
  Infraspinatus: "Shoulders",
  Subscapularis: "Shoulders",
  "Teres Minor": "Shoulders",
  "Trapezius, Upper": "Trapezius",
  "Trapezius, Middle": "Trapezius",
  "Trapezius, Lower": "Trapezius",
  "Levator Scapulae": "Trapezius",
  "Triceps Brachii": "Triceps",
  "Triceps Brachii, Long Head": "Triceps",
};

// ── Load raw data ────────────────────────────────────────────
const rawExercises = JSON.parse(
  readFileSync(join(RAW_DIR, "all-exercises.json"), "utf-8")
);

console.log(`Loaded ${rawExercises.length} raw exercises`);

// ── Normalize exercises ──────────────────────────────────────
const allMuscleNames = new Set();
const allEquipmentNames = new Set();

const normalizedExercises = rawExercises.map((ex) => {
  const equipment = normalizeEquipment(ex.equipment);
  if (equipment) allEquipmentNames.add(equipment);

  const normalizeMuscleList = (list) =>
    (list || [])
      .map(normalizeMuscle)
      .filter(Boolean)
      .filter((m) => {
        if (!MUSCLE_TO_GROUP[m]) {
          console.warn(`  Unknown muscle: "${m}" in exercise "${ex.name}"`);
          return false;
        }
        allMuscleNames.add(m);
        return true;
      });

  const targetMuscle = normalizeMuscle(ex.targetMuscle);
  if (targetMuscle && MUSCLE_TO_GROUP[targetMuscle]) {
    allMuscleNames.add(targetMuscle);
  }

  return {
    name: ex.name,
    url: ex.url,
    bodyRegion: ex.bodyRegion,
    targetMuscle: targetMuscle && MUSCLE_TO_GROUP[targetMuscle] ? targetMuscle : null,
    equipment,
    synergists: normalizeMuscleList(ex.synergists),
    stabilizers: normalizeMuscleList(ex.stabilizers),
    mechanics: ex.mechanics || null,
    force: ex.force || null,
    utility: ex.utility || null,
    category: ex.category || null,
    preparation: ex.preparation || null,
    execution: ex.execution || null,
  };
});

// ── Build muscles list ───────────────────────────────────────
const muscles = [...allMuscleNames]
  .sort()
  .map((name) => ({
    name,
    muscleGroup: MUSCLE_TO_GROUP[name],
  }));

// ── Build equipment list ─────────────────────────────────────
const equipmentList = [...allEquipmentNames]
  .filter((e) => e && e.trim() !== "")
  .sort()
  .map((name) => ({ name }));

// ── Write output ─────────────────────────────────────────────
writeFileSync(
  join(OUT_DIR, "muscles.json"),
  JSON.stringify(muscles, null, 2)
);
writeFileSync(
  join(OUT_DIR, "equipment.json"),
  JSON.stringify(equipmentList, null, 2)
);
writeFileSync(
  join(OUT_DIR, "exercises.json"),
  JSON.stringify(normalizedExercises, null, 2)
);

console.log(`\nOutput:`);
console.log(`  Muscles: ${muscles.length}`);
console.log(`  Equipment: ${equipmentList.length}`);
console.log(`  Exercises: ${normalizedExercises.length}`);

// ── Stats ────────────────────────────────────────────────────
const withTarget = normalizedExercises.filter((e) => e.targetMuscle).length;
const withEquip = normalizedExercises.filter((e) => e.equipment).length;
const withMechanics = normalizedExercises.filter((e) => e.mechanics).length;
console.log(`\nCoverage:`);
console.log(`  With target muscle: ${withTarget}/${normalizedExercises.length}`);
console.log(`  With equipment: ${withEquip}/${normalizedExercises.length}`);
console.log(`  With mechanics: ${withMechanics}/${normalizedExercises.length}`);
