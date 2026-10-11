import '../core/constants/app_constants.dart';
import '../models/exercise.dart';

/// Repository for accessing exercise data.
///
/// Backed by the curated in-app catalog below.
class ExerciseRepository {
  /// Gets all available exercises.
  Future<List<Exercise>> getAllExercises() async {
    return _seedExercises;
  }

  /// Gets exercise by ID.
  Future<Exercise?> getExerciseById(String id) async {
    try {
      return _seedExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets exercise by equipment ID.
  Future<Exercise?> getExerciseByEquipmentId(String equipmentId) async {
    try {
      return _seedExercises.firstWhere((e) => e.equipmentId == equipmentId);
    } catch (_) {
      return null;
    }
  }

  /// Gets all exercises for a specific equipment.
  Future<List<Exercise>> getExercisesForEquipment(String equipmentId) async {
    return _seedExercises.where((e) => e.equipmentId == equipmentId).toList();
  }

  // ===========================================================================
  // SEED DATA - Comprehensive exercise information
  // ===========================================================================

  static final List<Exercise> _seedExercises = [
    // Leg Press
    const Exercise(
      id: 'leg_press_exercise',
      equipmentId: 'leg_press',
      name: 'Leg Press',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Quadriceps', 'Glutes'],
      secondaryMuscles: ['Hamstrings', 'Calves'],
      steps: [
        'Adjust the seat so your knees are at a 90-degree angle when your feet are on the platform.',
        'Place your feet shoulder-width apart on the footplate.',
        'Grasp the handles on either side and keep your back flat against the seat.',
        'Push the platform away by extending your legs, but do not lock your knees.',
        'Slowly lower the weight back down, keeping control throughout the movement.',
        'Repeat for the desired number of repetitions.',
      ],
      safetyTips: [
        'Never lock your knees at the top of the movement.',
        'Keep your lower back pressed firmly against the seat.',
        'Use a controlled tempo – avoid bouncing the weight.',
        'Start with lighter weight to master the form.',
      ],
      commonMistakes: [
        'Allowing the lower back to round off the seat.',
        'Placing feet too high or too low on the platform.',
        'Locking knees at full extension.',
        'Using momentum instead of controlled movement.',
      ],
    ),

    // Lat Pulldown
    const Exercise(
      id: 'lat_pulldown_exercise',
      equipmentId: 'lat_pulldown',
      name: 'Lat Pulldown',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Latissimus Dorsi', 'Biceps'],
      secondaryMuscles: ['Rhomboids', 'Rear Deltoids', 'Forearms'],
      steps: [
        'Adjust the thigh pad to secure your legs and prevent lifting.',
        'Grasp the bar with a wide overhand grip, hands wider than shoulder-width.',
        'Sit down and lean back slightly, keeping your chest up.',
        'Pull the bar down towards your upper chest, squeezing your shoulder blades together.',
        'Pause briefly at the bottom, then slowly return to the starting position.',
        'Maintain control throughout the entire range of motion.',
      ],
      safetyTips: [
        'Avoid pulling the bar behind your neck – this strains the shoulders.',
        'Keep your core engaged throughout the movement.',
        'Do not swing or use momentum to move the weight.',
        'Focus on pulling with your back, not your arms.',
      ],
      commonMistakes: [
        'Leaning too far back during the pull.',
        'Using too narrow a grip.',
        'Not fully extending arms at the top.',
        'Pulling with the biceps instead of the back.',
      ],
    ),

    // Chest Press
    const Exercise(
      id: 'chest_press_exercise',
      equipmentId: 'chest_press',
      name: 'Machine Chest Press',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Pectoralis Major', 'Anterior Deltoids'],
      secondaryMuscles: ['Triceps', 'Serratus Anterior'],
      steps: [
        'Adjust the seat height so the handles are at chest level.',
        'Sit with your back firmly against the pad and feet flat on the floor.',
        'Grasp the handles with an overhand grip.',
        'Push the handles forward until your arms are fully extended but not locked.',
        'Slowly return to the starting position with control.',
        'Keep your shoulders back and chest up throughout.',
      ],
      safetyTips: [
        'Do not arch your back excessively.',
        'Keep wrists straight and aligned with forearms.',
        'Breathe out as you push, breathe in as you return.',
        'Start with a weight you can control for 10-12 reps.',
      ],
      commonMistakes: [
        'Flaring elbows out too wide.',
        'Not using full range of motion.',
        'Lifting shoulders during the press.',
        'Rushing through repetitions.',
      ],
    ),

    // Treadmill
    const Exercise(
      id: 'treadmill_exercise',
      equipmentId: 'treadmill',
      name: 'Treadmill Running',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Quadriceps', 'Hamstrings', 'Calves'],
      secondaryMuscles: ['Glutes', 'Hip Flexors', 'Core'],
      steps: [
        'Step onto the treadmill and straddle the belt.',
        'Attach the safety clip to your clothing.',
        'Start at a slow walking pace to warm up.',
        'Gradually increase speed to your desired running pace.',
        'Maintain an upright posture with a slight forward lean.',
        'Land midfoot, not on your heels.',
        'Use the handrails only for balance checks, not support.',
      ],
      safetyTips: [
        'Always use the safety clip.',
        'Start slow and increase speed gradually.',
        'Stay centred on the belt.',
        'Have a cool-down period before stopping.',
      ],
      commonMistakes: [
        'Holding onto handrails while running.',
        'Looking down at your feet.',
        'Overstriding or heel striking.',
        'Setting incline or speed too high too soon.',
      ],
    ),

    // Rowing Machine
    const Exercise(
      id: 'rowing_exercise',
      equipmentId: 'rowing_machine',
      name: 'Rowing Machine',
      difficulty: ExerciseDifficulty.intermediate,
      primaryMuscles: ['Latissimus Dorsi', 'Quadriceps', 'Glutes'],
      secondaryMuscles: ['Biceps', 'Core', 'Hamstrings', 'Calves'],
      steps: [
        'Secure your feet in the straps with the strap across the ball of your foot.',
        'Grasp the handle with an overhand grip.',
        'Start in the "catch" position: knees bent, arms extended, leaning slightly forward.',
        'Drive through your legs first, then lean back slightly.',
        'Pull the handle to your lower chest as your legs extend.',
        'Reverse the movement: extend arms, lean forward, then bend knees.',
      ],
      safetyTips: [
        'Keep your back straight – do not round it.',
        'Drive with legs first, not arms.',
        'Maintain a smooth, continuous motion.',
        'Do not grip the handle too tightly.',
      ],
      commonMistakes: [
        'Pulling with arms before legs extend.',
        'Leaning too far back at the finish.',
        'Rushing the recovery phase.',
        'Rounding the lower back.',
      ],
    ),

    // Cable Crossover
    const Exercise(
      id: 'cable_crossover_exercise',
      equipmentId: 'cable_crossover',
      name: 'Cable Crossover',
      difficulty: ExerciseDifficulty.intermediate,
      primaryMuscles: ['Pectoralis Major', 'Anterior Deltoids'],
      secondaryMuscles: ['Biceps', 'Serratus Anterior'],
      steps: [
        'Set both pulleys to the highest position.',
        'Stand in the centre with one foot slightly forward for balance.',
        'Grasp the handles with palms facing down.',
        'With a slight bend in your elbows, bring your hands together in front of your chest.',
        'Squeeze your chest at the bottom of the movement.',
        'Slowly return to the starting position with control.',
      ],
      safetyTips: [
        'Keep a slight bend in your elbows throughout.',
        'Do not let the weight stack slam.',
        'Maintain a stable core and neutral spine.',
        'Use a weight that allows proper form.',
      ],
      commonMistakes: [
        'Using too much weight and losing form.',
        'Straightening arms completely.',
        'Leaning too far forward.',
        'Not getting a full stretch at the top.',
      ],
    ),

    // Dumbbell Curl
    const Exercise(
      id: 'dumbbell_curl_exercise',
      equipmentId: 'dumbbells',
      name: 'Dumbbell Bicep Curl',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Biceps Brachii'],
      secondaryMuscles: ['Brachialis', 'Forearms'],
      steps: [
        'Stand with feet shoulder-width apart, holding a dumbbell in each hand.',
        'Keep your arms at your sides, palms facing forward.',
        'Keeping your upper arms stationary, curl the weights up towards your shoulders.',
        'Squeeze your biceps at the top of the movement.',
        'Slowly lower the dumbbells back to the starting position.',
        'Alternate arms or curl both simultaneously.',
      ],
      safetyTips: [
        'Keep your elbows close to your torso.',
        'Do not swing the weights – use controlled motion.',
        'Keep your wrists straight.',
        'Engage your core to prevent back swaying.',
      ],
      commonMistakes: [
        'Swinging the body to lift heavier weights.',
        'Moving elbows forward during the curl.',
        'Not fully extending arms at the bottom.',
        'Using momentum instead of muscle control.',
      ],
    ),

    // Barbell Bench Press
    const Exercise(
      id: 'barbell_bench_exercise',
      equipmentId: 'barbell_bench',
      name: 'Barbell Bench Press',
      difficulty: ExerciseDifficulty.intermediate,
      primaryMuscles: ['Pectoralis Major', 'Anterior Deltoids'],
      secondaryMuscles: ['Triceps', 'Serratus Anterior'],
      steps: [
        'Lie flat on the bench with your eyes under the bar.',
        'Plant your feet firmly on the floor.',
        'Grip the bar slightly wider than shoulder-width.',
        'Unrack the bar and hold it directly above your chest.',
        'Lower the bar to your mid-chest in a controlled manner.',
        'Press the bar back up to the starting position.',
        'Keep your wrists straight and elbows at about 45 degrees.',
      ],
      safetyTips: [
        'Always use a spotter for heavy weights.',
        'Keep your lower back slightly arched, not flat.',
        'Do not bounce the bar off your chest.',
        'Ensure the bar path is slightly diagonal.',
      ],
      commonMistakes: [
        'Flaring elbows out to 90 degrees.',
        'Lifting hips off the bench.',
        'Bouncing bar off chest.',
        'Uneven grip or bar path.',
      ],
    ),

    // Squat
    const Exercise(
      id: 'squat_exercise',
      equipmentId: 'squat_rack',
      name: 'Barbell Back Squat',
      difficulty: ExerciseDifficulty.intermediate,
      primaryMuscles: ['Quadriceps', 'Glutes'],
      secondaryMuscles: ['Hamstrings', 'Core', 'Lower Back'],
      steps: [
        'Position the bar on your upper back (not your neck).',
        'Step back from the rack with feet shoulder-width apart.',
        'Point your toes slightly outward.',
        'Brace your core and keep your chest up.',
        'Lower your body by bending at the hips and knees.',
        'Descend until your thighs are parallel to the floor (or below).',
        'Drive through your heels to return to standing.',
      ],
      safetyTips: [
        'Keep your knees tracking over your toes.',
        'Maintain a neutral spine throughout.',
        'Use safety bars set at appropriate height.',
        'Start with lighter weight to perfect form.',
      ],
      commonMistakes: [
        'Knees caving inward.',
        'Rising on toes or heels lifting.',
        'Rounding the lower back.',
        'Not reaching adequate depth.',
      ],
    ),

    // Smith Machine Squat
    const Exercise(
      id: 'smith_squat_exercise',
      equipmentId: 'smith_machine',
      name: 'Smith Machine Squat',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Quadriceps', 'Glutes'],
      secondaryMuscles: ['Hamstrings', 'Core'],
      steps: [
        'Position the bar on your upper back.',
        'Place your feet slightly in front of the bar.',
        'Unhook the bar by rotating it.',
        'Lower your body by bending at hips and knees.',
        'Descend until thighs are parallel to the floor.',
        'Push through your heels to return to standing.',
        'Re-hook the bar by rotating at the top.',
      ],
      safetyTips: [
        'The fixed path allows heavier loads but limits natural movement.',
        'Keep your core braced throughout.',
        'Do not round your lower back.',
        'Use the safety catches appropriately.',
      ],
      commonMistakes: [
        'Feet positioned directly under the bar.',
        'Leaning too far forward.',
        'Not using full range of motion.',
        'Forgetting to lock/unlock the bar properly.',
      ],
    ),

    // Leg Curl
    const Exercise(
      id: 'leg_curl_exercise',
      equipmentId: 'leg_curl',
      name: 'Lying Leg Curl',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Hamstrings'],
      secondaryMuscles: ['Calves', 'Glutes'],
      steps: [
        'Lie face down on the machine with the pad just above your heels.',
        'Grasp the handles for stability.',
        'Curl your legs up towards your glutes.',
        'Squeeze your hamstrings at the top.',
        'Slowly lower back to the starting position.',
        'Keep your hips pressed against the bench.',
      ],
      safetyTips: [
        'Do not lift your hips during the movement.',
        'Avoid hyperextending your knees at the bottom.',
        'Use a controlled tempo throughout.',
        'Adjust the pad position for comfort.',
      ],
      commonMistakes: [
        'Lifting hips off the pad.',
        'Using momentum to swing the weight.',
        'Not achieving full range of motion.',
        'Going too heavy too soon.',
      ],
    ),

    // Leg Extension
    const Exercise(
      id: 'leg_extension_exercise',
      equipmentId: 'leg_extension',
      name: 'Leg Extension',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Quadriceps'],
      secondaryMuscles: [],
      steps: [
        'Adjust the backrest and pad so your knees are aligned with the pivot point.',
        'Position the pad just above your ankles.',
        'Grasp the handles on either side.',
        'Extend your legs until they are straight but not locked.',
        'Squeeze your quads at the top.',
        'Slowly lower back to the starting position.',
      ],
      safetyTips: [
        'Do not lock your knees at full extension.',
        'Keep your back against the pad.',
        'Use moderate weight – this exercise puts stress on knees.',
        'Control the weight on the way down.',
      ],
      commonMistakes: [
        'Using too much weight.',
        'Lifting hips off the seat.',
        'Swinging legs to build momentum.',
        'Not aligning knee with machine pivot.',
      ],
    ),

    // Shoulder Press Machine
    const Exercise(
      id: 'shoulder_press_exercise',
      equipmentId: 'shoulder_press',
      name: 'Machine Shoulder Press',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Anterior Deltoids', 'Lateral Deltoids'],
      secondaryMuscles: ['Triceps', 'Trapezius'],
      steps: [
        'Adjust the seat so the handles are at shoulder height.',
        'Sit with your back firmly against the pad.',
        'Grasp the handles with an overhand grip.',
        'Press the handles overhead until arms are extended.',
        'Do not lock your elbows at the top.',
        'Lower the handles back to shoulder level with control.',
      ],
      safetyTips: [
        'Keep your core engaged and back supported.',
        'Do not arch your lower back excessively.',
        'Avoid locking elbows at full extension.',
        'Breathe out as you press up.',
      ],
      commonMistakes: [
        'Arching the back excessively.',
        'Pressing unevenly with one arm.',
        'Using momentum instead of controlled motion.',
        'Not achieving full range of motion.',
      ],
    ),

    // Seated Row
    const Exercise(
      id: 'seated_row_exercise',
      equipmentId: 'seated_row',
      name: 'Seated Cable Row',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Latissimus Dorsi', 'Rhomboids'],
      secondaryMuscles: ['Biceps', 'Rear Deltoids', 'Trapezius'],
      steps: [
        'Sit on the machine with your feet on the footrests.',
        'Grasp the handle with both hands.',
        'Sit upright with a slight lean forward, arms extended.',
        'Pull the handle towards your lower chest/upper abdomen.',
        'Squeeze your shoulder blades together at the end.',
        'Slowly extend arms back to the starting position.',
      ],
      safetyTips: [
        'Keep your back straight – do not round it.',
        'Avoid excessive swinging or momentum.',
        'Pull with your back muscles, not just arms.',
        'Maintain constant tension on the cable.',
      ],
      commonMistakes: [
        'Rounding the back during the pull.',
        'Leaning too far back.',
        'Not fully extending arms on the return.',
        'Shrugging shoulders instead of retracting.',
      ],
    ),

    // Elliptical
    const Exercise(
      id: 'elliptical_exercise',
      equipmentId: 'elliptical',
      name: 'Elliptical Trainer',
      difficulty: ExerciseDifficulty.beginner,
      primaryMuscles: ['Quadriceps', 'Glutes', 'Hamstrings'],
      secondaryMuscles: ['Calves', 'Core', 'Upper Body (with handles)'],
      steps: [
        'Step onto the pedals and grasp the handles.',
        'Start with a comfortable resistance level.',
        'Begin pedalling in a smooth, elliptical motion.',
        'Push and pull the handles to engage upper body.',
        'Maintain an upright posture throughout.',
        'Increase resistance or speed as desired.',
      ],
      safetyTips: [
        'Start at a low resistance to warm up.',
        'Keep your feet flat on the pedals.',
        'Do not lean heavily on the handles.',
        'Stay centred over the pedals.',
      ],
      commonMistakes: [
        'Leaning forward too much.',
        'Not engaging the arms with the handles.',
        'Going too fast with poor form.',
        'Setting resistance too high initially.',
      ],
    ),
  ];
}
