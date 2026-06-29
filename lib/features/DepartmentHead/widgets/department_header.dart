import 'package:dariziflow_app/core/widgets/status_badge.dart';
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
        StatusBadge(
          status: status.isEmpty ? "Unknown" : status,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(20),
          fontSize: 12,
        ),
      ],
    );
  }
}
