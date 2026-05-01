import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/qcDashboard/repositories/qc_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:path_provider/path_provider.dart' as path_provider;
import "dart:io";

import 'package:image_picker/image_picker.dart';

class CheckpointController extends GetxController {
  final TextEditingController remarksController = TextEditingController();
  final OrderRepository orderRepository;
  final UploadService uploadService;

  CheckpointController(
    this.orderRepository,
    this.uploadService,
    OrderDetailController find,
  );

  late final OperationModel op;
  late final CheckpointModel ck;
  String orderId = '';

  final checkpointDescription = ''.obs;
  final minUploads = 0.obs;
  final pickedImages = <File>[].obs;
  final userRole = ''.obs;

  final isSubmitting = false.obs;
  final isActionLoading = false.obs;
  final int maxFiles = 10;

  @override
  void onInit() {
    super.onInit();
    op = Get.arguments['operation'];
    ck = Get.arguments['checkpoint'];
    orderId = Get.arguments['orderId'] ?? '';

    minUploads.value = ck.minUploads;
    checkpointDescription.value = ck.submissionText.isNotEmpty
        ? ck.submissionText
        : "No Description Provided";
    dev.log("Submission Text: ${ck.submissionText}");
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await AppStorage.getUserRole();
    userRole.value = role?.toUpperCase() ?? '';
  }

  bool get isQC => userRole.value == 'QC_MEMBER';

  Future<void> pickImage() async {
    if (pickedImages.length >= maxFiles) {
      Get.snackbar("Limit Reached", "Max $maxFiles files allowed.");
      return;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) pickedImages.add(File(image.path));
  }

  void removeImage(int index) => pickedImages.removeAt(index);

  Future<File?> _compressImage(File file) async {
    final tempDir = await path_provider.getTemporaryDirectory();
    final targetPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    return result != null ? File(result.path) : null;
  }

  Future<void> submitCheckpoint() async {
    if (pickedImages.isEmpty && remarksController.text.isEmpty) {
      Get.snackbar("Error", "Please provide remarks or evidence.");
      return;
    }

    if (orderId.isEmpty) {
      Get.snackbar("Error", "Order Context Missing");
      return;
    }

    try {
      isSubmitting.value = true;
      final List<Map<String, dynamic>> evidenceList = [];
      final sigData = await uploadService.getCheckpointUploadSignature(
        orderId: orderId,
      );

      for (var image in pickedImages) {
        final compressed = await _compressImage(image);
        if (compressed == null) continue;

        final upload = await uploadService.uploadToCloudinary(
          file: compressed,
          cloudName: sigData['cloudName'],
          apiKey: sigData['apiKey'],
          timestamp: sigData['timestamp'].toString(),
          signature: sigData['signature'],
          folder: sigData['folder'],
        );

        evidenceList.add({
          "url": upload['secure_url'],
          "publicId": upload['public_id'],
          "resourceType": upload['resource_type'],
        });
      }

      final success = await orderRepository.submitCheckpointData(
        orderId: orderId,
        opId: op.id,
        chkId: ck.id,
        remarks: remarksController.text,
        evidence: evidenceList,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Success",
          "Submitted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      dev.log("Submission Error", error: e);
      Get.snackbar("Error", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> approveCheckpoint() async {
    isActionLoading.value = true;
    try {
      final success = await Get.find<QcRepository>().approveSubmission(
        orderId: orderId,
        opId: op.id,
        chkId: ck.id,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Success",
          "Approved",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> rejectCheckpoint() async {
    if (remarksController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "Please provide a rejection comment.",
        backgroundColor: Colors.orange,
      );
      return;
    }

    isActionLoading.value = true;
    try {
      final success = await Get.find<QcRepository>().rejectSubmission(
        orderId: orderId,
        opId: op.id,
        chkId: ck.id,
        comment: remarksController.text,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Rejected",
          "Sent for rework",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }
}
