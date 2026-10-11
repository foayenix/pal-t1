import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../models/equipment.dart';
import '../models/exercise.dart';
import '../models/recognition_result.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/exercise_repository.dart';
import '../services/recognition/claude_recognition_service.dart';
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

/// Whether photo scanning is set up (an API key was provided at build time).
final scanConfiguredProvider =
    Provider<bool>((ref) => AppConfig.isScanConfigured);

/// Provider for EquipmentRecognitionService (Claude vision).
final recognitionServiceProvider = Provider<EquipmentRecognitionService>((ref) {
  final service = ClaudeRecognitionService(
    apiKey: AppConfig.anthropicApiKey,
    catalog: EquipmentRepository.catalog,
  );
  ref.onDispose(service.dispose);
  return service;
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
final equipmentByIdProvider =
    FutureProvider.family<Equipment?, String>((ref, id) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getEquipmentById(id);
});

/// Provider for fetching all exercises
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAllExercises();
});

/// Provider for fetching exercise by ID
final exerciseByIdProvider =
    FutureProvider.family<Exercise?, String>((ref, id) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseById(id);
});

/// Provider for fetching exercise by equipment ID
final exerciseByEquipmentIdProvider =
    FutureProvider.family<Exercise?, String>((ref, equipmentId) async {
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
    final matchesSearch =
        equipment.name.toLowerCase().contains(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  }).toList();
});

/// The most recent successful scan, shown by the results screen.
final lastScanProvider = StateProvider<RecognitionResult?>((ref) => null);
