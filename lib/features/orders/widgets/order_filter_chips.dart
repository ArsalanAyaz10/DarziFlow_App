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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
