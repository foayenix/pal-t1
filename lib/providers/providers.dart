import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/equipment.dart';
import '../models/exercise.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/exercise_repository.dart';
import '../services/recognition/mock_recognition_service.dart';
import '../services/recognition/recognition_service.dart';

// =============================================================================
// REPOSITORIES
// =============================================================================

/// Provider for EquipmentRepository
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository();
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

// =============================================================================
// SERVICES
// =============================================================================

/// Provider for EquipmentRecognitionService
///
/// Currently uses MockEquipmentRecognitionService.
/// To switch to a real service:
/// 1. Create your implementation (e.g., RoboflowRecognitionService)
/// 2. Replace the return statement below
final recognitionServiceProvider = Provider<EquipmentRecognitionService>((ref) {
  // TODO: Replace with real recognition service when ready
  // return RoboflowRecognitionService(apiKey: 'your-api-key', modelEndpoint: 'your-endpoint');
  // return TFLiteRecognitionService(modelPath: 'assets/models/equipment.tflite');

  return MockEquipmentRecognitionService();
});

// =============================================================================
// DATA PROVIDERS
// =============================================================================

/// Provider for fetching all equipment
final allEquipmentProvider = FutureProvider<List<Equipment>>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getAllEquipment();
});

/// Provider for fetching equipment by ID
final equipmentByIdProvider = FutureProvider.family<Equipment?, String>((ref, id) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getEquipmentById(id);
});

/// Provider for fetching all exercises
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAllExercises();
});

/// Provider for fetching exercise by ID
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((ref, id) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseById(id);
});

/// Provider for fetching exercise by equipment ID
final exerciseByEquipmentIdProvider = FutureProvider.family<Exercise?, String>((ref, equipmentId) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseByEquipmentId(equipmentId);
});

// =============================================================================
// UI STATE PROVIDERS
// =============================================================================

/// Provider for search query in browse screen
final equipmentSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Filtered equipment based on search and category
final filteredEquipmentProvider = FutureProvider<List<Equipment>>((ref) async {
  final allEquipment = await ref.watch(allEquipmentProvider.future);
  final searchQuery = ref.watch(equipmentSearchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return allEquipment.where((equipment) {
    final matchesCategory = selectedCategory == 'All' ||
        equipment.category.displayName == selectedCategory;
    final matchesSearch = equipment.name
        .toLowerCase()
        .contains(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  }).toList();
});

/// Provider for recent scans (placeholder for future implementation)
final recentScansProvider = StateProvider<List<String>>((ref) => []);
