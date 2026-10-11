/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'PAL';
  static const String appFullName = 'Point and Lift';
  static const String appTagline = 'Point, snap, lift smarter.';
  static const String appVersion = '1.0.0';

  // Animation durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Recognition confidence: below the minimum we don't show a guide at all;
  // between the two we show it but flag it as a best guess.
  static const double minConfidenceThreshold = 0.4;
  static const double highConfidenceThreshold = 0.75;

  // Image settings (photos are downscaled before upload to keep scans fast)
  static const int maxImageWidth = 1280;
  static const int maxImageHeight = 1280;
  static const int imageQuality = 85;
}

/// Equipment categories
enum EquipmentCategory {
  machine('Machine'),
  freeWeight('Free Weight'),
  cardio('Cardio'),
  cable('Cable'),
  bodyweight('Bodyweight'),
  other('Other');

  final String displayName;
  const EquipmentCategory(this.displayName);
}

/// Exercise difficulty levels
enum ExerciseDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String displayName;
  const ExerciseDifficulty(this.displayName);
}
