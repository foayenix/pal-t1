import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../../providers/providers.dart';

/// Browse screen for manually selecting equipment.
class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEquipmentAsync = ref.watch(filteredEquipmentProvider);
    final searchQuery = ref.watch(equipmentSearchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Equipment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: TextField(
              onChanged: (value) {
                ref.read(equipmentSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(equipmentSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category filter
          _buildCategoryFilter(context, ref, selectedCategory),

          const SizedBox(height: AppConstants.spacingMd),

          // Equipment list
          Expanded(
            child: filteredEquipmentAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (equipment) {
                if (equipment.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildEquipmentList(context, equipment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref, String selectedCategory) {
    final categories = [
      'All',
      ...EquipmentCategory.values.map((c) => c.displayName),
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingSm),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (selected) {
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No equipment found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Try adjusting your search or filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList(BuildContext context, List<Equipment> equipmentList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: equipmentList.length,
      itemBuilder: (context, index) {
        final equipment = equipmentList[index];
        return _buildEquipmentCard(context, equipment);
      },
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Equipment equipment) {
    IconData iconData;
    switch (equipment.category) {
      case EquipmentCategory.cardio:
        iconData = Icons.directions_run;
        break;
      case EquipmentCategory.freeWeight:
        iconData = Icons.fitness_center;
        break;
      case EquipmentCategory.machine:
        iconData = Icons.precision_manufacturing;
        break;
      case EquipmentCategory.cable:
        iconData = Icons.cable;
        break;
      case EquipmentCategory.bodyweight:
        iconData = Icons.accessibility_new;
        break;
      default:
        iconData = Icons.fitness_center;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.results,
            extra: {
              'equipmentId': equipment.id,
              'confidence': 0.0, // No confidence since manually selected
            },
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              // Equipment icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  iconData,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: AppConstants.spacingMd),

              // Equipment details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSm,
                        vertical: AppConstants.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: Text(
                        equipment.category.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
