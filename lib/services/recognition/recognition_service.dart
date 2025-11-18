import 'dart:io';

import '../../models/recognition_result.dart';

/// Abstract interface for equipment recognition services.
///
/// This abstraction allows easy swapping between:
/// - Mock service (for development/testing)
/// - HTTP API service (e.g., Roboflow, custom backend)
/// - On-device ML service (e.g., TFLite, YOLO)
abstract class EquipmentRecognitionService {
  /// Recognises gym equipment from an image file.
  ///
  /// Returns a [RecognitionResult] containing:
  /// - equipmentId: The identified equipment type
  /// - confidence: Confidence score (0.0 to 1.0)
  /// - errorMessage: Error details if recognition failed
  Future<RecognitionResult> recogniseEquipment(File imageFile);

  /// Disposes any resources used by the service.
  void dispose() {}
}

// =============================================================================
// INTEGRATION POINTS FOR REAL SERVICES
// =============================================================================
//
// To integrate a real recognition service, implement EquipmentRecognitionService:
//
// 1. HTTP API (e.g., Roboflow):
//    - Create `RoboflowRecognitionService` that makes HTTP POST requests
//    - Send image as base64 or multipart form data
//    - Parse response to extract equipment ID and confidence
//
// 2. On-device ML (e.g., TFLite):
//    - Create `TFLiteRecognitionService`
//    - Load model in constructor
//    - Preprocess image (resize, normalize)
//    - Run inference and map output to equipment IDs
//
// Example:
//
// class RoboflowRecognitionService implements EquipmentRecognitionService {
//   final String apiKey;
//   final String modelEndpoint;
//   final http.Client _client;
//
//   RoboflowRecognitionService({
//     required this.apiKey,
//     required this.modelEndpoint,
//   }) : _client = http.Client();
//
//   @override
//   Future<RecognitionResult> recogniseEquipment(File imageFile) async {
//     final bytes = await imageFile.readAsBytes();
//     final base64Image = base64Encode(bytes);
//
//     final response = await _client.post(
//       Uri.parse('$modelEndpoint?api_key=$apiKey'),
//       body: base64Image,
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return RecognitionResult(
//         equipmentId: data['predictions'][0]['class'],
//         confidence: data['predictions'][0]['confidence'],
//       );
//     }
//
//     return RecognitionResult.failed('API error: ${response.statusCode}');
//   }
// }
// =============================================================================
