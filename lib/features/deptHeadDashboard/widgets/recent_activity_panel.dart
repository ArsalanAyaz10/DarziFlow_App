import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/widgets/activity_title.dart';
import 'package:flutter/material.dart';

class RecentActivityPanel extends StatelessWidget {
  final DeptHeadController controller;
  const RecentActivityPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activities = controller.processedActivities;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "RECENT ACTIVITY",
              style: TextStyle(
                fontSize: 15,
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
        ),
        const SizedBox(height: 10),
        activities.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "No Recent Activity",
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 3 ? 3 : activities.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: controller.navigateToFullActivityList,
                  child: ActivityTile(activity: activities[index]),
                ),
              ),
      ],
    );
  }
}
