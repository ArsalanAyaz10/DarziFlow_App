import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/features/Client/controllers/client_department_review_controller.dart';

class RejectDepartmentSheet extends GetView<ClientDepartmentReviewController> {
  final Color cardColor;
  final ColorScheme colorScheme;

  const RejectDepartmentSheet({
    super.key,
    required this.cardColor,
    required this.colorScheme,
  });

  static void show(
    BuildContext context,
    Color cardColor,
    ColorScheme colorScheme,
  ) {
    final controller = Get.find<ClientDepartmentReviewController>();
    controller.rejectionReasonController.clear();
    controller.selectedOperationForRejection.value = null;
    controller.selectedCheckpointForRejection.value = null;
    Get.bottomSheet(
      RejectDepartmentSheet(cardColor: cardColor, colorScheme: colorScheme),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;
    // Cover exactly half of the screen size when keyboard is closed; expand to 85% when open
    final double sheetHeight = isKeyboardOpen
        ? screenHeight * 0.85
        : screenHeight * 0.50;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Handle indicator
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 0,
                bottom: keyboardHeight + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reject Department Work',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Please specify the operation and checkpoint with the defect or issue, and provide rejection reasons.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown 1: Operation selection
                  Obx(
                    () => DropdownButtonFormField<OperationModel>(
                      // ignore: deprecated_member_use
                      value: controller.selectedOperationForRejection.value,
                      dropdownColor: cardColor,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        labelText: 'SELECT OPERATION',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.build_circle_outlined,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      items: controller.operations.map((op) {
                        return DropdownMenuItem<OperationModel>(
                          value: op,
                          child: Text(
                            op.name,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedOperationForRejection.value = val;
                        controller.selectedCheckpointForRejection.value =
                            null; // reset checkpoint
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  Obx(() {
                    final selectedOp =
                        controller.selectedOperationForRejection.value;
                    final checkpoints = selectedOp?.checkpoints ?? [];
                    return DropdownButtonFormField<CheckpointModel>(
                      // ignore: deprecated_member_use
                      value: controller.selectedCheckpointForRejection.value,
                      dropdownColor: cardColor,
                      disabledHint: Text(
                        selectedOp == null
                            ? 'First select an operation'
                            : 'No checkpoints available',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        labelText: 'SELECT CHECKPOINT',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      items: checkpoints.map((cp) {
                        return DropdownMenuItem<CheckpointModel>(
                          value: cp,
                          child: Text(
                            cp.name,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: selectedOp == null
                          ? null
                          : (val) {
                              controller.selectedCheckpointForRejection.value =
                                  val;
                            },
                    );
                  }),
                  const SizedBox(height: 10),

                  // Feedback Section
                  Text(
                    "ISSUE DESCRIPTION",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: controller.rejectionReasonController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Describe the issue or defect in detail...",
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.submitRejectDepartment(),
                      icon: const Icon(Icons.report_gmailerrorred_rounded),
                      label: const Text(
                        'Submit Rejection',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
