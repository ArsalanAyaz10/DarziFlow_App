import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/QualityControl/controllers/qc_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class QcHistoryScreen extends GetView<QcHistoryController> {
  const QcHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Index 2 = History
      appBar: const CustomAppBar(
        title: 'QC Action History',
        isTransparent: false,
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No history logs found.",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHistory,
          color: AppColors.atelierSilkGreen,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.historyLogs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final log = controller.historyLogs[index];
              return _historyCard(log, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _historyCard(dynamic log, bool isDark) {
  
    Color actionColor = Colors.grey;
    IconData actionIcon = Icons.info_outline;
    String actionText = log.action;

    if (log.action == 'APPROVE' || log.action == 'FINAL_APPROVE') {
      actionColor = AppColors.atelierSilkGreen;
      actionIcon = Icons.check_circle;
      actionText = "Approved";
    } else if (log.action == 'REJECT') {
      actionColor = AppColors.error;
      actionIcon = Icons.cancel;
      actionText = "Rejected";
    } else if (log.action == 'SUBMIT') {
      actionColor = Colors.blue;
      actionIcon = Icons.upload_file;
      actionText = "Submitted";
    }

    return InkWell(
      onTap: () => Get.toNamed(Routes.qcHistoryDetail, arguments: log),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.atelierSurfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(actionIcon, color: actionColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: actionColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  log.formattedDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
  
            // Context details
            Text(
              log.orderName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              log.departmentName,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tap for more details",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: actionColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 10, color: actionColor.withValues(alpha: 0.8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
