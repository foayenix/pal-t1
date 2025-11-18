import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Splash screen with PAL logo and tagline.
/// Navigates to Home after initialisation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for splash duration then navigate
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms),

            const SizedBox(height: 8),

            // Full name
            Text(
              AppConstants.appFullName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),

            const SizedBox(height: 48),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.8),
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 500.ms),

            const SizedBox(height: 64),

            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
