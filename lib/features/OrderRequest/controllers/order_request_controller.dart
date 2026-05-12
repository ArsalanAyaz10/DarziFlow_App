import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/features/OrderRequest/services/order_request_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderRequestController extends GetxController {
  final OrderRequestService _service = Get.find<OrderRequestService>();

  // State Variables
  final RxList<OrderRequestModel> requests = <OrderRequestModel>[].obs;
  final Rx<OrderRequestModel?> currentRequest = Rx<OrderRequestModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  /// Fetch all requests for the current user
  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedRequests = await _service.getAllRequests();
      requests.assignAll(fetchedRequests);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch order requests',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch details for a specific request
  Future<void> fetchRequestDetails(String id) async {
    try {
      isLoading.value = true;
      final request = await _service.getRequestById(id);
      currentRequest.value = request;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch request details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a new order request
  Future<bool> submitRequest({
    required String name,
    required String type,
    required String description,
    required DateTime targetDueDate,
    required List<AttachedFileModel> files,
  }) async {
    try {
      isLoading.value = true;
      final data = {
        'name': name,
        'type': type,
        'description': description,
        'targetDueDate': targetDueDate.toIso8601String(),
        'originalReferenceFiles': files.map((f) => f.toJson()).toList(),
      };

      await _service.createRequest(data);
      await fetchRequests(); // Refresh list
      Get.snackbar('Success', 'Order request submitted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a new proposal to an existing request
  Future<bool> submitProposal({
    required String requestId,
    int? amount,
    DateTime? dueDate,
    String? remarks,
    List<AttachedFileModel>? files,
    List<String>? departmentSequenceIds,
  }) async {
    try {
      isLoading.value = true;
      final proposalData = {
        if (amount != null) 'proposedAmount': amount,
        if (dueDate != null) 'proposedDueDate': dueDate.toIso8601String(),
        if (remarks != null) 'remarks': remarks,
        if (files != null) 'proposedReferenceFiles': files.map((f) => f.toJson()).toList(),
        if (departmentSequenceIds != null) 'departmentSequenceIds': departmentSequenceIds,
      };

      final updatedRequest = await _service.addProposal(requestId, proposalData);
      currentRequest.value = updatedRequest;
      
      // Update in the list as well
      int index = requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        requests[index] = updatedRequest;
      }
      
      Get.snackbar('Success', 'Proposal submitted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit proposal');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert request to order (Admin only logic)
  Future<void> convertToOrder(String requestId) async {
    try {
      isLoading.value = true;
      await _service.convertRequest(requestId);
      await fetchRequests(); // Refresh list to show CONVERTED status
      Get.snackbar('Success', 'Request converted to Order successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to convert request');
    } finally {
      isLoading.value = false;
    }
  }
}
