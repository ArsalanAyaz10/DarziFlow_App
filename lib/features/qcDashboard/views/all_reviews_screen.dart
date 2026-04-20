import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/qcDashboard/controllers/qc_dashboard_controller.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/review_queue_item.dart';
import 'package:dariziflow_app/features/qcDashboard/widgets/review_bottom_sheet.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';

class AllReviewsScreen extends GetView<QcDashboardController> {
  const AllReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.atelierBackgroundDark : AppColors.atelierBackgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: "All Pending Reviews",
        centerTitle: true,
        isTransparent: false,
        showBackButton: true,
        onBackPress: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pendingSubmissions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.atelierSilkGreen,
            ),
          );
        }

        if (controller.pendingSubmissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.reviews_outlined,
                  size: 64,
                  color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No Pending Reviews",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up with your quality checks!",
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.atelierSilkGreen,
          onRefresh: controller.refreshDashboard,
          child: Column(
            children: [
              // Header Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.atelierSurfaceDark : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: (isDark ? Colors.white : AppColors.black).withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "${controller.pendingSubmissions.length} Submissions",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Latest first",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
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
                      onTap: () {
                        _showReviewOptions(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  void _showReviewOptions(BuildContext context, Map<String, dynamic> item) {
    Get.bottomSheet(
      ReviewBottomSheet(submission: item),
      isScrollControlled: true,
    );
  }
}
