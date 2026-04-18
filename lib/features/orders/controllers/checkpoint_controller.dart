
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'dart:developer' as dev;
import 'package:path_provider/path_provider.dart' as path_provider;
import "dart:io";

import 'package:image_picker/image_picker.dart';

class CheckpointController extends GetxController {
  TextEditingController remarksController = TextEditingController();

  final OrderRepository orderRepository;
  final UploadService uploadService;

  CheckpointController(
    this.orderRepository,
    this.uploadService,
  );

  var operation = Rxn<OperationModel>();
  var isLoading = false.obs;
  late final OperationModel op;
  late final CheckpointModel ck;
  String orderId = '';
  var checkpointDescription = ''.obs;
  var minUploads = 0.obs;
  var SubmissionTypes = [];

  // Image variables
  var pickedImages = <File>[].obs;
  final int maxFiles = 10;

  // loading
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    op = Get.arguments['operation'];
    ck = Get.arguments['checkpoint'];
    orderId = Get.arguments['orderId'];
    if (orderId.isEmpty) {
      dev.log("LOG: orderId passed to SubmitCheckpoint is empty or null");
    }
    
    minUploads.value = ck.minUploads;
    checkpointDescription.value = ck.submissionText.isNotEmpty ? ck.submissionText : "No Description Provided";
    SubmissionTypes = [ck.submissionType];
  }

  Future<void> pickImage() async {
    if (pickedImages.length >= maxFiles) {
      Get.snackbar(
        "Limit Reached",
        "You can only upload up to $maxFiles files.",
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      pickedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    pickedImages.removeAt(index);
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await path_provider.getTemporaryDirectory();
    final targetPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, //% compression
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  Future<void> submitCheckpoint() async {
    if (pickedImages.isEmpty && remarksController.text.isEmpty) {
      Get.snackbar("Error", "Please provide remarks or evidence.");
      return;
    }

    try {
      isSubmitting.value = true;
      dev.log("SUBMITTING FOR ORDER ID: '$orderId'");

      if (orderId.isEmpty) {
        Get.snackbar("Error", "Order Context Missing");
        return;
      }
      List<Map<String, dynamic>> evidenceList = [];

      final sigData = await uploadService.getCheckpointUploadSignature(
        orderId: orderId,
      );

      for (var image in pickedImages) {
        File? compressed = await _compressImage(image);
        if (compressed == null) continue;

        final uploadResult = await uploadService.uploadToCloudinary(
          file: compressed,
          cloudName: sigData['cloudName'],
          apiKey: sigData['apiKey'],
          timestamp: sigData['timestamp'].toString(),
          signature: sigData['signature'],
          folder: sigData['folder'],
        );

        evidenceList.add({
          "url": uploadResult['secure_url'],
          "publicId": uploadResult['public_id'],
          "resourceType": uploadResult['resource_type'],
        });
      }

      bool success = await orderRepository.submitCheckpointData(
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
          "Checkpoint submitted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      dev.log("Final Submission Error: $e");
      Get.snackbar("Submission Failed", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}
