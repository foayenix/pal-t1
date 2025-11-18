import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Browse screen for manually selecting equipment.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // TODO: Replace with actual data from repository
  final List<Map<String, dynamic>> _mockEquipment = [
    {
      'id': 'leg_press',
      'name': 'Leg Press Machine',
      'category': 'Machine',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'lat_pulldown',
      'name': 'Lat Pulldown Machine',
      'category': 'Machine',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'chest_press',
      'name': 'Chest Press Machine',
      'category': 'Machine',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'treadmill',
      'name': 'Treadmill',
      'category': 'Cardio',
      'icon': Icons.directions_run,
    },
    {
      'id': 'rowing_machine',
      'name': 'Rowing Machine',
      'category': 'Cardio',
      'icon': Icons.rowing,
    },
    {
      'id': 'cable_crossover',
      'name': 'Cable Crossover',
      'category': 'Cable',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'dumbbells',
      'name': 'Dumbbells',
      'category': 'Free Weight',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'barbell_bench',
      'name': 'Barbell Bench Press',
      'category': 'Free Weight',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'squat_rack',
      'name': 'Squat Rack',
      'category': 'Free Weight',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'smith_machine',
      'name': 'Smith Machine',
      'category': 'Machine',
      'icon': Icons.fitness_center,
    },
  ];

  List<String> get _categories {
    final categories = _mockEquipment
        .map((e) => e['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<Map<String, dynamic>> get _filteredEquipment {
    return _mockEquipment.where((equipment) {
      final matchesCategory = _selectedCategory == 'All' ||
          equipment['category'] == _selectedCategory;
      final matchesSearch = equipment['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spacingSm),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Equipment list
          Expanded(
            child: _filteredEquipment.isEmpty
                ? _buildEmptyState()
                : _buildEquipmentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildEquipmentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: _filteredEquipment.length,
      itemBuilder: (context, index) {
        final equipment = _filteredEquipment[index];
        return _buildEquipmentCard(equipment);
      },
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.results,
            extra: {
              'equipmentId': equipment['id'],
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
                  equipment['icon'] as IconData,
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
                      equipment['name'] as String,
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
                        equipment['category'] as String,
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
