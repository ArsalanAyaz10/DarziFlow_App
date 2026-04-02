import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';

class OrderDetailsScreen extends GetView<OrderDetailController> {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Obx(() {
          final order = controller.order.value;
          return CustomAppBar(
            title: order?.orderName ?? "",
            centerTitle: true,
            isTransparent: true,
            showBackButton: true,
            isDashboard: false,
          );
        }),
      ),

      bottomNavigationBar: const BottomNavBar(),
      body: Obx(() {
        if (controller.isLoading.value || controller.order.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressCard(context),
              const SizedBox(height: 25),
              _buildTimeline(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Production Progress",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "${controller.progress.value}%",
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: controller.progress.value / 100,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final operations = controller.order.value?.operations ?? [];
    return Column(
      children: List.generate(operations.length, (index) {
        final op = operations[index];
        final bool hasRejection = op.checkpoints.any((cp) => cp.isRejected);

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            collapsedIconColor: AppColors.primaryGreen,
            splashColor: Colors.transparent,
            dense: true,
            initiallyExpanded: hasRejection || (index == 0 && !op.isCompleted),
            tilePadding: EdgeInsets.zero,
            leading: _buildCircleIcon(op, index, operations.length),
            title: Text(
              op.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            children: [_buildOperationDetails(context, op)],
          ),
        );
      }),
    );
  }

  Widget _buildCircleIcon(OperationModel op, int index, int total) {
    bool isDone = op.isCompleted;
    return Column(
      crossAxisAlignment: .start,
      mainAxisAlignment: .spaceAround,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primaryGreen : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone
                  ? AppColors.primaryGreen
                  : Colors.grey.withValues(alpha: .5),
            ),
          ),
          child: Icon(
            isDone ? Icons.check : Icons.radio_button_unchecked_sharp,
            size: 16,
            color: isDone ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationDetails(BuildContext context, OperationModel op) {
    final currentCP = op.checkpoints.isNotEmpty ? op.checkpoints.last : null;
    if (currentCP == null) return const SizedBox.shrink();

    final currentOrderId = controller.order.value?.orderId;

    // --- Logic for Button State ---
    String buttonLabel = "Submit Checkpoint";
    bool isBtnDisabled = false;
    Color btnColor = AppColors.primaryGreen;

    // Logic based on checkpoint status
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
            (cp) => _buildCheckpointItem(context, cp, isBtnDisabled),
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
                          'orderId': currentOrderId,
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

  Widget _buildCheckpointItem(
    BuildContext context,
    CheckpointModel cp,
    bool isBtnDisabled,
  ) {
    IconData stateIcon;
    Color stateColor;

    if (cp.isApproved || cp.status == 'QC_APPROVED') {
      stateIcon = Icons.check_circle;
      stateColor = AppColors.primaryGreen;
    } else if (cp.isRejected || cp.status == 'QC_REJECTED') {
      stateIcon = Icons.cancel;
      stateColor = Colors.red;
    } else if (cp.isQcPending || cp.status == 'SUBMITTED') {
      stateIcon = Icons.schedule;
      stateColor = Colors.orange;
    } else if (cp.toBeSubmitted) {
      stateIcon = Icons.upload_file;
      stateColor = Colors.blue;
    } else {
      stateIcon = Icons.radio_button_unchecked;
      stateColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _showHistory(context, cp),
        child: Row(
          children: [
            Icon(stateIcon, color: stateColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cp.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (cp.isRejected || cp.status == 'QC_REJECTED')
                    const Text(
                      "Rejected:View feedback",
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    )
                  else if (cp.isApproved || cp.status == 'QC_APPROVED')
                    const Text(
                      "Approved: Check Remarks",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                      ),
                    )
                  else if (cp.isQcPending || cp.status == 'SUBMITTED')
                    const Text(
                      "Awaiting Approval",
                      style: TextStyle(color: Colors.orange, fontSize: 11),
                    )
                  else
                    const Text(
                      "View history",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (cp.history.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.history,
                  size: 22,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => _showHistory(context, cp),
              ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, CheckpointModel cp) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "History: ${cp.name}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: cp.history.reversed
                        .map(
                          (h) => ListTile(
                            title: Text(
                              h.action,
                              style: TextStyle(
                                color:
                                    h.action.toLowerCase().contains("APPROVE")
                                    ? AppColors.primaryGreen
                                    : (h.action.toLowerCase().contains("REJECT")
                                          ? Colors.red
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(h.comment ?? "No comment"),
                            trailing: Text(
                              "${h.actedAt.hour.toString().padLeft(2, '0')}:${h.actedAt.minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }
}
