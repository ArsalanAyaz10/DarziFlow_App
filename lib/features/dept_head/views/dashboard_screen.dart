import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/error_view.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/features/dept_head/controllers/deptHeadController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeptHeadDashboardScreen extends GetView<DeptHeadController> {
  const DeptHeadDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
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
            _buildAppBar(),
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
                      _buildDeptHeader(),
                      const SizedBox(height: 20),
                      _buildStatCards(),
                      const SizedBox(height: 20),
                      _buildEfficiencyCard(),
                      const SizedBox(height: 30),
                      _buildRecentActivityHeader(),
                      const SizedBox(height: 15),
                      _buildActivityList(),
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

  Widget _buildAppBar() {
    return Obx(
      () => AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundColor: AppColors.grey,
            child: Icon(Icons.person, color: AppColors.white),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.userRole.value,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              controller.userName.value,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptHeader() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.departmentName.value.isEmpty
                ? "Department"
                : controller.departmentName.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
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

  Widget _buildStatCards() {
    return Obx(() {
      return Row(
        children: [
          _buildStatTile(
            "Total Orders",
            controller.totalOrders.value.toString(),
            controller.ordersTrend.value,
            AppColors.primaryGreen,
          ),
          const SizedBox(width: 15),
          _buildStatTile(
            "In Progress",
            controller.inProgressOrders.value.toString(),
            "Queue: ${controller.pendingCheckpoints.value}",
            AppColors.blueGrey,
            trendIcon: Icons.hourglass_empty,
          ),
        ],
      );
    });
  }

  Widget _buildStatTile(
    String label,
    String value,
    String subText,
    Color color, {
    IconData? trendIcon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, const Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
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
                    const Text(
                      "Department Performance",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Efficiency Score",
                      style: TextStyle(
                        color: AppColors.white,
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
                        color: AppColors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Quality: ${controller.qualityScore.value}%",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildScoreCircle(),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  "Checkpoints",
                  "${controller.completedCheckpoints.value}/${controller.totalCheckpoints.value}",
                  Icons.task_alt,
                ),
                _buildMetricItem(
                  "Quality",
                  "${controller.qualityScore.value}%",
                  Icons.star,
                ),
                _buildMetricItem(
                  "Overdue",
                  "${controller.overdueTasks.value}",
                  Icons.warning_amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle() {
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
              backgroundColor: AppColors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${controller.efficiencyScore.value}",
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "%",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildActivityList() {
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
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("No recent activity"),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length > 3 ? 3 : activities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];

          final action = activity['action'] ?? '';
          final checkpoint = activity['checkpointName'] ?? '';
          final orderName = activity['orderName'] ?? '';

          final actedAt = DateTime.tryParse(activity['actedAt'] ?? '');
          final timeAgo = controller.formatTimeAgo(actedAt);
          final message = controller.formatReadableMessage(action, checkpoint);

          return _buildActivityCard(
            orderId: activity['orderId'] ?? '',
            title: orderName,
            message: message,
            action: action,
            timeAgo: timeAgo,
          );
        },
      );
    });
  }

  Widget _buildActivityCard({
    required String orderId,
    required String title,
    required String message,
    required String action,
    required String timeAgo,
  }) {
    final color = _getActionColor(action);
    final icon = _getActionIcon(action);

    return GestureDetector(
      onTap: () => Get.toNamed("/order-details", arguments: orderId),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(message, style: TextStyle(color: color)),
          trailing: Text(
            timeAgo,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'APPROVE':
        return AppColors.primaryGreen;
      case 'REJECT':
        return AppColors.error;
      case 'SUBMIT':
        return AppColors.primaryBlue;
      default:
        return AppColors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'APPROVE':
        return Icons.check_circle_outline;
      case 'REJECT':
        return Icons.cancel_outlined;
      case 'SUBMIT':
        return Icons.send_outlined;
      default:
        return Icons.fiber_manual_record;
    }
  }
}
