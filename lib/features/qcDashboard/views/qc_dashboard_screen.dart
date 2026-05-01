import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/features/qcDashboard/controllers/qc_dashboard_controller.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/qc_stat_card.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/review_queue_item.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart'
    as darizi_notifications;
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/widgets/dashboard_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QCDashboardScreen extends GetView<QcDashboardController> {
  const QCDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.atelierBackgroundDark
        : AppColors.atelierBackgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Obx(
          () => CustomAppBar(
            isDashboard: true,
            isTransparent: true,
            userAvatarUrl: controller.userAvatar.value,
            title: controller.userName.value,
            subtitle: "QC Team Member",
            actions: [
              IconButton(
                onPressed: () => Get.toNamed('/notification-inbox'),
                icon: Obx(() {
                  final unreadCount =
                      Get.find<darizi_notifications.NotificationController>()
                          .unreadCount
                          .value;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                    ),
                    backgroundColor: AppColors.error,
                    child: Icon(
                      Icons.notifications_none,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.pendingSubmissions.isEmpty) {
          return const DashboardShimmer();
        }
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.atelierSilkGreen,
                onRefresh: controller.refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quality Control",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Review submitted work and maintain standards.",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.atelierTonalGrey
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Divider(color: colors.outlineVariant, height: 10),

                            const SizedBox(height: 10),
                            Obx(
                              () => Row(
                                children: [
                                  QCStatCard(
                                    label: "Pending",
                                    value:
                                        "${controller.pendingReviewsCount.value}",
                                    subText: "REVIEWS",
                                    icon: Icons.pending_actions_outlined,
                                    accentColor: Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  QCStatCard(
                                    label: "Approved",
                                    value:
                                        "${controller.approvedTodayCount.value}",
                                    subText: "TODAY",
                                    icon: Icons.check_circle_outline,
                                    accentColor: AppColors.atelierSilkGreen,
                                  ),
                                  const SizedBox(width: 10),
                                  QCStatCard(
                                    label: "Rejected",
                                    value:
                                        "${controller.rejectedTodayCount.value}",
                                    subText: "TODAY",
                                    icon: Icons.cancel_outlined,
                                    accentColor: AppColors.error,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Divider(color: colors.outlineVariant, height: 10),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Assigned Orders",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      assignedOrders(context),

                      const SizedBox(height: 10),

                      Divider(color: colors.outlineVariant, height: 10),

                      const SizedBox(height: 10),

                      // Reviews List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reviews Needed",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(Routes.allReviews),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "View All",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.atelierSilkGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: AppColors.atelierSilkGreen,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: reviewList(controller),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget assignedOrders(BuildContext context) {
    return Obx(() {
      if (controller.activeOrders.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            "No active orders currently assigned to you.",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.activeOrders.length,
          itemBuilder: (context, index) {
            final order = controller.activeOrders[index];
            final displayId = order.uniqueId.length > 6
                ? order.uniqueId.substring(0, 6)
                : order.uniqueId;

            final statusText = order.overallStatus.replaceAll('_', ' ');

            return InkWell(
              onTap: () => Get.toNamed(Routes.orderDetails, arguments: order),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 240,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order.orderName.isNotEmpty
                          ? order.orderName
                          : 'Unnamed Order',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Order #$displayId",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget reviewList(QcDashboardController controller) {
    return Obx(() {
      if (controller.pendingSubmissions.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  "No pending reviews",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.pendingSubmissions.length,
        itemBuilder: (context, index) {
          final item = controller.pendingSubmissions[index];

          final orderName = item['orderName'] ?? 'Unknown Order';
          final checkpointName = item['checkpointName'] ?? 'General Review';
          final deptName = item['departmentName'] ?? 'Production';

          List<String> evidence = [];
          final files = item['submissionFiles'] as List? ?? [];
          final text = item['submissionText']?.toString() ?? '';
          if (files.isNotEmpty) evidence.add('photo');
          if (text.isNotEmpty) evidence.add('text');
          if (evidence.isEmpty) evidence.add('none');

          return ReviewQueueItem(
            orderName: "Order: $orderName",
            department: deptName,
            checkpointName: checkpointName,
            time: controller.formatTimeAgo(item['submittedAt']),
            evidenceTypes: evidence,
            onTap: () =>
                Get.toNamed(Routes.workflow, arguments: item['orderId']),
          );
        },
      );
    });
  }
}
