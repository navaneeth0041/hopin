import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TabSelector extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  const TabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Report Issue',
              value: 'report',
              icon: Icons.report_problem_outlined,
              isSelected: selectedTab == 'report',
              onTap: () => onTabChanged('report'),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _TabItem(
              label: 'Get Support',
              value: 'support',
              icon: Icons.headset_mic_outlined,
              isSelected: selectedTab == 'support',
              onTap: () => onTabChanged('support'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}