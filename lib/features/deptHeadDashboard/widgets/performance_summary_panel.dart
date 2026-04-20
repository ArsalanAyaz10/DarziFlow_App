import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/widgets/Efficiency_Score_Card.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerformanceSummaryPanel extends StatelessWidget {
  final DeptHeadController controller;
  const PerformanceSummaryPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            StatTile(
              label: "Total Orders",
              value: controller.totalOrders.value.toString(),
              subText: "Orders Assigned",
              color: AppColors.primaryGreen,
              icon: Icons.shopping_bag_outlined,
              showTrend: true,
              onTap: () => Get.toNamed(Routes.allOrders),
            ),
            const SizedBox(width: 15),
            StatTile(
              label: "Active Orders",
              value: controller.inProgressOrders.value.toString(),
              subText: "In progress now",
              color: Colors.orange,
              icon: Icons.pending_actions,
              showTrend: false,
              onTap: () => Get.toNamed(Routes.orders),
            ),
          ],
        ),
        const SizedBox(height: 20),
        EfficiencyScoreCard(
          controller: controller,
          colors: colors,
          isDark: isDark,
        ),
      ],
    );
  }
}
