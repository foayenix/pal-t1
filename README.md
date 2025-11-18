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
- [x] Navigation setup
- [x] Placeholder screens
- [ ] Data models
- [ ] Mock recognition service
- [ ] Firebase integration
- [ ] Seed data
- [ ] Video player

## License

MIT
