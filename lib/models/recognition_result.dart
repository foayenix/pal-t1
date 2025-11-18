/// Result from the equipment recognition service.
class RecognitionResult {
  final String equipmentId;
  final double confidence;
  final String? errorMessage;

  const RecognitionResult({
    required this.equipmentId,
    required this.confidence,
    this.errorMessage,
  });

  /// Whether the recognition was successful (confidence above threshold).
  bool get isSuccessful => errorMessage == null && confidence > 0;

  /// Whether the confidence is high enough to be reliable.
  bool isConfident(double threshold) => confidence >= threshold;

  /// Creates a failed recognition result.
  factory RecognitionResult.failed(String errorMessage) {
    return RecognitionResult(
      equipmentId: '',
      confidence: 0.0,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() => 'RecognitionResult(equipmentId: $equipmentId, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
