import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/Orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/features/Orders/controllers/order_workflow_controller.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/QualityControl/repositories/qc_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class CheckpointController extends GetxController {
  final TextEditingController remarksController = TextEditingController();
  final OrderRepository orderRepository;
  final UploadService uploadService;
  final ImagePicker _picker = ImagePicker();

  CheckpointController(
    this.orderRepository,
    this.uploadService,
  );

  late final OperationModel op;
  late final CheckpointModel ck;
  String orderId = '';

  final checkpointDescription = ''.obs;
  final minUploads = 0.obs;
  final pickedImages = <File>[].obs;
  SubmissionType allowedSubmissions = SubmissionType.text;
  final userRole = ''.obs;

  final isSubmitting = false.obs;
  final isActionLoading = false.obs;
  final maxFiles = 10.obs;

  @override
  void onInit() {
    super.onInit();
    op = Get.arguments['operation'];
    ck = Get.arguments['checkpoint'];
    orderId = Get.arguments['orderId'] ?? '';

    minUploads.value = ck.minUploads;
    if (minUploads.value > 0) {
      maxFiles.value = minUploads.value;
    } else {
      maxFiles.value = 10;
    }
    allowedSubmissions = ck.submissionType;
    checkpointDescription.value = ck.description.isNotEmpty
        ? ck.description
        : "No Description Provided";
    dev.log("Description: ${ck.description}");
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await AppStorage.getUserRole();
    userRole.value = role?.toUpperCase() ?? '';
  }

  bool get isQC => userRole.value == 'QC_MEMBER';

  Future<void> pickMedia({bool fromCamera = false, bool isVideo = false, bool isFile = false}) async {
    final allowed = ck.allowedTypes.map((e) => e.toUpperCase()).toList();
    final isMediaAllowed = allowed.isEmpty ||
        allowed.contains('IMAGE') ||
        allowed.contains('VIDEO') ||
        allowed.contains('DOCUMENT') ||
        allowed.contains('DOC') ||
        ck.submissionType != SubmissionType.text;

    if (!isMediaAllowed) {
      Get.snackbar("Not Allowed", "This checkpoint only accepts text submissions.");
      return;
    }

    if (pickedImages.length >= maxFiles.value) {
      Get.snackbar("Limit Reached", "Max ${maxFiles.value} files allowed.");
      return;
    }

    try {
      if (isFile) {
        List<String> allowedExtensions = [];
        final allowed = ck.allowedTypes.map((e) => e.toUpperCase()).toList();
        if (allowed.isEmpty || allowed.contains('IMAGE')) {
          allowedExtensions.addAll(['jpg', 'jpeg', 'png']);
        }
        if (allowed.isEmpty || allowed.contains('VIDEO')) {
          allowedExtensions.addAll(['mp4', 'mov', 'avi']);
        }
        if (allowed.isEmpty || allowed.contains('DOCUMENT') || allowed.contains('DOC')) {
          allowedExtensions.addAll(['pdf', 'doc', 'docx']);
        }

        final result = await FilePicker.pickFiles(
          type: allowedExtensions.isNotEmpty ? FileType.custom : FileType.any,
          allowedExtensions: allowedExtensions.isNotEmpty ? allowedExtensions : null,
          allowMultiple: true,
        );

        if (result != null) {
          for (var path in result.paths) {
            if (path != null && pickedImages.length < maxFiles.value) {
              pickedImages.add(File(path));
            } else if (path != null && pickedImages.length >= maxFiles.value) {
              Get.snackbar("Limit Reached", "Some files were not added because the limit of ${maxFiles.value} was reached.");
              break;
            }
          }
        }
      } else if (isVideo) {
        final XFile? video = await _picker.pickVideo(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        );
        if (video != null) {
          pickedImages.add(File(video.path));
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 70,
        );
        if (image != null) {
          pickedImages.add(File(image.path));
        }
      }
    } catch (e) {
      dev.log("Pick Media Error: $e");
      Get.snackbar("Error", "Failed to pick media: $e");
    }
  }

  void removeImage(int index) => pickedImages.removeAt(index);

  Future<File?> _processFile(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      return file; 
    }

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
    if (pickedImages.length < minUploads.value) {
      Get.snackbar(
        "Missing Evidence",
        "This checkpoint requires at least ${minUploads.value} evidence file(s).",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (pickedImages.isEmpty && remarksController.text.isEmpty) {
      Get.snackbar("Error", "Please provide remarks or evidence.");
      return;
    }

    if (pickedImages.isNotEmpty) {
      final allowed = ck.allowedTypes.map((e) => e.toUpperCase()).toList();
      final isMediaAllowed = allowed.contains('IMAGE') ||
          allowed.contains('VIDEO') ||
          allowed.contains('DOCUMENT') ||
          allowed.contains('DOC') ||
          ck.submissionType != SubmissionType.text;

      if (!isMediaAllowed) {
        Get.snackbar("Error", "Media upload is not allowed for this checkpoint.");
        return;
      }

      if (allowed.isNotEmpty) {
        bool isImageAllowed = allowed.contains('IMAGE');
        bool isVideoAllowed = allowed.contains('VIDEO');
        bool isDocAllowed =
            allowed.contains('DOCUMENT') || allowed.contains('DOC');

        List<String> validExts = [];
        if (isImageAllowed) validExts.addAll(['jpg', 'jpeg', 'png']);
        if (isVideoAllowed) validExts.addAll(['mp4', 'mov', 'avi']);
        if (isDocAllowed) validExts.addAll(['pdf', 'doc', 'docx']);

        for (var file in pickedImages) {
          final ext = file.path.split('.').last.toLowerCase();
          if (validExts.isNotEmpty && !validExts.contains(ext)) {
            Get.snackbar(
              "Invalid Submission",
              "File type .$ext is not allowed. Accepted formats: ${ck.allowedTypes.join(', ')}",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
        }
      }
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
        final processed = await _processFile(image);
        if (processed == null) continue;

        final upload = await uploadService.uploadToCloudinary(
          file: processed,
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
        _refreshRelatedControllers();
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

  void _refreshRelatedControllers() {
    if (Get.isRegistered<OrderDetailController>()) {
      Get.find<OrderDetailController>().refreshOrderDetails();
    }
    if (Get.isRegistered<OrderWorkflowController>()) {
      Get.find<OrderWorkflowController>().refreshOrderDetails();
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
        _refreshRelatedControllers();
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
        _refreshRelatedControllers();
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
