import 'dart:typed_data';

import '../../models/recognition_result.dart';

/// Abstract interface for equipment recognition services.
///
/// The app uses [ClaudeRecognitionService]; tests substitute a fake.
abstract class EquipmentRecognitionService {
  /// Identifies gym equipment in a photo and returns how to use it.
  ///
  /// Never throws: failures come back as [RecognitionStatus.failed] with a
  /// user-facing message.
  Future<RecognitionResult> recogniseEquipment(Uint8List imageBytes);

  /// Releases any resources held by the service.
  void dispose();
}
