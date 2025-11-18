import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../models/exercise.dart';
import '../../providers/providers.dart';

/// Results screen showing detected equipment and exercise details.
class ResultsScreen extends ConsumerWidget {
  final String equipmentId;
  final double confidence;

  const ResultsScreen({
    super.key,
    required this.equipmentId,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch equipment and exercise data
    final equipmentAsync = ref.watch(equipmentByIdProvider(equipmentId));
    final exerciseAsync = ref.watch(exerciseByEquipmentIdProvider(equipmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
        data: (equipment) {
          if (equipment == null) {
            return _buildErrorState(context, 'Equipment not found');
          }

          return exerciseAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(context, error.toString()),
            data: (exercise) {
              if (exercise == null) {
                return _buildErrorState(context, 'Exercise not found');
              }

              return _buildContent(context, equipment, exercise);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Equipment equipment, Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Equipment identification card
          _buildEquipmentCard(context, equipment, exercise),

          const SizedBox(height: AppConstants.spacingMd),

          // Video player placeholder
          _buildVideoPlayer(context, exercise.videoUrl),

          const SizedBox(height: AppConstants.spacingMd),

          // Muscles section
          _buildMusclesSection(context, exercise),

          const SizedBox(height: AppConstants.spacingMd),

          // Steps section
          _buildStepsSection(context, exercise),

          const SizedBox(height: AppConstants.spacingMd),

          // Safety tips section
          if (exercise.safetyTips.isNotEmpty) ...[
            _buildSafetySection(context, exercise),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          // Common mistakes section
          if (exercise.commonMistakes.isNotEmpty) ...[
            _buildMistakesSection(context, exercise),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          const SizedBox(height: AppConstants.spacingLg),

          // Action buttons
          _buildActionButtons(context),

          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Equipment equipment, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildDifficultyBadge(context, exercise.difficulty),
              ],
            ),
            if (confidence > 0) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, ExerciseDifficulty difficulty) {
    Color badgeColor;
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        badgeColor = AppColors.success;
        break;
      case ExerciseDifficulty.intermediate:
        badgeColor = AppColors.warning;
        break;
      case ExerciseDifficulty.advanced:
        badgeColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        difficulty.displayName,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: badgeColor,
            ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, String? videoUrl) {
    // TODO: Implement actual video player with chewie
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement video playback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video player coming soon'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Watch Exercise Demo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusclesSection(BuildContext context, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Muscles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Primary muscles
            Text(
              'Primary',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: exercise.primaryMuscles
                  .map((muscle) => Chip(
                        label: Text(muscle),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primary),
                      ))
                  .toList(),
            ),

            if (exercise.secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingMd),

              // Secondary muscles
              Text(
                'Secondary',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: exercise.secondaryMuscles
                    .map((muscle) => Chip(
                          label: Text(muscle),
                          backgroundColor: AppColors.borderLight,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Perform',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...exercise.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySection(BuildContext context, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: AppColors.success),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Safety Tips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...exercise.safetyTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Expanded(
                        child: Text(
                          tip,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakesSection(BuildContext context, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppColors.warning),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Common Mistakes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...exercise.commonMistakes.map((mistake) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cancel,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Expanded(
                        child: Text(
                          mistake,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.scan),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan Again'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.browse),
          icon: const Icon(Icons.search),
          label: const Text('Not right? Pick manually'),
        ),
      ],
    );
  }
}
