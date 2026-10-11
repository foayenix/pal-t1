import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../models/equipment.dart';
import '../../models/exercise.dart';
import '../../models/recognition_result.dart';
import 'recognition_service.dart';

/// Recognises gym equipment by sending the photo to Claude (vision).
///
/// Claude either matches the photo to the curated [catalog] (whose reviewed
/// guides the app then shows) or, for anything else, writes a usage guide
/// for the equipment it sees.
class ClaudeRecognitionService implements EquipmentRecognitionService {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-5-5';

  /// "low" keeps a scan to a few seconds; identification plus a standard
  /// usage guide doesn't need deeper reasoning.
  static const String _effort = 'low';

  static const Duration _timeout = Duration(seconds: 90);
  static const String _noMatch = 'none';

  final String apiKey;
  final List<Equipment> catalog;
  final http.Client _client;

  ClaudeRecognitionService({
    required this.apiKey,
    required this.catalog,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<RecognitionResult> recogniseEquipment(Uint8List imageBytes) async {
    final mediaType = detectImageMediaType(imageBytes);
    if (mediaType == null) {
      return RecognitionResult.failed(
        'That image format isn\'t supported. Try taking the photo again '
        'with the camera.',
      );
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'content-type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01',
              // Lets the API retry on a fallback model if a request is declined.
              'anthropic-beta': 'server-side-fallback-2026-07-01',
            },
            body: jsonEncode(_buildRequest(imageBytes, mediaType)),
          )
          .timeout(_timeout);
    } on TimeoutException {
      return RecognitionResult.failed(
        'The scan took too long. Check your connection and try again.',
      );
    } on SocketException {
      return RecognitionResult.failed(
        'No internet connection. Scanning needs a connection — you can '
        'still browse equipment manually.',
      );
    } on http.ClientException {
      return RecognitionResult.failed(
        'Couldn\'t reach the recognition service. Check your connection '
        'and try again.',
      );
    }

    if (response.statusCode != 200) {
      return RecognitionResult.failed(_describeHttpError(response));
    }

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return parseResponse(body as Map<String, dynamic>);
    } on FormatException {
      return _unreadable();
    } on TypeError {
      // A field had an unexpected shape.
      return _unreadable();
    }
  }

  RecognitionResult _unreadable() {
    return RecognitionResult.failed(
      'Got an unreadable answer from the recognition service. Try again.',
    );
  }

  Map<String, dynamic> _buildRequest(Uint8List imageBytes, String mediaType) {
    return {
      'model': _model,
      'max_tokens': 8000,
      'fallbacks': 'default',
      'output_config': {
        'effort': _effort,
        'format': {'type': 'json_schema', 'schema': _responseSchema},
      },
      'system': _systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': base64Encode(imageBytes),
              },
            },
            {
              'type': 'text',
              'text': 'What gym equipment is this, and how do I use it?',
            },
          ],
        },
      ],
    };
  }

  String get _systemPrompt {
    final catalogLines = catalog.map((e) => '- ${e.id}: ${e.name}').join('\n');
    return '''
You are PAL, a gym companion app. The user is a gym beginner who photographs a
piece of gym equipment and needs to know what it is and how to use it safely.

Identify the equipment in the photo. If it matches one of these catalog
entries, set catalog_id to that entry's id; otherwise set catalog_id to
"$_noMatch":
$catalogLines

Always fill in equipment_name, category and the exercise guide for the
equipment you see (for catalog matches too). The guide should cover the single
most common beginner exercise on this equipment: clear, numbered-style steps
written for someone who has never used it, the safety points that matter most,
and the mistakes beginners typically make. Use British English.

setup_notes: one or two sentences about this particular machine as it appears
in the photo, e.g. where the seat or pad adjustment is, which handles to use,
or the weight stack. Leave it empty if nothing specific is visible.

confidence: your confidence from 0 to 1 that you've identified the equipment
correctly. Be honest — a blurry, partial or ambiguous photo deserves a low
score.

If the photo does not show gym equipment, or is too unclear to tell, set
is_gym_equipment to false, catalog_id to "$_noMatch", explain briefly in
equipment_name what you see instead, and leave the exercise lists empty.''';
  }

  Map<String, dynamic> get _responseSchema {
    Map<String, dynamic> stringList() => {
          'type': 'array',
          'items': {'type': 'string'},
        };

    return {
      'type': 'object',
      'properties': {
        'is_gym_equipment': {'type': 'boolean'},
        'catalog_id': {
          'type': 'string',
          'enum': [...catalog.map((e) => e.id), _noMatch],
        },
        'confidence': {'type': 'number'},
        'equipment_name': {'type': 'string'},
        'category': {
          'type': 'string',
          'enum': EquipmentCategory.values.map((c) => c.name).toList(),
        },
        'setup_notes': {'type': 'string'},
        'exercise': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'difficulty': {
              'type': 'string',
              'enum': ExerciseDifficulty.values.map((d) => d.name).toList(),
            },
            'primary_muscles': stringList(),
            'secondary_muscles': stringList(),
            'steps': stringList(),
            'safety_tips': stringList(),
            'common_mistakes': stringList(),
          },
          'required': [
            'name',
            'difficulty',
            'primary_muscles',
            'secondary_muscles',
            'steps',
            'safety_tips',
            'common_mistakes',
          ],
          'additionalProperties': false,
        },
      },
      'required': [
        'is_gym_equipment',
        'catalog_id',
        'confidence',
        'equipment_name',
        'category',
        'setup_notes',
        'exercise',
      ],
      'additionalProperties': false,
    };
  }

  /// Converts a Messages API response body into a [RecognitionResult].
  RecognitionResult parseResponse(Map<String, dynamic> body) {
    final stopReason = body['stop_reason'];
    if (stopReason == 'refusal') {
      return RecognitionResult.failed(
        'The recognition service declined this photo. Try a different photo.',
      );
    }
    if (stopReason == 'max_tokens') {
      return RecognitionResult.failed(
        'The recognition answer was cut off. Try again.',
      );
    }

    // Content can also hold thinking blocks; the JSON answer is the text.
    final text = (body['content'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join();
    if (text.isEmpty) {
      return RecognitionResult.failed(
        'The recognition service returned no answer. Try again.',
      );
    }

    final data = jsonDecode(text) as Map<String, dynamic>;
    final name = (data['equipment_name'] as String? ?? '').trim();

    if (data['is_gym_equipment'] != true) {
      return RecognitionResult.notEquipment(
        name.isEmpty
            ? 'That doesn\'t look like gym equipment.'
            : 'That doesn\'t look like gym equipment ($name).',
      );
    }

    final confidence =
        ((data['confidence'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    final setupNotes = (data['setup_notes'] as String? ?? '').trim();

    final catalogId = data['catalog_id'] as String?;
    final catalogMatch = catalog.where((e) => e.id == catalogId).firstOrNull;

    if (catalogMatch != null) {
      return RecognitionResult(
        status: RecognitionStatus.recognised,
        confidence: confidence,
        catalogId: catalogMatch.id,
        equipment: catalogMatch,
        setupNotes: setupNotes.isEmpty ? null : setupNotes,
      );
    }

    final guide = data['exercise'] as Map<String, dynamic>;
    final equipmentId = 'scanned_${_slug(name)}';
    final exercise = Exercise(
      id: '${equipmentId}_exercise',
      equipmentId: equipmentId,
      name: guide['name'] as String,
      difficulty: ExerciseDifficulty.values.firstWhere(
        (d) => d.name == guide['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      primaryMuscles: List<String>.from(guide['primary_muscles'] as List),
      secondaryMuscles: List<String>.from(guide['secondary_muscles'] as List),
      steps: List<String>.from(guide['steps'] as List),
      safetyTips: List<String>.from(guide['safety_tips'] as List),
      commonMistakes: List<String>.from(guide['common_mistakes'] as List),
    );

    return RecognitionResult(
      status: RecognitionStatus.recognised,
      confidence: confidence,
      equipment: Equipment(
        id: equipmentId,
        name: name.isEmpty ? exercise.name : name,
        category: EquipmentCategory.values.firstWhere(
          (c) => c.name == data['category'],
          orElse: () => EquipmentCategory.other,
        ),
        defaultExerciseId: exercise.id,
      ),
      exercise: exercise,
      setupNotes: setupNotes.isEmpty ? null : setupNotes,
    );
  }

  String _describeHttpError(http.Response response) {
    String? apiMessage;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      apiMessage =
          (body['error'] as Map<String, dynamic>?)?['message'] as String?;
    } on FormatException {
      // Non-JSON error body; fall through to the generic message.
    }

    switch (response.statusCode) {
      case 401:
        return 'Your Anthropic API key was rejected. Check the key you built '
            'the app with.';
      case 403:
        return 'Your Anthropic API key isn\'t allowed to use this model.';
      case 413:
        return 'That photo is too large. Try again with the camera.';
      case 429:
        return 'Too many scans in a short time (or your API credit has run '
            'out). Wait a moment and try again.';
      case 500:
      case 529:
        return 'The recognition service is busy right now. Try again in a '
            'moment.';
      default:
        return 'Recognition failed (${response.statusCode})'
            '${apiMessage == null ? '' : ': $apiMessage'}';
    }
  }

  static String _slug(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'equipment' : slug;
  }

  /// Returns the image media type from the file's magic bytes, or null if it
  /// isn't a format the API accepts (JPEG, PNG, GIF, WebP).
  static String? detectImageMediaType(Uint8List bytes) {
    bool startsWith(List<int> sig, [int offset = 0]) {
      if (bytes.length < offset + sig.length) return false;
      for (var i = 0; i < sig.length; i++) {
        if (bytes[offset + i] != sig[i]) return false;
      }
      return true;
    }

    if (startsWith([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
    if (startsWith([0x89, 0x50, 0x4E, 0x47])) return 'image/png';
    if (startsWith([0x47, 0x49, 0x46, 0x38])) return 'image/gif';
    if (startsWith([0x52, 0x49, 0x46, 0x46]) &&
        startsWith([0x57, 0x45, 0x42, 0x50], 8)) {
      return 'image/webp';
    }
    return null;
  }

  @override
  void dispose() => _client.close();
}
