import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/browse/browse_screen.dart';
import '../features/home/home_screen.dart';
import '../features/results/results_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/splash/splash_screen.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String results = '/results';
  static const String scanResults = '/results/scan';
  static const String browse = '/browse';

  /// Results for a catalog item picked manually.
  static String catalogResults(String equipmentId) =>
      Uri(path: results, queryParameters: {'equipmentId': equipmentId})
          .toString();
}

/// Pops the current screen, or goes home if there's nothing to pop
/// (e.g. after a `go` or a deep link).
void popOrGoHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

/// Global router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanResults,
        name: 'scanResults',
        builder: (context, state) => const ResultsScreen.scan(),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) => ResultsScreen.catalog(
          equipmentId: state.uri.queryParameters['equipmentId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.browse,
        name: 'browse',
        builder: (context, state) => const BrowseScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});
