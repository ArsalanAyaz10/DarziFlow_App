import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/orders/widgets/checkpoint_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OperationDetails extends StatelessWidget {
  final OperationModel op;
  final String? orderId;
  final String userRole;

  const OperationDetails({
    super.key,
    required this.op,
    required this.orderId,
    this.userRole = '',
  });

  bool get _isQC => userRole.toUpperCase() == 'QC_MEMBER';

  @override
  Widget build(BuildContext context) {
    final currentCP = op.checkpoints.isNotEmpty ? op.checkpoints.last : null;
    if (currentCP == null) return const SizedBox.shrink();

    // --- Role-based button configuration ---
    String buttonLabel;
    bool isBtnDisabled;
    Color btnColor;
    VoidCallback? onPressed;

    if (_isQC) {
      // QC MEMBER: "Review Checkpoint" — only enabled when status is SUBMITTED
      final isSubmitted = currentCP.status == 'SUBMITTED' || currentCP.isQcPending;
      final isAlreadyReviewed = currentCP.isApproved || currentCP.isRejected;

      if (isAlreadyReviewed) {
        buttonLabel = currentCP.isApproved ? "Already Approved" : "Already Rejected";
        isBtnDisabled = true;
        btnColor = currentCP.isApproved ? Colors.grey.shade400 : Colors.redAccent;
        onPressed = null;
      } else if (isSubmitted) {
        buttonLabel = "Review Checkpoint";
        isBtnDisabled = false;
        btnColor = Colors.orange;
        onPressed = () => Get.toNamed(
              '/submit-checkpoint',
              arguments: {
                'operation': op,
                'checkpoint': currentCP,
                'orderId': orderId,
              },
            );
      } else {
        buttonLabel = "Awaiting Submission";
        isBtnDisabled = true;
        btnColor = Colors.grey.shade400;
        onPressed = null;
      }
    } else {
      // DEPARTMENT HEAD / DEFAULT: existing submit logic
      if (currentCP.status == 'SUBMITTED' || currentCP.isQcPending) {
        buttonLabel = "Already Submitted";
        isBtnDisabled = true;
        btnColor = Colors.orange;
      } else if (currentCP.status == 'QC_APPROVED' || currentCP.isApproved) {
        buttonLabel = "Checkpoint Approved";
        isBtnDisabled = true;
        btnColor = Colors.grey.shade400;
      } else if (currentCP.status == 'QC_REJECTED' || currentCP.isRejected) {
        buttonLabel = "Re-submit Checkpoint";
        isBtnDisabled = false;
        btnColor = Colors.redAccent;
      } else {
        buttonLabel = "Submit Checkpoint";
        isBtnDisabled = false;
        btnColor = AppColors.primaryGreen;
      }

      onPressed = isBtnDisabled
          ? null
          : () => Get.toNamed(
                '/submit-checkpoint',
                arguments: {
                  'operation': op,
                  'checkpoint': currentCP,
                  'orderId': orderId,
                },
              );
    }

    return Container(
      margin: const EdgeInsets.only(left: 45, bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          ...op.checkpoints.map(
            (cp) => CheckpointItem(cp: cp),
          ),
          if (!op.isCompleted) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
