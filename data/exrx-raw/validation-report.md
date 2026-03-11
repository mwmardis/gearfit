# ExRx Crawl Validation Report

## Summary
- **Total exercises**: 512
- **Body regions**: 10
  - Back: 97
  - Calves: 39
  - Chest: 50
  - Forearms: 21
  - Hips: 35
  - Neck: 22
  - Shoulders: 55
  - Thighs: 33
  - Upper Arms: 57
  - Waist: 103
- **Failed exercises**: 9

## Categories
- strength: 465
- stretch: 47

## Data Completeness
- Missing mechanics: 50/512
- Missing force: 50/512
- Missing utility: 52/512
- Missing preparation: 6/512
- Missing execution: 6/512
- Missing targetMuscle: 37/512

## Muscle Taxonomy
- **Unique muscle names (raw)**: 85
- **Case/formatting duplicates**: 8
  - ['Gluteus Medius', 'Gluteus medius', '**Gluteus medius**']
  - ['Gluteus Minimus', 'Gluteus minimus', '**Gluteus minimus**']
  - ['Latissimus Dorsi', 'Latissimus dorsi']
  - ['Pectoralis Major', 'Pectoralis major']
  - ['Pectoralis Minor', 'Pectoralis minor']
  - ['Psoas major', 'Psoas Major']
  - ['Quadratus lumborum', 'Quadratus Lumborum']
  - ['Tensor Fasciae Latae', 'Tensor fasciae latae']

## Equipment Taxonomy
- **Unique equipment names**: 23
  - : 1
  - Assisted: 4
  - Assisted (machine): 3
  - Assisted (partner): 2
  - Band Resistive: 1
  - Band-assisted: 6
  - Barbell: 57
  - Body Weight: 59
  - Bodyweight: 4
  - Cable: 78
  - Dumbbell: 59
  - Isometric: 4
  - Lever (plate loaded): 45
  - Lever (selectorized): 50
  - Self-assisted: 5
  - Sled: 13
  - Sled (plate loaded): 1
  - Sled (selectorized): 1
  - Smith: 15
  - Stretch: 46
  - Suspended: 22
  - Suspension: 2
  - Weighted: 34

## Failed Exercises (9)
- High Bar: https://exrx.net/WeightExercises/BackGeneral/BWUnderhandSupineRowHigh
- Pull-up (open-centered bar): https://exrx.net/WeightExercises/LatissimusDorsi/AsPullupOpenKneeling
- Close Grip Pulldown: https://exrx.net/WeightExercises/LatissimusDorsi/CBCloseGripPulldown
- Incline Bench Press: https://exrx.net/WeightExercises/PectoralClavicular/LVInclineBenchPress
- on stability ball: https://exrx.net/WeightExercises/PectoralClavicular/BWDeclinePushupOnBall
- Hammer Curl: https://exrx.net/WeightExercises/Brachioradialis/CBHammerCurl
- Reclined Shoulder Press: https://exrx.net/WeightExercises/DeltoidAnterior/LVReclinedShoulderPress
- Rear Delt Inverted Row (on hips): https://exrx.net/WeightExercises/DeltoidPosterior/BWRearDeltInvertedRowHips
- Concentration Curl: https://exrx.net/WeightExercises/Brachialis/DBConcentrationCurl

## Proposed Normalizations

### Muscle Name Normalization
- "**Gluteus medius**" -> "Gluteus Medius"
- "**Gluteus minimus**" -> "Gluteus Minimus"
- "Anterior Deltoid" -> "Deltoid, Anterior"
- "Gluteus medius" -> "Gluteus Medius"
- "Gluteus minimus" -> "Gluteus Minimus"
- "Gluteus minimus, anterior fibers" -> "Gluteus Minimus"
- "Iliocastalis lumborum" -> "Iliocostalis Lumborum"
- "Iliocastalis thoracis" -> "Iliocostalis Thoracis"
- "Lateral Deltoid" -> "Deltoid, Lateral"
- "Latissimus dorsi" -> "Latissimus Dorsi"
- "Major, Clavicular" -> "Pectoralis Major, Clavicular"
- "Obturator externus" -> "Hip External Rotators"
- "Pectoralis" -> "Pectoralis Major"
- "Pectoralis major" -> "Pectoralis Major"
- "Pectoralis minor" -> "Pectoralis Minor"
- "Posterior Deltoid" -> "Deltoid, Posterior"
- "Psoas major" -> "Psoas Major"
- "Quadratus lumborum" -> "Quadratus Lumborum"
- "Sternocleidomastoid, Posterior Fibers" -> "Sternocleidomastoid"
- "Tensor fasciae latae" -> "Tensor Fasciae Latae"
- "Trapezius, Upper Fibers" -> "Trapezius, Upper"
- "Triceps" -> "Triceps Brachii"
- "Triceps, Long Head" -> "Triceps Brachii, Long Head"

### Equipment Normalization
- "Assisted (machine)" -> "Assisted"
- "Assisted (partner)" -> "Assisted"
- "Band-assisted" -> "Band Resistive"
- "Body Weight" -> "Bodyweight"
- "Sled (plate loaded)" -> "Sled"
- "Sled (selectorized)" -> "Sled"
- "Suspension" -> "Suspended"

### Two-Tier Muscle Groups
- **Adductors**: Adductor Brevis, Adductor Longus, Adductor Magnus, Adductors, Hip, Gracilis
- **Back**: Latissimus Dorsi, Rhomboids, Teres Major, Erector Spinae, Iliocostalis Lumborum, Iliocostalis Thoracis
- **Biceps**: Biceps Brachii, Biceps Brachii, Short Head, Brachialis, Brachioradialis, Coracobrachialis
- **Calves**: Gastrocnemius, Soleus, Tibialis Anterior
- **Chest**: Pectoralis Major, Pectoralis Major, Clavicular, Pectoralis Major, Sternal, Pectoralis Minor
- **Core**: Rectus Abdominis, Obliques, Transverse Abdominis, Quadratus Lumborum, Serratus Anterior, Serratus Anterior, Inferior Digitations
- **Forearms**: Wrist Flexors, Wrist Extensors, Flexor Carpi Radialis, Flexor Carpi Ulnaris, Extensor Carpi Radialis, Extensor Carpi Ulnaris
- **Glutes**: Gluteus Maximus, Gluteus Maximus, Lower Fibers, Gluteus Medius, Gluteus Minimus
- **Hamstrings**: Hamstrings
- **Hip Flexors**: Iliopsoas, Psoas Major, Tensor Fasciae Latae, Sartorius, Pectineus
- **Hip Rotators**: Hip External Rotators, Piriformis
- **Neck**: Sternocleidomastoid, Splenius
- **Quadriceps**: Quadriceps, Rectus Femoris
- **Shoulders**: Deltoid, Anterior, Deltoid, Lateral, Deltoid, Posterior, Supraspinatus, Infraspinatus, Subscapularis, Teres Minor
- **Trapezius**: Trapezius, Upper, Trapezius, Middle, Trapezius, Lower, Levator Scapulae
- **Triceps**: Triceps Brachii, Triceps Brachii, Long Head