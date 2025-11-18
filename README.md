# PAL - Personal AI Lifter

A gym companion app that recognises equipment and shows exercise instructions.

## Features

- **Equipment Recognition**: Take a photo of gym equipment and get instant exercise guidance
- **Exercise Details**: Step-by-step instructions, target muscles, safety tips
- **Video Demos**: Watch animated exercise demonstrations
- **Manual Browse**: Search and filter equipment manually

## Tech Stack

- **Frontend**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: go_router
- **Backend**: Firebase (Firestore, Storage)
- **Image Recognition**: Mock service (ready for Roboflow/TFLite integration)

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode
- Firebase project (optional for MVP)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Firebase Setup (Optional)

1. Create a Firebase project
2. Add Android/iOS apps
3. Download config files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Run FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── splash/
│   ├── home/
│   ├── scan/
│   ├── results/
│   └── browse/
├── models/
├── repositories/
└── services/
    └── recognition/
```

## MVP Status

- [x] Project scaffold
- [x] Navigation setup (go_router)
- [x] All screens implemented (Splash, Home, Scan, Results, Browse)
- [x] Data models (Equipment, Exercise, RecognitionResult)
- [x] Mock recognition service (ready for Roboflow/TFLite)
- [x] Repositories with seed data (15 equipment, 15 exercises)
- [x] Riverpod providers for state management
- [x] Reusable widget library
- [ ] Firebase integration (optional - uses local data for now)
- [ ] Video player (placeholder ready)

## How It Works

1. **Splash Screen**: Animated logo, auto-navigates to Home
2. **Home Screen**: "Scan Equipment" and "Browse Manually" CTAs
3. **Scan Screen**: Take photo or pick from gallery
4. **Recognition**: Mock service returns random equipment (swap for real ML later)
5. **Results Screen**: Shows exercise name, muscles, steps, safety tips, common mistakes
6. **Browse Screen**: Searchable/filterable list of all 15 equipment types

## Equipment Included

- Leg Press Machine
- Lat Pulldown Machine
- Chest Press Machine
- Treadmill
- Rowing Machine
- Cable Crossover Machine
- Dumbbells
- Barbell Bench Press
- Squat Rack
- Smith Machine
- Leg Curl Machine
- Leg Extension Machine
- Shoulder Press Machine
- Seated Row Machine
- Elliptical Trainer

## Integration Points

### Real Image Recognition

Replace `MockEquipmentRecognitionService` in `lib/providers/providers.dart`:

```dart
// For HTTP API (Roboflow)
final recognitionServiceProvider = Provider<EquipmentRecognitionService>((ref) {
  return RoboflowRecognitionService(
    apiKey: 'your-api-key',
    modelEndpoint: 'your-endpoint',
  );
});

// For on-device ML (TFLite)
final recognitionServiceProvider = Provider<EquipmentRecognitionService>((ref) {
  return TFLiteRecognitionService(
    modelPath: 'assets/models/equipment.tflite',
  );
});
```

### Firebase

1. Uncomment Firebase dependencies in `pubspec.yaml`
2. Run `flutterfire configure`
3. Uncomment Firebase init in `main.dart`
4. Update repositories to use Firestore instead of seed data

## License

MIT
