import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:pal_app/app/app.dart';
import 'package:pal_app/core/constants/app_constants.dart';
import 'package:pal_app/models/equipment.dart';
import 'package:pal_app/models/exercise.dart';
import 'package:pal_app/models/recognition_result.dart';
import 'package:pal_app/providers/providers.dart';
import 'package:pal_app/repositories/equipment_repository.dart';

import '../helpers.dart';

const _hipThrust = Equipment(
  id: 'scanned_hip_thrust_machine',
  name: 'Hip Thrust Machine',
  category: EquipmentCategory.machine,
  defaultExerciseId: 'scanned_hip_thrust_machine_exercise',
);

const _hipThrustGuide = Exercise(
  id: 'scanned_hip_thrust_machine_exercise',
  equipmentId: 'scanned_hip_thrust_machine',
  name: 'Machine Hip Thrust',
  difficulty: ExerciseDifficulty.beginner,
  primaryMuscles: ['Glutes'],
  secondaryMuscles: [],
  steps: ['Sit with your upper back on the pad.'],
  safetyTips: ['Keep your chin tucked.'],
  commonMistakes: ['Arching the lower back.'],
);

void main() {
  late FakeImagePicker picker;
  late FakeRecognitionService recogniser;

  setUp(() {
    picker = FakeImagePicker();
    ImagePickerPlatform.instance = picker;
    recogniser = FakeRecognitionService(RecognitionResult.failed('unset'));
  });

  Future<void> startApp(WidgetTester tester, {bool configured = true}) async {
    // A tall surface so the scan buttons and results fit without scrolling.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recognitionServiceProvider.overrideWithValue(recogniser),
          scanConfiguredProvider.overrideWithValue(configured),
        ],
        child: const PalApp(),
      ),
    );
    await pumpPastSplash(tester);
  }

  Future<void> scanAPhoto(WidgetTester tester) async {
    await tester.tap(find.text('Scan Equipment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();
  }

  testWidgets('splash hands over to home', (tester) async {
    await startApp(tester);

    expect(find.text('Scan Equipment'), findsOneWidget);
    expect(find.text('Browse Equipment Manually'), findsOneWidget);
    expect(find.text('Recent Scans'), findsNothing);
  });

  testWidgets('scanning a catalog machine shows its curated guide',
      (tester) async {
    recogniser.result = RecognitionResult(
      status: RecognitionStatus.recognised,
      confidence: 0.92,
      catalogId: 'leg_press',
      equipment:
          EquipmentRepository.catalog.firstWhere((e) => e.id == 'leg_press'),
      setupNotes: 'The seat lever is on your right.',
    );
    await startApp(tester);

    await scanAPhoto(tester);

    expect(recogniser.calls, 1);
    expect(find.text('How to Use It'), findsOneWidget);
    expect(find.text('Leg Press Machine'), findsOneWidget);
    expect(find.text('The seat lever is on your right.'), findsOneWidget);
    expect(find.textContaining('Identified (92% sure)'), findsOneWidget);
    expect(find.textContaining('written by AI'), findsNothing);

    // Back goes home, not to a scan screen stuck on a spinner.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Scan Equipment'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('scanning unknown equipment shows the AI-written guide',
      (tester) async {
    recogniser.result = const RecognitionResult(
      status: RecognitionStatus.recognised,
      confidence: 0.6,
      equipment: _hipThrust,
      exercise: _hipThrustGuide,
    );
    await startApp(tester);

    await scanAPhoto(tester);

    expect(find.text('Machine Hip Thrust'), findsOneWidget);
    expect(find.text('Hip Thrust Machine'), findsOneWidget);
    expect(find.textContaining('written by AI'), findsOneWidget);
    expect(find.textContaining('Best guess (60% sure)'), findsOneWidget);
    expect(find.text('Sit with your upper back on the pad.'), findsOneWidget);
  });

  testWidgets('a low-confidence scan asks for a better photo instead',
      (tester) async {
    recogniser.result = const RecognitionResult(
      status: RecognitionStatus.recognised,
      confidence: AppConstants.minConfidenceThreshold - 0.1,
      equipment: _hipThrust,
      exercise: _hipThrustGuide,
    );
    await startApp(tester);

    await scanAPhoto(tester);

    expect(find.text('Not sure what that is'), findsOneWidget);
    expect(
        find.textContaining('might be a Hip Thrust Machine'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Take Photo'), findsOneWidget);
  });

  testWidgets('a failed scan shows the reason and offers manual browse',
      (tester) async {
    recogniser.result = RecognitionResult.failed('No internet connection.');
    await startApp(tester);

    await scanAPhoto(tester);

    expect(find.text('No internet connection.'), findsOneWidget);
    await tester.tap(find.text('Browse Manually'));
    await tester.pumpAndSettle();
    expect(find.text('Browse Equipment'), findsOneWidget);
  });

  testWidgets('cancelling the camera returns to the scan options',
      (tester) async {
    picker.cancel = true;
    await startApp(tester);

    await scanAPhoto(tester);

    expect(recogniser.calls, 0);
    expect(find.text('Take Photo'), findsOneWidget);
  });

  testWidgets('without an API key, scanning explains how to set it up',
      (tester) async {
    await startApp(tester, configured: false);

    await tester.tap(find.text('Scan Equipment'));
    await tester.pumpAndSettle();

    expect(find.text('Scanning isn\'t set up yet'), findsOneWidget);
    expect(find.text('Take Photo'), findsNothing);
  });

  testWidgets('browsing to a machine shows its guide without a confidence',
      (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Browse Equipment Manually'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'treadmill');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Treadmill'));
    await tester.pumpAndSettle();

    expect(find.text('How to Use It'), findsOneWidget);
    expect(find.textContaining('sure)'), findsNothing);
    expect(find.text('Watch a demo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Browse Equipment'), findsOneWidget);
  });
}
