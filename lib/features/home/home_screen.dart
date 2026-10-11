import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Home screen with main CTA to scan equipment.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingXl),

              // Header
              Text(
                'Welcome to',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppConstants.spacingXs),

              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideX(begin: -0.1, duration: 400.ms),

              const SizedBox(height: AppConstants.spacingSm),

              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const Spacer(),

              // Main illustration placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.9, 0.9), duration: 500.ms),

              const Spacer(),

              // Primary CTA - Scan Equipment
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.scan),
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: const Text(
                    'Scan Equipment',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.3, duration: 400.ms),

              const SizedBox(height: AppConstants.spacingMd),

              // Secondary CTA - Browse Manually
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.browse),
                  icon: const Icon(Icons.list_alt, size: 24),
                  label: const Text(
                    'Browse Equipment Manually',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.3, duration: 400.ms),

              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
