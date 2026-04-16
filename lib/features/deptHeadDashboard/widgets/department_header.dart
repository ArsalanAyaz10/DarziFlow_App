import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';

class DepartmentHeader extends StatelessWidget {
  final String departmentName;
  final String status;

  const DepartmentHeader({
    super.key,
    required this.departmentName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          departmentName.isEmpty ? "Department" : departmentName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 4,
                backgroundColor: AppColors.primaryGreen,
              ),
              const SizedBox(width: 5),
              Text(
                status.isEmpty ? "Unknown" : status,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
