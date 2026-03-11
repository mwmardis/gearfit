"""Generate validation report from crawled ExRx exercise data."""
import json
import os
from collections import Counter

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'data', 'exrx-raw')

def main():
    with open(os.path.join(DATA_DIR, 'all-exercises.json'), 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    lines = []
    lines.append('# ExRx Crawl Validation Report')
    lines.append('')
    lines.append('## Summary')
    lines.append(f'- **Total exercises**: {len(exercises)}')

    # Region counts
    regions = Counter(ex.get('bodyRegion', '') for ex in exercises)
    lines.append(f'- **Body regions**: {len(regions)}')
    for r, c in sorted(regions.items()):
        lines.append(f'  - {r}: {c}')

    # Failed exercises
    total_failed = 0
    fail_details = []
    for f_name in sorted(os.listdir(DATA_DIR)):
        if f_name.endswith('-failed.json'):
            with open(os.path.join(DATA_DIR, f_name), 'r', encoding='utf-8') as fh:
                failed = json.load(fh)
                total_failed += len(failed)
                for f_item in failed:
                    fail_details.append(f_item)
    lines.append(f'- **Failed exercises**: {total_failed}')

    # Category breakdown
    cats = Counter(ex.get('category', '') for ex in exercises)
    lines.append('')
    lines.append('## Categories')
    for c, cnt in sorted(cats.items()):
        lines.append(f'- {c}: {cnt}')

    # Data completeness
    no_mech = [ex for ex in exercises if not ex.get('mechanics')]
    no_force = [ex for ex in exercises if not ex.get('force')]
    no_util = [ex for ex in exercises if not ex.get('utility')]
    no_prep = [ex for ex in exercises if not ex.get('preparation')]
    no_exec = [ex for ex in exercises if not ex.get('execution')]
    no_target = [ex for ex in exercises if not ex.get('targetMuscle')]

    lines.append('')
    lines.append('## Data Completeness')
    lines.append(f'- Missing mechanics: {len(no_mech)}/{len(exercises)}')
    lines.append(f'- Missing force: {len(no_force)}/{len(exercises)}')
    lines.append(f'- Missing utility: {len(no_util)}/{len(exercises)}')
    lines.append(f'- Missing preparation: {len(no_prep)}/{len(exercises)}')
    lines.append(f'- Missing execution: {len(no_exec)}/{len(exercises)}')
    lines.append(f'- Missing targetMuscle: {len(no_target)}/{len(exercises)}')

    # Muscle taxonomy
    all_muscles = {}
    for ex in exercises:
        t = ex.get('targetMuscle', '')
        if t:
            all_muscles.setdefault(t, {'target': 0, 'synergist': 0, 'stabilizer': 0})
            all_muscles[t]['target'] += 1
        for s in ex.get('synergists', []):
            all_muscles.setdefault(s, {'target': 0, 'synergist': 0, 'stabilizer': 0})
            all_muscles[s]['synergist'] += 1
        for s in ex.get('stabilizers', []):
            all_muscles.setdefault(s, {'target': 0, 'synergist': 0, 'stabilizer': 0})
            all_muscles[s]['stabilizer'] += 1

    # Find case duplicates
    lower_map = {}
    for m in all_muscles:
        key = m.lower().strip('*').strip()
        lower_map.setdefault(key, []).append(m)
    case_dupes = {k: v for k, v in lower_map.items() if len(v) > 1}

    lines.append('')
    lines.append('## Muscle Taxonomy')
    lines.append(f'- **Unique muscle names (raw)**: {len(all_muscles)}')
    lines.append(f'- **Case/formatting duplicates**: {len(case_dupes)}')
    if case_dupes:
        for k, variants in sorted(case_dupes.items()):
            lines.append(f'  - {variants}')

    # Equipment taxonomy
    equip_counts = Counter(ex.get('equipment', '') for ex in exercises)
    lines.append('')
    lines.append('## Equipment Taxonomy')
    lines.append(f'- **Unique equipment names**: {len(equip_counts)}')
    for e, cnt in sorted(equip_counts.items()):
        lines.append(f'  - {e}: {cnt}')

    equip_lower = {}
    for e in equip_counts:
        key = e.lower().strip()
        equip_lower.setdefault(key, []).append(e)
    equip_dupes = {k: v for k, v in equip_lower.items() if len(v) > 1}
    if equip_dupes:
        lines.append('- **Equipment near-duplicates**:')
        for k, variants in sorted(equip_dupes.items()):
            lines.append(f'  - {variants}')

    # Failed exercises detail
    if fail_details:
        lines.append('')
        lines.append(f'## Failed Exercises ({total_failed})')
        for fd in fail_details:
            lines.append(f'- {fd["name"]}: {fd["url"]}')

    # Proposed normalizations
    lines.append('')
    lines.append('## Proposed Normalizations')
    lines.append('')
    lines.append('### Muscle Name Normalization')

    norm_map = {
        '**Gluteus medius**': 'Gluteus Medius',
        '**Gluteus minimus**': 'Gluteus Minimus',
        'Gluteus medius': 'Gluteus Medius',
        'Gluteus minimus': 'Gluteus Minimus',
        'Gluteus minimus, anterior fibers': 'Gluteus Minimus',
        'Latissimus dorsi': 'Latissimus Dorsi',
        'Pectoralis major': 'Pectoralis Major',
        'Pectoralis minor': 'Pectoralis Minor',
        'Pectoralis': 'Pectoralis Major',
        'Psoas major': 'Psoas Major',
        'Quadratus lumborum': 'Quadratus Lumborum',
        'Tensor fasciae latae': 'Tensor Fasciae Latae',
        'Obturator externus': 'Hip External Rotators',
        'Anterior Deltoid': 'Deltoid, Anterior',
        'Lateral Deltoid': 'Deltoid, Lateral',
        'Posterior Deltoid': 'Deltoid, Posterior',
        'Triceps': 'Triceps Brachii',
        'Triceps, Long Head': 'Triceps Brachii, Long Head',
        'Major, Clavicular': 'Pectoralis Major, Clavicular',
        'Trapezius, Upper Fibers': 'Trapezius, Upper',
        'Iliocastalis lumborum': 'Iliocostalis Lumborum',
        'Iliocastalis thoracis': 'Iliocostalis Thoracis',
        'Sternocleidomastoid, Posterior Fibers': 'Sternocleidomastoid',
    }
    for old, new in sorted(norm_map.items()):
        lines.append(f'- "{old}" -> "{new}"')

    lines.append('')
    lines.append('### Equipment Normalization')
    equip_norm = {
        'Body Weight': 'Bodyweight',
        'Assisted (machine)': 'Assisted',
        'Assisted (partner)': 'Assisted',
        'Band-assisted': 'Band Resistive',
        'Suspension': 'Suspended',
        'Sled (plate loaded)': 'Sled',
        'Sled (selectorized)': 'Sled',
    }
    for old, new in sorted(equip_norm.items()):
        lines.append(f'- "{old}" -> "{new}"')

    # Two-tier muscle groups
    lines.append('')
    lines.append('### Two-Tier Muscle Groups')
    muscle_groups = {
        'Chest': ['Pectoralis Major', 'Pectoralis Major, Clavicular', 'Pectoralis Major, Sternal', 'Pectoralis Minor'],
        'Back': ['Latissimus Dorsi', 'Rhomboids', 'Teres Major', 'Erector Spinae', 'Iliocostalis Lumborum', 'Iliocostalis Thoracis'],
        'Shoulders': ['Deltoid, Anterior', 'Deltoid, Lateral', 'Deltoid, Posterior', 'Supraspinatus', 'Infraspinatus', 'Subscapularis', 'Teres Minor'],
        'Trapezius': ['Trapezius, Upper', 'Trapezius, Middle', 'Trapezius, Lower', 'Levator Scapulae'],
        'Biceps': ['Biceps Brachii', 'Biceps Brachii, Short Head', 'Brachialis', 'Brachioradialis', 'Coracobrachialis'],
        'Triceps': ['Triceps Brachii', 'Triceps Brachii, Long Head'],
        'Forearms': ['Wrist Flexors', 'Wrist Extensors', 'Flexor Carpi Radialis', 'Flexor Carpi Ulnaris', 'Extensor Carpi Radialis', 'Extensor Carpi Ulnaris'],
        'Core': ['Rectus Abdominis', 'Obliques', 'Transverse Abdominis', 'Quadratus Lumborum', 'Serratus Anterior', 'Serratus Anterior, Inferior Digitations'],
        'Glutes': ['Gluteus Maximus', 'Gluteus Maximus, Lower Fibers', 'Gluteus Medius', 'Gluteus Minimus'],
        'Quadriceps': ['Quadriceps', 'Rectus Femoris'],
        'Hamstrings': ['Hamstrings'],
        'Hip Flexors': ['Iliopsoas', 'Psoas Major', 'Tensor Fasciae Latae', 'Sartorius', 'Pectineus'],
        'Adductors': ['Adductor Brevis', 'Adductor Longus', 'Adductor Magnus', 'Adductors, Hip', 'Gracilis'],
        'Hip Rotators': ['Hip External Rotators', 'Piriformis'],
        'Calves': ['Gastrocnemius', 'Soleus', 'Tibialis Anterior'],
        'Neck': ['Sternocleidomastoid', 'Splenius'],
    }
    for group, muscles in sorted(muscle_groups.items()):
        lines.append(f'- **{group}**: {", ".join(muscles)}')

    report = '\n'.join(lines)
    with open(os.path.join(DATA_DIR, 'validation-report.md'), 'w', encoding='utf-8') as f:
        f.write(report)
    print(report)


if __name__ == '__main__':
    main()
