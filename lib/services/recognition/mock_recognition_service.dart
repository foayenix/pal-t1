import 'dart:io';
import 'dart:math';

import '../../models/recognition_result.dart';
import 'recognition_service.dart';

/// Mock implementation of the equipment recognition service.
///
/// This service simulates recognition for development and testing.
/// It randomly selects from known equipment IDs with varying confidence scores.
class MockEquipmentRecognitionService implements EquipmentRecognitionService {
  final Random _random = Random();

  /// List of known equipment IDs that can be "recognised".
  /// This should match the equipment in the seed data.
  static const List<String> knownEquipmentIds = [
    'leg_press',
    'lat_pulldown',
    'chest_press',
    'treadmill',
    'rowing_machine',
    'cable_crossover',
    'dumbbells',
    'barbell_bench',
    'squat_rack',
    'smith_machine',
    'leg_curl',
    'leg_extension',
    'shoulder_press',
    'seated_row',
    'elliptical',
  ];

  /// Simulated processing delay range (milliseconds).
  final int minDelayMs;
  final int maxDelayMs;

  /// Minimum confidence score for simulated results.
  final double minConfidence;

  MockEquipmentRecognitionService({
    this.minDelayMs = 1000,
    this.maxDelayMs = 2500,
    this.minConfidence = 0.65,
  });

  @override
  Future<RecognitionResult> recogniseEquipment(File imageFile) async {
    // Simulate network/processing delay
    final delay = minDelayMs + _random.nextInt(maxDelayMs - minDelayMs);
    await Future.delayed(Duration(milliseconds: delay));

    // Simulate occasional failures (5% chance)
    if (_random.nextDouble() < 0.05) {
      return RecognitionResult.failed('Recognition service temporarily unavailable');
    }

    // Select a random equipment ID
    // In a real scenario, this would be based on image analysis
    final equipmentId = knownEquipmentIds[_random.nextInt(knownEquipmentIds.length)];

    // Generate a confidence score between minConfidence and 1.0
    final confidence = minConfidence + _random.nextDouble() * (1.0 - minConfidence);

    return RecognitionResult(
      equipmentId: equipmentId,
      confidence: confidence,
    );
  }

  /// Recognises equipment with a deterministic result based on filename.
  /// Useful for testing specific scenarios.
  Future<RecognitionResult> recogniseEquipmentDeterministic(File imageFile) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final filename = imageFile.path.toLowerCase();

    // Map filename patterns to equipment
    for (final equipmentId in knownEquipmentIds) {
      if (filename.contains(equipmentId.replaceAll('_', ''))) {
        return RecognitionResult(
          equipmentId: equipmentId,
          confidence: 0.95,
        );
      }
    }

    // Default to random if no pattern matches
    return RecognitionResult(
      equipmentId: knownEquipmentIds[_random.nextInt(knownEquipmentIds.length)],
      confidence: 0.75,
    );
  }
}
