import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
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
        ),
        const SizedBox(height: 12),
        activities.isEmpty
            ? Container(
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

class ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    String type = activity['type'] ?? '';
    if (type.isEmpty) {
      final action = activity['action'] ?? '';
      final message = (activity['message'] ?? '').toString().toLowerCase();

      if (message.contains('material') || message.contains('alert')) {
        type = 'alert';
      } else if (action == 'ASSIGN' || message.contains('assigned')) {
        type = 'assignment';
      } else if (action == 'MOVE' || message.contains('moved')) {
        type = 'movement';
      } else if (action == 'SUBMIT') {
        type = 'submission';
      } else if (action == 'APPROVE') {
        type = 'approval';
      } else if (action == 'REJECT') {
        type = 'rejection';
      } else {
        type = 'default';
      }
    }

    // Determine icon
    IconData iconData;
    switch (type) {
      case 'movement':
        iconData = Icons.swap_horiz;
        break;
      case 'alert':
        iconData = Icons.warning_amber_rounded;
        break;
      case 'assignment':
        iconData = Icons.person_add_alt;
        break;
      case 'submission':
        iconData = Icons.upload_file;
        break;
      case 'approval':
        iconData = Icons.check_circle;
        break;
      case 'rejection':
        iconData = Icons.cancel;
        break;
      default:
        iconData = Icons.circle;
        break;
    }

    Color color;
    switch (type) {
      case 'movement':
        color = Colors.blue;
        break;
      case 'alert':
        color = Colors.orange;
        break;
      case 'assignment':
        color = Colors.purple;
        break;
      case 'submission':
        color = AppColors.primaryGreen;
        break;
      case 'approval':
        color = Colors.green;
        break;
      case 'rejection':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
        break;
    }

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['subtitle'] ?? '',
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
          Text(
            activity['timeAgo'] ?? '',
            softWrap: true,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
