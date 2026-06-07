import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/features/Client/controllers/client_department_review_controller.dart';

class ApproveConfirmationDialog extends GetView<ClientDepartmentReviewController> {
  final ColorScheme colorScheme;

  const ApproveConfirmationDialog({super.key, required this.colorScheme});

  static void show(BuildContext context, ColorScheme colorScheme) {
    Get.dialog(ApproveConfirmationDialog(colorScheme: colorScheme));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Colors.green,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Approve Department',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to approve this department? '
        'This will finalize the work for all completed operations and checkpoints.',
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // close the dialog
            controller.approveDepartment();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Approve',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
