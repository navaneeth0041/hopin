import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final VoidCallback onMoreFilters;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onMoreFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('All', selectedFilter == 'All'),
          const SizedBox(width: 8),
          _buildFilterChip('Today', selectedFilter == 'Today'),
          const SizedBox(width: 8),
          _buildFilterChip('This Week', selectedFilter == 'This Week'),
          const SizedBox(width: 8),
          _buildMoreFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onFilterSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryYellow
                : AppColors.divider,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreFiltersButton() {
    return GestureDetector(
      onTap: onMoreFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.tune,
              size: 18,
              color: AppColors.primaryYellow,
            ),
            SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}