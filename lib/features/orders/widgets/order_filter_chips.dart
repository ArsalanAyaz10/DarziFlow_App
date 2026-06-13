import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';

class OrderFilterChips extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const OrderFilterChips({
    super.key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              visualDensity: const VisualDensity(horizontal: -2, vertical: -4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              labelPadding: EdgeInsets.zero,
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onFilterSelected(filter);
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: AppColors.primaryGreen,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
