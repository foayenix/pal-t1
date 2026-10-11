import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/recognition_result.dart';
import '../../providers/providers.dart';

/// State for the scan screen
enum ScanState { initial, capturing, processing, error }

/// Scan screen for capturing or selecting equipment images.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  ScanState _state = ScanState.initial;
  Uint8List? _selectedImage;
  String _errorTitle = '';
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _state = ScanState.capturing;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      if (!mounted) return;

      if (image == null) {
        setState(() => _state = ScanState.initial);
        return;
      }
      await _processImage(await image.readAsBytes());
    } catch (e) {
      _showError(
        'Couldn\'t get the photo',
        source == ImageSource.camera
            ? 'The camera couldn\'t be opened. Check that PAL has camera '
                'permission in your phone\'s settings.'
            : 'The photo couldn\'t be loaded. Check that PAL has photo '
                'access in your phone\'s settings.',
      );
    }
  }

  Future<void> _processImage(Uint8List imageBytes) async {
    setState(() {
      _selectedImage = imageBytes;
      _state = ScanState.processing;
    });

    final recognitionService = ref.read(recognitionServiceProvider);
    final result = await recognitionService.recogniseEquipment(imageBytes);
    if (!mounted) return;

    switch (result.status) {
      case RecognitionStatus.failed:
        _showError('Something went wrong',
            result.message ?? 'Recognition failed. Please try again.');
      case RecognitionStatus.notEquipment:
        _showError(
          'Couldn\'t spot any equipment',
          '${result.message ?? 'That doesn\'t look like gym equipment.'} '
              'Try again with the whole machine in frame.',
        );
      case RecognitionStatus.recognised:
        if (!result.isConfident(AppConstants.minConfidenceThreshold)) {
          final guess = result.equipment?.name;
          _showError(
            'Not sure what that is',
            '${guess == null ? 'The photo was too unclear' : 'It might be a $guess, but I\'m not confident'}. '
                'Try a clearer photo from a few steps back, or pick it manually.',
          );
          return;
        }
        ref.read(lastScanProvider.notifier).state = result;
        context.pushReplacement(AppRoutes.scanResults);
    }
  }

  void _showError(String title, String message) {
    if (!mounted) return;
    setState(() {
      _state = ScanState.error;
      _errorTitle = title;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Equipment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGoHome(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!ref.watch(scanConfiguredProvider)) {
      return _buildNotConfiguredView();
    }
    switch (_state) {
      case ScanState.initial:
        return _buildInitialView();
      case ScanState.capturing:
        return _buildCapturingView();
      case ScanState.processing:
        return _buildProcessingView();
      case ScanState.error:
        return _buildErrorView();
    }
  }

  Widget _buildNotConfiguredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.key_off, size: 64, color: AppColors.warning),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Scanning isn\'t set up yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'This build has no Anthropic API key. Rebuild the app with '
              '--dart-define-from-file=pal_secrets.json (see the README). '
              'You can still browse equipment manually.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton(
              onPressed: () => context.pushReplacement(AppRoutes.browse),
              child: const Text('Browse Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'Point your camera at the gym equipment',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Make sure the equipment is clearly visible and well-lit',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Take photo button
          SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text(
                'Take Photo',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Pick from gallery button
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 24),
              label: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacingXl),

          // Browse manually link
          TextButton(
            onPressed: () {
              context.pushReplacement(AppRoutes.browse);
            },
            child: const Text(
              'Or browse equipment manually',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.spacingMd),
          Text('Opening camera...'),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show selected image
            if (_selectedImage != null)
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: AppConstants.spacingXl),

            // Loading indicator
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),

            const SizedBox(height: AppConstants.spacingMd),

            Text(
              'Recognising equipment...',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: AppConstants.spacingSm),

            Text(
              'This may take a few seconds',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
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
              _errorTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _state = ScanState.initial;
                  _errorMessage = null;
                });
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            OutlinedButton(
              onPressed: () {
                context.pushReplacement(AppRoutes.browse);
              },
              child: const Text('Browse Manually'),
            ),
          ],
        ),
      ),
    );
  }
}
