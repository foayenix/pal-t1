import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/results/results_screen.dart';
import '../features/browse/browse_screen.dart';

/// Route names for type-safe navigation
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String results = '/results';
  static const String browse = '/browse';
}

/// Global router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
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
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) {
          // Get equipment ID from query parameters or extra data
          final equipmentId = state.uri.queryParameters['equipmentId'] ??
                              (state.extra as Map<String, dynamic>?)?['equipmentId'] ?? '';
          final confidence = double.tryParse(
            state.uri.queryParameters['confidence'] ??
            (state.extra as Map<String, dynamic>?)?['confidence']?.toString() ?? '0'
          ) ?? 0.0;

          return ResultsScreen(
            equipmentId: equipmentId,
            confidence: confidence,
          );
        },
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
