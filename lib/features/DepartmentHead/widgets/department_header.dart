import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/deptHead_controller.dart';

class DepartmentHeader extends StatelessWidget {
  final DeptHeadController controller;

  const DepartmentHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          controller.departmentName.value.isEmpty ? "Department" : controller.departmentName.value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        StatusBadge(
          status: controller.deptStatus.value.isEmpty ? "Unknown" : controller.deptStatus.value,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(20),
          fontSize: 12,
        ),
      ],
    ));
  }
}
