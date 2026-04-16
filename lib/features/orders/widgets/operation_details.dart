import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/orders/widgets/checkpoint_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OperationDetails extends StatelessWidget {
  final OperationModel op;
  final String? orderId;

  const OperationDetails({super.key, required this.op, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final currentCP = op.checkpoints.isNotEmpty ? op.checkpoints.last : null;
    if (currentCP == null) return const SizedBox.shrink();

    String buttonLabel = "Submit Checkpoint";
    bool isBtnDisabled = false;
    Color btnColor = AppColors.primaryGreen;

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
    } else if (currentCP.status == 'PENDING') {
      buttonLabel = "Submit Checkpoint";
      isBtnDisabled = false;
      btnColor = AppColors.primaryGreen;
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
                onPressed: isBtnDisabled
                    ? null
                    : () => Get.toNamed(
                        '/submit-checkpoint',
                        arguments: {
                          'operation': op,
                          'checkpoint': currentCP,
                          'orderId': orderId,
                        },
                      ),
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
