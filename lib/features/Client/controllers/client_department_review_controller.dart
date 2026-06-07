import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/features/Client/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';

class ClientDepartmentReviewController extends GetxController {
  final ClientService _clientService = Get.find<ClientService>();

  final String orderId;
  final String workflowStatus;
  final List<OperationModel> operations;

  var isSubmitting = false.obs;

  final selectedOperationForRejection = Rxn<OperationModel>();
  final selectedCheckpointForRejection = Rxn<CheckpointModel>();
  final rejectionReasonController = TextEditingController();

  ClientDepartmentReviewController({
    required this.orderId,
    required this.workflowStatus,
    required this.operations,
  });

  bool get isRejected => workflowStatus.toUpperCase().contains('REJECTED');
  bool get isApprovalPending => workflowStatus.toUpperCase() == 'CLIENT_APPROVAL_PENDING';
  bool get isCompleted => workflowStatus.toUpperCase() == 'COMPLETED';

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }
  bool get isAllCompleted => operations.every((op) => op.isCompleted);

  Future<void> approveDepartment() async {
    try {
      isSubmitting.value = true;
      final success = await _clientService.approveDepartment(orderId);
      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Department Approved',
          'All operations have been approved successfully.',
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Approve Department API Error: $e');
      Get.snackbar(
        'Error',
        'Failed to approve department. Please try again.',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> rejectDepartment(
    String comment, {
    String? operationId,
    String? checkpointId,
  }) async {
    try {
      isSubmitting.value = true;
      final success = await _clientService.rejectDepartment(
        orderId,
        comment,
        operationId: operationId,
        checkpointId: checkpointId,
      );
      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Rejected',
          'Department work rejected.',
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      if (e.runtimeType.toString() == 'DioException') {
        final dioError = e as dynamic;
        debugPrint('Reject Department API Error Data: ${dioError.response?.data}');
      }
      debugPrint('Reject Department API Error: $e');
      Get.snackbar(
        'Error',
        'Failed to reject department.',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void submitRejectDepartment() {
    final reason = rejectionReasonController.text.trim();
    if (selectedOperationForRejection.value == null) {
      Get.snackbar(
        'Required',
        'Please select an operation',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    if (selectedCheckpointForRejection.value == null) {
      Get.snackbar(
        'Required',
        'Please select a checkpoint',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    if (reason.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter an issue description',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    Get.back();
    rejectDepartment(
      reason,
      operationId: selectedOperationForRejection.value?.id,
      checkpointId: selectedCheckpointForRejection.value?.id,
    );
  }
}
