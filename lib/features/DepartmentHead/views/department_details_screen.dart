import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/department_details_controller.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DepartmentDetailsScreen extends GetView<DepartmentDetailsController> {
  const DepartmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: "Department Details",
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      controller.name.value.isEmpty
                          ? "Loading..."
                          : controller.name.value,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          controller.status.value,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (controller.description.value.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  controller.description.value,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 10,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Department Overview Stats
              Row(
                children: [
                  StatTile(
                    label: "Total Orders",
                    value: controller.totalOrders.value.toString(),
                    subText: "Orders Assigned",
                    color: AppColors.primaryGreen,
                    icon: Icons.shopping_bag_outlined,
                    showTrend: true,
                    onTap: () => Get.toNamed(Routes.orders),
                  ),
                  const SizedBox(width: 15),
                  StatTile(
                    label: "Active Orders",
                    value: controller.activeOrders.value.toString(),
                    subText: "In progress now",
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                    showTrend: false,
                    onTap: () => Get.toNamed(Routes.orders),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Operations
              Text(
                "Department Operations",
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              if (controller.operations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No Operations Configured",
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Column(
                  children: controller.operations.map((op) {
                    final name = op['name'] ?? 'Unknown';
                    final description = op['description'] ?? '';
                    final checkpoints = op['checkpoints'] as List? ?? [];
                    final checkpointCount = checkpoints.length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "$checkpointCount Checkpoints",
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              "Description: ${description.toString()}",
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 5),

              // DEPT HEAD INFO
              Text(
                "Department Head Details",
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryGreen.withValues(
                        alpha: 0.2,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.managerName.value.isEmpty
                                ? "Name Not Mentioned"
                                : controller.managerName.value,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            controller.managerEmail.value.isEmpty
                                ? "Email Not Mentioned"
                                : controller.managerEmail.value,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO Message Screen
                      },
                      icon: const Icon(
                        Icons.message,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO Optional WEB RTC Feature
                      },
                      icon: const Icon(
                        Icons.call,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
