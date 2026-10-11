import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../models/exercise.dart';
import '../../models/recognition_result.dart';
import '../../providers/providers.dart';

/// Results screen showing the identified equipment and how to use it.
///
/// Shows either a catalog item picked from Browse ([ResultsScreen.catalog])
/// or the latest photo scan ([ResultsScreen.scan]).
class ResultsScreen extends ConsumerWidget {
  /// Catalog equipment to show; null means "show the latest scan".
  final String? equipmentId;

  const ResultsScreen.catalog({super.key, required String this.equipmentId});

  const ResultsScreen.scan({super.key}) : equipmentId = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use It'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGoHome(context),
        ),
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final catalogId = equipmentId;
    if (catalogId != null) {
      return _buildCatalogGuide(context, ref, catalogId, scan: null);
    }

    final scan = ref.watch(lastScanProvider);
    if (scan == null || !scan.isRecognised) {
      return _buildErrorState(context, 'No scan to show. Take a photo first.');
    }
    if (scan.isCatalogMatch) {
      return _buildCatalogGuide(context, ref, scan.catalogId!, scan: scan);
    }
    return _buildContent(context, scan.equipment!, scan.exercise!, scan: scan);
  }

  /// Loads the curated guide for a catalog item.
  Widget _buildCatalogGuide(
    BuildContext context,
    WidgetRef ref,
    String catalogId, {
    required RecognitionResult? scan,
  }) {
    final equipmentAsync = ref.watch(equipmentByIdProvider(catalogId));
    final exerciseAsync = ref.watch(exerciseByEquipmentIdProvider(catalogId));

    return equipmentAsync.when(
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
            return _buildContent(context, equipment, exercise, scan: scan);
          },
        );
      },
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

  Widget _buildContent(
    BuildContext context,
    Equipment equipment,
    Exercise exercise, {
    required RecognitionResult? scan,
  }) {
    final isAiGuide = scan != null && !scan.isCatalogMatch;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEquipmentCard(context, equipment, exercise, scan: scan),

          if (isAiGuide) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _buildNotice(
              context,
              icon: Icons.auto_awesome,
              color: AppColors.info,
              text: 'This guide was written by AI for the equipment in your '
                  'photo. If anything looks off, ask gym staff before lifting.',
            ),
          ],

          if (scan?.setupNotes != null) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _buildNotice(
              context,
              icon: Icons.tune,
              color: AppColors.primary,
              title: 'On this machine',
              text: scan!.setupNotes!,
            ),
          ],

          const SizedBox(height: AppConstants.spacingMd),

          _buildDemoLink(context, equipment, exercise),

          const SizedBox(height: AppConstants.spacingMd),

          // Muscles section
          if (exercise.primaryMuscles.isNotEmpty) ...[
            _buildMusclesSection(context, exercise),
            const SizedBox(height: AppConstants.spacingMd),
          ],

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
          _buildActionButtons(context, isScan: scan != null),

          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }

  Widget _buildNotice(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    String? title,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: color),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                ],
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    BuildContext context,
    Equipment equipment,
    Exercise exercise, {
    required RecognitionResult? scan,
  }) {
    final confidence = scan?.confidence ?? 0;
    final isLowConfidence =
        scan != null && !scan.isConfident(AppConstants.highConfidenceThreshold);
    final confidenceColor =
        isLowConfidence ? AppColors.warning : AppColors.success;

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
            if (scan != null) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Icon(
                    isLowConfidence ? Icons.help_outline : Icons.check_circle,
                    color: confidenceColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Expanded(
                    child: Text(
                      isLowConfidence
                          ? 'Best guess (${(confidence * 100).toStringAsFixed(0)}% sure) '
                              '— check it matches what you see'
                          : 'Identified (${(confidence * 100).toStringAsFixed(0)}% sure)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: confidenceColor,
                          ),
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

  Widget _buildDifficultyBadge(
      BuildContext context, ExerciseDifficulty difficulty) {
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
        color: badgeColor.withValues(alpha: 0.1),
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

  Widget _buildDemoLink(
      BuildContext context, Equipment equipment, Exercise exercise) {
    return OutlinedButton.icon(
      onPressed: () => _openDemoVideos(context, equipment, exercise),
      icon: const Icon(Icons.play_circle_outline),
      label: const Text('Watch a demo'),
    );
  }

  Future<void> _openDemoVideos(
    BuildContext context,
    Equipment equipment,
    Exercise exercise,
  ) async {
    final query = '${exercise.name} ${equipment.name} how to proper form';
    final uri =
        Uri.https('www.youtube.com', '/results', {'search_query': query});
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t open YouTube.')),
      );
    }
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
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
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
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingMd),
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
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingSm),
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
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingSm),
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

  Widget _buildActionButtons(BuildContext context, {required bool isScan}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.pushReplacement(AppRoutes.scan),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scan Again'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.browse),
          icon: const Icon(Icons.search),
          label: Text(
              isScan ? 'Not right? Pick manually' : 'Browse other equipment'),
        ),
      ],
    );
  }
}
