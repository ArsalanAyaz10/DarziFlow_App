import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/error_view.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeptHeadDashboardScreen extends GetView<DeptHeadController> {
  const DeptHeadDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.processedActivities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.refreshDashboard,
          );
        }

        return Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeptHeader(context),
                      const SizedBox(height: 20),
                      _buildStatCards(context),
                      const SizedBox(height: 20),
                      _buildEfficiencyCard(context),
                      const SizedBox(height: 30),
                      _buildRecentActivityHeader(context),
                      _buildActivityList(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 0),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Obx(
      () => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: InkWell(
            onTap: () {
              Get.toNamed("/profile");
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colors.onSurface.withValues(alpha: 0.1),
              backgroundImage: controller.userAvatar.value.isNotEmpty
                  ? NetworkImage(controller.userAvatar.value)
                  : null,
              child: controller.userAvatar.value.isEmpty
                  ? Icon(Icons.person, size: 24, color: AppColors.primaryGreen)
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.userName.value,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 13,
                letterSpacing: .5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              controller.userRole.value,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: colors.onSurface),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.departmentName.value.isEmpty
                ? "Department"
                : controller.departmentName.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          StatusBadge(
            status: controller.deptStatus.value.isEmpty
                ? "Unknown Status"
                : controller.deptStatus.value,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _buildStatTile(
            context,
            "Total Orders",
            controller.totalOrders.value.toString(),
            "Orders Assigned",
            AppColors.primaryGreen,
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(width: 15),
          _buildStatTile(
            context,
            "Active Orders",
            controller.inProgressOrders.value.toString(),
            "In progress now",
            Colors.orange,
            icon: Icons.pending_actions,
            showTrend: false,
          ),
        ],
      );
    });
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    String subText,
    Color color, {
    IconData? icon,
    IconData? trendIcon,
    bool showTrend = true,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            if (showTrend)
              Row(
                children: [
                  Icon(
                    trendIcon ??
                        (subText.startsWith('+')
                            ? Icons.trending_up
                            : Icons.trending_down),
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    subText,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Text(
                subText,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Use a theme-adaptive background for the card
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
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
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
                Column(
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
                        color: isDark
                            ? colors.onPrimaryContainer
                            : AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.onSurface.withValues(alpha: 0.1)
                            : AppColors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Quality: ${controller.qualityScore.value}%",
                        style: TextStyle(
                          color: isDark
                              ? colors.onPrimaryContainer
                              : AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildScoreCircle(context),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  "Operations",
                  "${controller.completedOps.value}/${controller.totalOperationsHandled.value}",
                  Icons.checklist,
                ),
                _buildMetricItem(
                  context,
                  "Checkpoints",
                  "${controller.completedCheckpoints.value}/${controller.totalCheckpoints.value}",
                  Icons.task_alt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(
              value: controller.efficiencyScore.value / 100,
              strokeWidth: 6,
              backgroundColor: isDark
                  ? colors.onPrimaryContainer.withValues(alpha: 0.2)
                  : AppColors.white.withValues(alpha: 0.2),
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
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

  Widget _buildRecentActivityHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        GestureDetector(
          onTap: controller.navigateToFullActivityList,
          child: const Text(
            "VIEW ALL",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Obx(() {
      final activities = controller.processedActivities;

      if (controller.isLoading.value && activities.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (activities.isEmpty) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              "No recent activity",
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length > 3 ? 3 : activities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityCard(context, activity);
        },
      );
    });
  }

  Widget _buildActivityCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final colors = Theme.of(context).colorScheme;
    final activityType = _getActivityType(activity);
    final iconData = _getActivityIcon(activityType);
    final color = _getActivityTypeColor(activityType);
    final timeAgo = activity['timeAgo'] ?? '';
    final title = activity['title'] ?? '';
    final subtitle = activity['subtitle'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with colored background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Time
          Text(
            timeAgo,
            softWrap: true,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'movement':
        return Icons.swap_horiz;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'assignment':
        return Icons.person_add_alt;
      case 'submission':
        return Icons.upload_file;
      case 'approval':
        return Icons.check_circle;
      case 'rejection':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _getActivityType(Map<String, dynamic> activity) {
    // Determine activity type based on available data
    if (activity['type'] != null) return activity['type'];

    final action = activity['action'] ?? '';
    final message = activity['message'] ?? '';

    if (message.toLowerCase().contains('material') ||
        message.toLowerCase().contains('alert')) {
      return 'alert';
    }
    if (action == 'ASSIGN' || message.toLowerCase().contains('assigned')) {
      return 'assignment';
    }
    if (action == 'MOVE' || message.toLowerCase().contains('moved')) {
      return 'movement';
    }
    if (action == 'SUBMIT') {
      return 'submission';
    }
    if (action == 'APPROVE') {
      return 'approval';
    }
    if (action == 'REJECT') {
      return 'rejection';
    }

    return 'default';
  }

  Color _getActivityTypeColor(String type) {
    switch (type) {
      case 'movement':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'assignment':
        return Colors.purple;
      case 'submission':
        return AppColors.primaryGreen;
      case 'approval':
        return Colors.green;
      case 'rejection':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
