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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final order = controller.order.value;
          return Column(
            children: [
              Text(
                order?.displayOrderId ?? "Loading...",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                order?.orderName ?? "",
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Obx(() {
        if (controller.isLoading.value || controller.order.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildRejectionAlert(context), // New Alert for Rework
              _buildProgressCard(context),
              const SizedBox(height: 25),
              _buildTimeline(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRejectionAlert(BuildContext context) {
    final rejection = controller.latestRejection;
    if (rejection == null ||
        controller.currentPhase.value != "REWORK REQUIRED") {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                "REWORK REQUIRED",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rejection.comment ?? "No feedback provided by QC.",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.settings_suggest_outlined,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                "Current Phase: ${controller.currentPhase.value}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: hasRejection || (index == 0 && !op.isCompleted),
            tilePadding: EdgeInsets.zero,
            leading: _buildCircleIcon(op, index, operations.length),
            title: Text(
              op.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: _buildStatusBadge(op.status, hasRejection),
            children: [_buildOperationDetails(context, op)],
          ),
        );
      }),
    );
  }

  Widget _buildCircleIcon(OperationModel op, int index, int total) {
    bool isDone = op.isCompleted;
    return Column(
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
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          child: Icon(
            isDone ? Icons.check : _getOpIcon(op.name),
            size: 16,
            color: isDone ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationDetails(BuildContext context, OperationModel op) {
    return Container(
      margin: const EdgeInsets.only(left: 45, bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ...op.checkpoints.map((cp) => _buildCheckpointItem(context, cp)),
          if (!op.isCompleted) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.toNamed('/submit-checkpoint', arguments: op),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "Submit Work",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckpointItem(BuildContext context, CheckpointModel cp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            cp.isApproved
                ? Icons.check_circle
                : (cp.isRejected ? Icons.cancel : Icons.radio_button_unchecked),
            color: cp.isApproved
                ? AppColors.primaryGreen
                : (cp.isRejected ? Colors.red : Colors.grey),
            size: 18,
          ),
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
                if (cp.isRejected)
                  const Text(
                    "View feedback for details",
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (cp.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history, size: 18),
              onPressed: () => _showHistory(context, cp),
            ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context, CheckpointModel cp) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Action History: ${cp.name}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...cp.history.reversed.map(
              (h) => ListTile(
                title: Text(h.action),
                subtitle: Text(h.comment ?? "No comment"),
                trailing: Text("${h.actedAt.hour}:${h.actedAt.minute}"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isRejected) {
    if (isRejected) return _badge("REWORK REQUIRED", Colors.red);
    if (status == 'COMPLETED')
      return _badge("COMPLETED", AppColors.primaryGreen);
    return _badge(status, Colors.grey);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getOpIcon(String name) {
    if (name.contains("Design")) return Icons.architecture;
    if (name.contains("Cloth")) return Icons.content_cut;
    return Icons.inventory_2_outlined;
  }
}
