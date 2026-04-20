import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/features/qcDashboard/controllers/qc_dashboard_controller.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/qc_stat_card.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/review_queue_item.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart' as darizi_notifications;
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/widgets/dashboard_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class QCDashboardScreen extends GetView<QcDashboardController> {
  const QCDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.atelierBackgroundDark
        : AppColors.atelierBackgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quality Control",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Review submitted work and maintain standards.",
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.atelierTonalGrey
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => Row(
                          children: [
                            QCStatCard(
                              label: "Pending",
                              value: "${controller.pendingReviewsCount.value}",
                              subText: "REVIEWS",
                              icon: Icons.pending_actions_outlined,
                              accentColor: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 8),
                            QCStatCard(
                              label: "Approved",
                              value: "${controller.approvedTodayCount.value}",
                              subText: "TODAY",
                              icon: Icons.check_circle_outline,
                              accentColor: AppColors.atelierSilkGreen,
                            ),
                            const SizedBox(width: 8),
                            QCStatCard(
                              label: "Rejected",
                              value: "${controller.rejectedTodayCount.value}",
                              subText: "TODAY",
                              icon: Icons.cancel_outlined,
                              accentColor: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 3. Queue Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reviews Needed",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Prioritized by submission time",
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.atelierTonalGrey
                                      : Colors.grey.shade600,
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
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.atelierSilkGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
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
                      const SizedBox(height: 10),
                      _buildReviewQueue(controller),
                      const SizedBox(height: 100),
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

  Widget _buildReviewQueue(QcDashboardController controller) {
    return Obx(() {
      if (controller.pendingSubmissions.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No pending reviews",
                  style: GoogleFonts.manrope(color: Colors.grey.shade500),
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
          return ReviewQueueItem(
            orderId: item['orderName'] ?? 'N/A',
            workerName: "Submitted Task",
            department: item['departmentName'] ?? 'Production',
            checkpointName: item['checkpointName'] ?? 'General Review',
            time: item['submittedAt'] ?? '',
            evidenceTypes: const ['photo'],
            onTap: () => Get.toNamed(Routes.allReviews),
          );
        },
      );
    });
  }
}
