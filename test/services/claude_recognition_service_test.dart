import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pal_app/core/constants/app_constants.dart';
import 'package:pal_app/models/recognition_result.dart';
import 'package:pal_app/repositories/equipment_repository.dart';
import 'package:pal_app/services/recognition/claude_recognition_service.dart';

import '../helpers.dart';

/// Wraps [answer] the way the Messages API returns a structured-output reply.
http.Response apiReply(Map<String, dynamic> answer,
    {String stop = 'end_turn'}) {
  return http.Response(
    jsonEncode({
      'id': 'msg_test',
      'type': 'message',
      'role': 'assistant',
      'model': 'claude-opus-5-5',
      'stop_reason': stop,
      'content': [
        {'type': 'thinking', 'thinking': '', 'signature': 'sig'},
        {'type': 'text', 'text': jsonEncode(answer)},
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

Map<String, dynamic> answer({
  bool isEquipment = true,
  String catalogId = 'none',
  double confidence = 0.9,
  String name = 'Hip Thrust Machine',
  String category = 'machine',
  String setupNotes = '',
}) {
  return {
    'is_gym_equipment': isEquipment,
    'catalog_id': catalogId,
    'confidence': confidence,
    'equipment_name': name,
    'category': category,
    'setup_notes': setupNotes,
    'exercise': {
      'name': 'Machine Hip Thrust',
      'difficulty': 'beginner',
      'primary_muscles': ['Glutes'],
      'secondary_muscles': ['Hamstrings'],
      'steps': ['Sit with your upper back on the pad.', 'Drive hips up.'],
      'safety_tips': ['Keep your chin tucked.'],
      'common_mistakes': ['Arching the lower back.'],
    },
  };
}

void main() {
  late http.Request captured;

  ClaudeRecognitionService serviceReturning(http.Response response) {
    return ClaudeRecognitionService(
      apiKey: 'test-key',
      catalog: EquipmentRepository.catalog,
      client: MockClient((request) async {
        captured = request;
        return response;
      }),
    );
  }

  test('sends the photo to Claude with the catalog in the schema', () async {
    final service = serviceReturning(apiReply(answer()));
    await service.recogniseEquipment(fakeJpeg);

    expect(captured.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(captured.headers['x-api-key'], 'test-key');
    expect(captured.headers['anthropic-version'], '2023-06-01');

    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['model'], 'claude-opus-5-5');
    expect(body['fallbacks'], 'default');

    final image = (body['messages'][0]['content'] as List).first as Map;
    expect(image['type'], 'image');
    expect(image['source']['media_type'], 'image/jpeg');
    expect(image['source']['data'], base64Encode(fakeJpeg));

    final schema = body['output_config']['format']['schema'] as Map;
    final ids = schema['properties']['catalog_id']['enum'] as List;
    expect(ids, containsAll(['leg_press', 'treadmill', 'none']));
  });

  test('catalog match uses the curated catalog entry', () async {
    final service = serviceReturning(apiReply(answer(
      catalogId: 'leg_press',
      confidence: 0.93,
      name: 'Leg Press',
      setupNotes: 'Seat adjusts with the red lever on the right.',
    )));

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.recognised);
    expect(result.isCatalogMatch, isTrue);
    expect(result.catalogId, 'leg_press');
    expect(result.equipment!.name, 'Leg Press Machine');
    expect(result.exercise, isNull);
    expect(result.confidence, 0.93);
    expect(result.setupNotes, 'Seat adjusts with the red lever on the right.');
  });

  test('equipment outside the catalog gets an AI-written guide', () async {
    final service = serviceReturning(apiReply(answer()));

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.recognised);
    expect(result.isCatalogMatch, isFalse);
    expect(result.equipment!.name, 'Hip Thrust Machine');
    expect(result.equipment!.category, EquipmentCategory.machine);
    expect(result.exercise!.name, 'Machine Hip Thrust');
    expect(result.exercise!.steps, hasLength(2));
    expect(result.exercise!.difficulty, ExerciseDifficulty.beginner);
    expect(result.setupNotes, isNull);
  });

  test('a photo without equipment is reported as such', () async {
    final service = serviceReturning(
      apiReply(answer(isEquipment: false, name: 'a water bottle')),
    );

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.notEquipment);
    expect(result.message, contains('a water bottle'));
  });

  test('a refusal becomes a failure, not a crash', () async {
    final service = serviceReturning(http.Response(
      jsonEncode({'stop_reason': 'refusal', 'content': <dynamic>[]}),
      200,
    ));

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.failed);
  });

  test('a malformed answer becomes a failure, not a crash', () async {
    final service = serviceReturning(http.Response(
      jsonEncode({
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'text', 'text': '{"is_gym_equipment": true}'},
        ],
      }),
      200,
    ));

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.failed);
    expect(result.message, contains('unreadable'));
  });

  test('a rejected API key gets a clear message', () async {
    final service = serviceReturning(http.Response(
      jsonEncode({
        'type': 'error',
        'error': {
          'type': 'authentication_error',
          'message': 'invalid x-api-key'
        },
      }),
      401,
    ));

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.failed);
    expect(result.message, contains('API key was rejected'));
  });

  test('no connection gets a clear message', () async {
    final service = ClaudeRecognitionService(
      apiKey: 'test-key',
      catalog: EquipmentRepository.catalog,
      client: MockClient((_) => throw const SocketException('offline')),
    );

    final result = await service.recogniseEquipment(fakeJpeg);

    expect(result.status, RecognitionStatus.failed);
    expect(result.message, contains('No internet connection'));
  });

  test('unsupported image formats fail without calling the API', () async {
    var called = false;
    final service = ClaudeRecognitionService(
      apiKey: 'test-key',
      catalog: EquipmentRepository.catalog,
      client: MockClient((_) async {
        called = true;
        return http.Response('', 200);
      }),
    );

    // HEIC files start with an ftyp box, which the API doesn't accept.
    final heic = Uint8List.fromList(
      [0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63],
    );
    final result = await service.recogniseEquipment(heic);

    expect(result.status, RecognitionStatus.failed);
    expect(called, isFalse);
  });

  test('detects supported image formats from their bytes', () {
    expect(
        ClaudeRecognitionService.detectImageMediaType(fakeJpeg), 'image/jpeg');
    expect(
      ClaudeRecognitionService.detectImageMediaType(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]),
      ),
      'image/png',
    );
    expect(
      ClaudeRecognitionService.detectImageMediaType(
        Uint8List.fromList(utf8.encode('RIFF\x00\x00\x00\x00WEBPVP8 ')),
      ),
      'image/webp',
    );
    expect(ClaudeRecognitionService.detectImageMediaType(Uint8List(2)), isNull);
  });
}
