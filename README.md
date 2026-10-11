# PAL - Point and Lift

Snap a photo of any piece of gym equipment and PAL tells you what it is and
how to use it: the exercise, step-by-step instructions, target muscles, safety
tips and common mistakes.

## How it works

1. **Scan**: take a photo (or pick one from your gallery).
2. **Recognise**: the photo goes to Claude (Anthropic's AI, with vision), which
   identifies the equipment.
   - If it's one of the 15 machines in PAL's curated catalog, you get the
     reviewed guide for that machine.
   - If it's anything else (a hip thrust machine, a hack squat, a GHD, ...),
     Claude writes a guide for what it sees. These are labelled as
     AI-written.
   - Either way you also get notes about *that* machine where visible (e.g.
     where the seat adjustment is).
3. **Unsure?** Low-confidence results ask for a clearer photo instead of
   guessing; borderline ones are shown but flagged as a best guess.
4. **Watch a demo** opens a YouTube search for the exercise.
5. **Browse** lets you pick from the catalog manually, with no connection or
   API key needed.

## Setup

### 1. Install Flutter

Flutter 3.x ([install guide](https://docs.flutter.dev/get-started/install)),
plus Android Studio (Android) and/or Xcode (iPhone).

### 2. Get an Anthropic API key

Create one at <https://console.anthropic.com/> and add some credit. Each scan
is one request to `claude-opus-5-5` with a downscaled photo, costing roughly a
few US cents.

### 3. Add your key

```bash
cp pal_secrets.example.json pal_secrets.json
# edit pal_secrets.json and paste your key
```

`pal_secrets.json` is gitignored, so don't commit it.

> **The key is compiled into the app.** That's fine for an app only you
> install on your own phone. Never share or publish a build made with your
> key: anyone with the app file can extract it. If you ever want to share
> PAL, move the Claude call behind a small server first.

### 4. Run it

```bash
flutter pub get
flutter run --dart-define-from-file=pal_secrets.json
```

Without the key, the app still runs and browsing works. The Scan screen
explains how to set the key up.

To install a standalone build on an Android phone:

```bash
flutter build apk --release --dart-define-from-file=pal_secrets.json
# then install build/app/outputs/flutter-apk/app-release.apk
```

## Development

```bash
flutter analyze
flutter test
```

Tests cover the Claude response handling (catalog match, AI-written guide,
not-equipment, refusals, malformed answers, bad key, no connection,
unsupported image formats) and the app flows (scan → guide, low confidence,
failures, cancelled camera, missing key, browse).

## Project structure

```
lib/
├── main.dart
├── app/                    # App widget, routes
├── core/
│   ├── config/             # Build-time config (API key)
│   ├── constants/          # Spacing, thresholds, enums
│   └── theme/
├── features/               # splash, home, scan, results, browse
├── models/                 # Equipment, Exercise, RecognitionResult
├── providers/              # Riverpod providers
├── repositories/           # Curated catalog (15 machines + guides)
└── services/recognition/   # Claude vision recognition
```

## Curated catalog

Leg Press, Lat Pulldown, Chest Press, Treadmill, Rowing Machine, Cable
Crossover, Dumbbells, Barbell Bench Press, Squat Rack, Smith Machine, Leg Curl,
Leg Extension, Shoulder Press, Seated Row, Elliptical Trainer.

Anything else is handled by the AI-written guide.

## Safety

PAL's guides are general instructions, not personal coaching. If something
feels wrong or you're unsure about a machine, ask gym staff.

## License

MIT. The Poppins font (`assets/fonts/`) is under the SIL Open Font License; see
`assets/fonts/OFL.txt`.
