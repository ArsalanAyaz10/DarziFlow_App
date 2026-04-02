import 'dart:ui' as BorderType;

import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/features/orders/controllers/checkpoint_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:image_picker/image_picker.dart';

class SubmitcheckpointScreen extends GetView<CheckpointController> {
  const SubmitcheckpointScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Submit Checkpoint',
        isDashboard: true,
        isTransparent: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              // TODO: Notifications Feature
            },
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(controller.ck.name, style: TextStyle(fontSize: 22)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          controller.op.status.isEmpty
                              ? "Unknown Status"
                              : controller.op.status,
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Obx(
                () => Text(
                  controller.checkpointDescription.value.isEmpty
                      ? "No submission instructions provided."
                      : controller.checkpointDescription.value,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    "QUALITY EVIDENCE",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      "${controller.pickedImages.length}/${controller.minUploads} Files",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.pickedImages.length < 10
                        ? controller.pickedImages.length + 1
                        : 10,
                    itemBuilder: (context, index) {
                      if (index == controller.pickedImages.length &&
                          index < 10) {
                        return _buildAddButton();
                      }
                      return _buildImagePreview(index);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Max file size: 100 MB.",
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    "Accepted formats: PNG, PDF.",
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "Checkpoint Remarks",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller.remarksController,
                  keyboardType: TextInputType.multiline,
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  maxLines: 4,
                  style: TextStyle(color: Colors.white70),
                  decoration: InputDecoration(
                    hintText: "Enter your remarks here...",
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Obx(
                () => CustomElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitCheckpoint(),
                  text: controller.isSubmitting.value
                      ? "Submitting..."
                      : "Submit Checkpoint",
                  height: 50,
                  icon: controller.isSubmitting.value ? null : Icons.send_sharp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(controller.pickedImages[index]),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return DottedBorder(
      child: GestureDetector(
        onTap: () => controller.pickImage(),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primaryGreen,
                size: 28,
              ),
              const SizedBox(height: 4),
              const Text(
                "ADD",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
