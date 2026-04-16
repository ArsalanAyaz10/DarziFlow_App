import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
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
        _EfficiencyScoreCard(
          controller: controller,
          colors: colors,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// The gradient card showing department performance / efficiency score.
class _EfficiencyScoreCard extends StatelessWidget {
  final DeptHeadController controller;
  final ColorScheme colors;
  final bool isDark;

  const _EfficiencyScoreCard({
    required this.controller,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primaryContainer,
                  colors.primaryContainer.withValues(alpha: 0.8),
                ]
              : [AppColors.primaryGreen, const Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.green).withValues(
              alpha: 0.3,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabels(),
              _buildCircularProgress(),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn(
                "Operations",
                "${controller.completedOps.value}/${controller.totalOperationsHandled.value}",
                Icons.checklist,
              ),
              _buildMetricColumn(
                "Checkpoints",
                "${controller.completedCheckpoints.value}/${controller.totalCheckpoints.value}",
                Icons.task_alt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Department Performance",
          style: TextStyle(
            color: isDark
                ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                : Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Efficiency Score",
          style: TextStyle(
            color: isDark ? colors.onPrimaryContainer : AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? colors.onSurface.withValues(alpha: 0.1)
                : AppColors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Quality: ${controller.qualityScore.value}%",
            style: TextStyle(
              color: isDark ? colors.onPrimaryContainer : AppColors.white,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            value: controller.efficiencyScore.value / 100,
            strokeWidth: 6,
            backgroundColor:
                (isDark ? colors.onPrimaryContainer : AppColors.white)
                    .withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? colors.onPrimaryContainer : Colors.white,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${controller.efficiencyScore.value}",
              style: TextStyle(
                color: isDark ? colors.onPrimaryContainer : AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "%",
              style: TextStyle(
                color: isDark
                    ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                    : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDark
              ? colors.onPrimaryContainer.withValues(alpha: 0.7)
              : Colors.white70,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? colors.onPrimaryContainer : AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                : Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
