import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:pal_app/models/recognition_result.dart';
import 'package:pal_app/services/recognition/recognition_service.dart';

/// Smallest byte sequence the recognition service treats as a JPEG.
final Uint8List fakeJpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 0]);

/// Recognition service that returns a canned result.
class FakeRecognitionService implements EquipmentRecognitionService {
  RecognitionResult result;
  int calls = 0;

  FakeRecognitionService(this.result);

  @override
  Future<RecognitionResult> recogniseEquipment(Uint8List imageBytes) async {
    calls++;
    return result;
  }

  @override
  void dispose() {}
}

/// A valid 1x1 PNG, so the scan screen's photo preview can decode it.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

/// Image picker that "takes" [tinyPng] without a real camera.
class FakeImagePicker extends ImagePickerPlatform {
  bool cancel = false;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return cancel ? null : XFile.fromData(tinyPng, mimeType: 'image/png');
  }
}

/// Waits for the splash screen to hand over to Home.
Future<void> pumpPastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}
