/// Build-time configuration, passed with `--dart-define-from-file`.
///
/// See the README: copy `pal_secrets.example.json` to `pal_secrets.json`,
/// add your key, and run `flutter run --dart-define-from-file=pal_secrets.json`.
class AppConfig {
  /// Anthropic API key used for photo recognition.
  ///
  /// It is compiled into the app, so only build with your own key for your
  /// own phone — never publish a build that contains it.
  static const String anthropicApiKey =
      String.fromEnvironment('ANTHROPIC_API_KEY');

  static bool get isScanConfigured => anthropicApiKey.isNotEmpty;
}
