import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

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
  File? _selectedImage;
  String? _errorMessage;

  Future<void> _takePhoto() async {
    try {
      setState(() {
        _state = ScanState.capturing;
        _errorMessage = null;
      });

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (photo != null) {
        await _processImage(File(photo.path));
      } else {
        setState(() => _state = ScanState.initial);
      }
    } catch (e) {
      setState(() {
        _state = ScanState.error;
        _errorMessage = 'Failed to capture photo: ${e.toString()}';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _state = ScanState.capturing;
        _errorMessage = null;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        await _processImage(File(image.path));
      } else {
        setState(() => _state = ScanState.initial);
      }
    } catch (e) {
      setState(() {
        _state = ScanState.error;
        _errorMessage = 'Failed to select image: ${e.toString()}';
      });
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _state = ScanState.processing;
    });

    // TODO: Call the actual recognition service here
    // For now, simulate processing and navigate to results with mock data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navigate to results with mock equipment ID
      // In real implementation, this would come from the recognition service
      context.push(
        AppRoutes.results,
        extra: {
          'equipmentId': 'leg_press', // Mock equipment ID
          'confidence': 0.87,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Equipment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              color: AppColors.primary.withOpacity(0.1),
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
              onPressed: _takePhoto,
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
              onPressed: _pickFromGallery,
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
              context.pop();
              context.push(AppRoutes.browse);
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
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
              'Oops! Something went wrong',
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
          ],
        ),
      ),
    );
  }
}
