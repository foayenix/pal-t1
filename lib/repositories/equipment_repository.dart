import '../core/constants/app_constants.dart';
import '../models/equipment.dart';

/// Repository for accessing equipment data.
///
/// Backed by the curated in-app catalog below.
class EquipmentRepository {
  /// The curated catalog, used by recognition to map photos to known equipment.
  static List<Equipment> get catalog => List.unmodifiable(_seedEquipment);

  /// Gets all available equipment.
  Future<List<Equipment>> getAllEquipment() async {
    return _seedEquipment;
  }

  /// Gets equipment by ID.
  Future<Equipment?> getEquipmentById(String id) async {
    try {
      return _seedEquipment.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets equipment filtered by category.
  Future<List<Equipment>> getEquipmentByCategory(
      EquipmentCategory category) async {
    return _seedEquipment.where((e) => e.category == category).toList();
  }

  /// Searches equipment by name.
  Future<List<Equipment>> searchEquipment(String query) async {
    final lowerQuery = query.toLowerCase();
    return _seedEquipment
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ===========================================================================
  // SEED DATA
  // ===========================================================================

  static final List<Equipment> _seedEquipment = [
    const Equipment(
      id: 'leg_press',
      name: 'Leg Press Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      defaultExerciseId: 'leg_press_exercise',
    ),
    const Equipment(
      id: 'lat_pulldown',
      name: 'Lat Pulldown Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b',
      defaultExerciseId: 'lat_pulldown_exercise',
    ),
    const Equipment(
      id: 'chest_press',
      name: 'Chest Press Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1576678927484-cc907957088c',
      defaultExerciseId: 'chest_press_exercise',
    ),
    const Equipment(
      id: 'treadmill',
      name: 'Treadmill',
      category: EquipmentCategory.cardio,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c',
      defaultExerciseId: 'treadmill_exercise',
    ),
    const Equipment(
      id: 'rowing_machine',
      name: 'Rowing Machine',
      category: EquipmentCategory.cardio,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1519311965067-36d3e5f33d39',
      defaultExerciseId: 'rowing_exercise',
    ),
    const Equipment(
      id: 'cable_crossover',
      name: 'Cable Crossover Machine',
      category: EquipmentCategory.cable,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1597347316205-36f6c451902a',
      defaultExerciseId: 'cable_crossover_exercise',
    ),
    const Equipment(
      id: 'dumbbells',
      name: 'Dumbbells',
      category: EquipmentCategory.freeWeight,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
      defaultExerciseId: 'dumbbell_curl_exercise',
    ),
    const Equipment(
      id: 'barbell_bench',
      name: 'Barbell Bench Press',
      category: EquipmentCategory.freeWeight,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1534368270820-9de3d8053204',
      defaultExerciseId: 'barbell_bench_exercise',
    ),
    const Equipment(
      id: 'squat_rack',
      name: 'Squat Rack',
      category: EquipmentCategory.freeWeight,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
      defaultExerciseId: 'squat_exercise',
    ),
    const Equipment(
      id: 'smith_machine',
      name: 'Smith Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
      defaultExerciseId: 'smith_squat_exercise',
    ),
    const Equipment(
      id: 'leg_curl',
      name: 'Leg Curl Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      defaultExerciseId: 'leg_curl_exercise',
    ),
    const Equipment(
      id: 'leg_extension',
      name: 'Leg Extension Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      defaultExerciseId: 'leg_extension_exercise',
    ),
    const Equipment(
      id: 'shoulder_press',
      name: 'Shoulder Press Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1576678927484-cc907957088c',
      defaultExerciseId: 'shoulder_press_exercise',
    ),
    const Equipment(
      id: 'seated_row',
      name: 'Seated Row Machine',
      category: EquipmentCategory.machine,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b',
      defaultExerciseId: 'seated_row_exercise',
    ),
    const Equipment(
      id: 'elliptical',
      name: 'Elliptical Trainer',
      category: EquipmentCategory.cardio,
      imageExampleUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a',
      defaultExerciseId: 'elliptical_exercise',
    ),
  ];
}
