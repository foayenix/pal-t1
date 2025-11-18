import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

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
    // TODO: Fetch actual equipment and exercise data from repository
    // For now, using mock data
    final mockExercise = _getMockExercise();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Equipment identification card
            _buildEquipmentCard(context, mockExercise),

            const SizedBox(height: AppConstants.spacingMd),

            // Video player placeholder
            _buildVideoPlayer(context, mockExercise['videoUrl'] as String),

            const SizedBox(height: AppConstants.spacingMd),

            // Muscles section
            _buildMusclesSection(context, mockExercise),

            const SizedBox(height: AppConstants.spacingMd),

            // Steps section
            _buildStepsSection(context, mockExercise),

            const SizedBox(height: AppConstants.spacingMd),

            // Safety tips section
            _buildSafetySection(context, mockExercise),

            const SizedBox(height: AppConstants.spacingMd),

            // Common mistakes section
            _buildMistakesSection(context, mockExercise),

            const SizedBox(height: AppConstants.spacingXl),

            // Action buttons
            _buildActionButtons(context),

            const SizedBox(height: AppConstants.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Map<String, dynamic> exercise) {
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
                        exercise['name'] as String,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        exercise['equipment'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildDifficultyBadge(context, exercise['difficulty'] as String),
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

  Widget _buildDifficultyBadge(BuildContext context, String difficulty) {
    Color badgeColor;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        badgeColor = AppColors.success;
        break;
      case 'intermediate':
        badgeColor = AppColors.warning;
        break;
      case 'advanced':
        badgeColor = AppColors.error;
        break;
      default:
        badgeColor = AppColors.info;
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
        difficulty,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: badgeColor,
            ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, String videoUrl) {
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
                      content: Text('Video player will be implemented'),
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

  Widget _buildMusclesSection(BuildContext context, Map<String, dynamic> exercise) {
    final primary = exercise['primaryMuscles'] as List<String>;
    final secondary = exercise['secondaryMuscles'] as List<String>;

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
              children: primary
                  .map((muscle) => Chip(
                        label: Text(muscle),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primary),
                      ))
                  .toList(),
            ),

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
              children: secondary
                  .map((muscle) => Chip(
                        label: Text(muscle),
                        backgroundColor: AppColors.borderLight,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, Map<String, dynamic> exercise) {
    final steps = exercise['steps'] as List<String>;

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
            ...steps.asMap().entries.map((entry) => Padding(
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

  Widget _buildSafetySection(BuildContext context, Map<String, dynamic> exercise) {
    final tips = exercise['safetyTips'] as List<String>;

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
            ...tips.map((tip) => Padding(
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

  Widget _buildMistakesSection(BuildContext context, Map<String, dynamic> exercise) {
    final mistakes = exercise['commonMistakes'] as List<String>;

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
            ...mistakes.map((mistake) => Padding(
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

  /// Mock exercise data - will be replaced with actual Firestore data
  Map<String, dynamic> _getMockExercise() {
    return {
      'name': 'Leg Press',
      'equipment': 'Leg Press Machine',
      'difficulty': 'Beginner',
      'primaryMuscles': ['Quadriceps', 'Glutes'],
      'secondaryMuscles': ['Hamstrings', 'Calves'],
      'steps': [
        'Adjust the seat so your knees are at a 90-degree angle when your feet are on the platform.',
        'Place your feet shoulder-width apart on the footplate.',
        'Grasp the handles on either side and keep your back flat against the seat.',
        'Push the platform away by extending your legs, but do not lock your knees.',
        'Slowly lower the weight back down, keeping control throughout the movement.',
        'Repeat for the desired number of repetitions.',
      ],
      'safetyTips': [
        'Never lock your knees at the top of the movement.',
        'Keep your lower back pressed firmly against the seat.',
        'Use a controlled tempo – avoid bouncing the weight.',
        'Start with lighter weight to master the form.',
      ],
      'commonMistakes': [
        'Allowing the lower back to round off the seat.',
        'Placing feet too high or too low on the platform.',
        'Locking knees at full extension.',
        'Using momentum instead of controlled movement.',
      ],
      'videoUrl': 'https://example.com/videos/leg-press.mp4',
    };
  }
}
