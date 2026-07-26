import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  final RxList<File> pickedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  /// Pick files for order request
  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null) {
        for (var path in result.paths) {
          if (path != null) {
            pickedFiles.add(File(path));
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick files');
    }
  }

  /// Remove a picked file
  void removeFile(int index) {
    if (index >= 0 && index < pickedFiles.length) {
      pickedFiles.removeAt(index);
    }
  }

  /// Fetch all requests for the current user
  Future<void> fetchRequests({Map<String, dynamic>? queryParameters}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedRequests = await _service.getAllRequests(queryParameters: queryParameters);
      requests.assignAll(fetchedRequests);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch order requests',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.1),
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
  }) async {
    try {
      isLoading.value = true;
      
      // Upload files first
      List<AttachedFileModel> uploadedFiles = [];
      if (pickedFiles.isNotEmpty) {
        final sigData = await _service.getUploadSignature(context: 'order_request');
        for (var file in pickedFiles) {
          final uploadResult = await _service.uploadToCloudinary(
            filePath: file.path,
            cloudName: sigData['cloudName'],
            apiKey: sigData['apiKey'],
            timestamp: sigData['timestamp'].toString(),
            signature: sigData['signature'],
            folder: sigData['folder'],
          );
          uploadedFiles.add(AttachedFileModel(
            fileName: file.path.split(Platform.pathSeparator).last,
            fileUrl: uploadResult['secure_url'],
            publicId: uploadResult['public_id'],
            resourceType: uploadResult['resource_type'],
          ));
        }
      }

      final data = {
        'name': name,
        'type': type,
        'description': description,
        'targetDueDate': targetDueDate.toIso8601String(),
        'originalReferenceFiles': uploadedFiles.map((f) => f.toJson()).toList(),
      };

      await _service.createRequest(data);
      await fetchRequests(); // Refresh list
      pickedFiles.clear(); // Clear picked files on success
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
        'proposedAmount': ?amount,
        'proposedDueDate': ?dueDate?.toIso8601String(),
        'remarks': ?remarks,
        'proposedReferenceFiles': ?files?.map((f) => f.toJson()).toList(),
        'departmentSequenceIds': ?departmentSequenceIds,
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
