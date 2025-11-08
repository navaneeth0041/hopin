import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/common_widgets/custom_buttons.dart';

class RideFilterOptions {
  String? priceRange;
  int? minSeats;
  String? sortBy;

  RideFilterOptions({this.priceRange, this.minSeats, this.sortBy});

  RideFilterOptions copyWith({
    String? priceRange,
    int? minSeats,
    String? sortBy,
  }) {
    return RideFilterOptions(
      priceRange: priceRange ?? this.priceRange,
      minSeats: minSeats ?? this.minSeats,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      priceRange != null || minSeats != null || sortBy != null;
}

class FilterBottomSheet extends StatefulWidget {
  final RideFilterOptions currentFilters;

  const FilterBottomSheet({super.key, required this.currentFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RideFilterOptions _filters;

  final List<String> _priceRanges = [
    'Under ₹50',
    '₹50 - ₹100',
    '₹100 - ₹200',
    'Above ₹200',
  ];

  final List<String> _sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Time: Earliest First',
    'Time: Latest First',
    'Seats: Most Available',
  ];

  @override
  void initState() {
    super.initState();
    _filters = RideFilterOptions(
      priceRange: widget.currentFilters.priceRange,
      minSeats: widget.currentFilters.minSeats,
      sortBy: widget.currentFilters.sortBy,
    );
  }

  void _clearFilters() {
    setState(() {
      _filters = RideFilterOptions();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Rides',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_filters.hasActiveFilters)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Price Range'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _priceRanges.map((range) {
                          final isSelected = _filters.priceRange == range;
                          return _buildChoiceChip(
                            label: range,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _filters = _filters.copyWith(
                                  priceRange: isSelected ? null : range,
                                );
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Minimum Available Seats'),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(6, (index) {
                          final seats = index + 1;
                          final isSelected = _filters.minSeats == seats;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index < 5 ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filters = _filters.copyWith(
                                      minSeats: isSelected ? null : seats,
                                    );
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryYellow
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryYellow
                                          : AppColors.divider,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$seats',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.black
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      _buildSectionTitle('Sort By'),
                      const SizedBox(height: 12),
                      ..._sortOptions.map((option) {
                        final isSelected = _filters.sortBy == option;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: RadioListTile<String>(
                            value: option,
                            groupValue: _filters.sortBy,
                            onChanged: (value) {
                              setState(() {
                                _filters = _filters.copyWith(sortBy: value);
                              });
                            },
                            title: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            activeColor: AppColors.primaryYellow,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: isSelected
                                ? AppColors.primaryYellow.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  label: 'Apply Filters',
                  onPressed: _applyFilters,
                  height: 56,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryYellow
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
