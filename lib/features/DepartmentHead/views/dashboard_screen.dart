import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/deptHead_controller.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/dashboard_widgets.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart'
    as darizi_notifications;
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeptHeadDashboardScreen extends GetView<DeptHeadController> {
  const DeptHeadDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Obx(
          () => CustomAppBar(
            isDashboard: true,
            isTransparent: true,
            userAvatarUrl: controller.userAvatar.value,
            title: controller.userName.value,
            subtitle: controller.userRole.value,
            actions: [
              IconButton(
                onPressed: () {
                  Get.toNamed('/notification-inbox');
                },
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
                      color: colors.onSurface,
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
            controller.processedActivities.isEmpty) {
          return const DashboardShimmer();
        }
        return Column(
          children: [
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
                      DepartmentHeader(
                        departmentName: controller.departmentName.value,
                        status: controller.deptStatus.value,
                      ),
                      const SizedBox(height: 20),
                      PerformanceSummaryPanel(controller: controller),
                      const SizedBox(height: 20),
                      RecentActivityPanel(
                        activities: controller.processedActivities,
                        onViewAll: controller.navigateToFullActivityList,
                      ),
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
}
