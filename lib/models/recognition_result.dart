import 'equipment.dart';
import 'exercise.dart';

/// Outcome of a recognition attempt.
enum RecognitionStatus {
  /// Gym equipment was identified and a guide is available.
  recognised,

  /// The photo doesn't show gym equipment (or it's too unclear to tell).
  notEquipment,

  /// The request itself failed (no connection, bad key, service error, ...).
  failed,
}

/// Result from the equipment recognition service.
class RecognitionResult {
  final RecognitionStatus status;

  /// The model's confidence in the identification (0.0 to 1.0).
  final double confidence;

  /// ID of the matching catalog equipment, or null when the equipment isn't
  /// in the curated catalog and [equipment]/[exercise] were AI-generated.
  final String? catalogId;

  /// What was identified. For catalog matches this is the catalog entry.
  final Equipment? equipment;

  /// How to use it. Null for catalog matches (the curated guide is used).
  final Exercise? exercise;

  /// Notes about the specific machine in the photo (seat pins, handles, ...).
  final String? setupNotes;

  /// User-facing explanation when [status] isn't [RecognitionStatus.recognised].
  final String? message;

  const RecognitionResult({
    required this.status,
    this.confidence = 0.0,
    this.catalogId,
    this.equipment,
    this.exercise,
    this.setupNotes,
    this.message,
  });

  factory RecognitionResult.failed(String message) {
    return RecognitionResult(
        status: RecognitionStatus.failed, message: message);
  }

  factory RecognitionResult.notEquipment(String message) {
    return RecognitionResult(
      status: RecognitionStatus.notEquipment,
      message: message,
    );
  }

  bool get isRecognised => status == RecognitionStatus.recognised;

  /// Whether the curated catalog guide should be shown.
  bool get isCatalogMatch => catalogId != null;

  /// Whether the confidence is high enough to be reliable.
  bool isConfident(double threshold) => confidence >= threshold;

  @override
  String toString() =>
      'RecognitionResult(status: ${status.name}, catalogId: $catalogId, '
      'equipment: ${equipment?.name}, '
      'confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
