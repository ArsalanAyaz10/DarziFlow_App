import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/features/orders/controllers/checkpoint_controller.dart';
import 'package:dariziflow_app/features/orders/widgets/checkpoint_history_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubmitcheckpointScreen extends GetView<CheckpointController> {
  const SubmitcheckpointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: controller.isQC ? 'Review Checkpoint' : 'Submit Checkpoint',
        isDashboard: true,
        isTransparent: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.ck.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (controller.ck.history.isNotEmpty)
                      IconButton(
                        onPressed: () => Get.bottomSheet(
                          CheckpointHistorySheet(
                            history: controller.ck.history,
                            checkpointName: controller.ck.name,
                          ),
                          isScrollControlled: true,
                        ),
                        icon: Icon(
                          Icons.history,
                          color: colors.onSurfaceVariant,
                          size: 18,
                        ),
                        tooltip: 'View History',
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            controller.ck.status.replaceAll('_', ' '),
                            style: const TextStyle(
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
                Divider(color: colors.outlineVariant, height: 10),
                const SizedBox(height: 5),

                // Requirements
                if (controller.ck.allowedTypes.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "Required Evidence: ",
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Wrap(
                        spacing: 6,
                        children: controller.ck.allowedTypes
                            .map(
                              (type) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),

                Divider(color: colors.outlineVariant, height: 10),

                const SizedBox(height: 5),

                // Instructions
                const Text(
                  "Submission Instructions:",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Obx(
                  () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      controller.checkpointDescription.value.isEmpty
                          ? "No submission instructions provided."
                          : controller.checkpointDescription.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Divider(color: colors.outlineVariant, height: 10),

                const SizedBox(height: 10),

                if (controller.isQC) ...[
                  // Submitted Evidence
                  const Text(
                    "SUBMITTED EVIDENCE",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (controller.ck.submissionFiles.isEmpty)
                    Text(
                      "No media files uploaded.",
                      style: TextStyle(color: colors.error, fontSize: 12),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.ck.submissionFiles.length,
                        itemBuilder: (context, index) {
                          final file = controller.ck.submissionFiles[index];
                          return GestureDetector(
                            onTap: () =>
                                _showFullScreenImage(context, file.url),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 100,
                              decoration: BoxDecoration(
                                color: colors.onSurface.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(file.url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),

                  Divider(color: colors.outlineVariant, height: 10),

                  const SizedBox(height: 10),

                  // Submitted Remarks
                  const Text(
                    "SUBMITTED REMARKS",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Text(
                      controller.ck.submissionText.isEmpty
                          ? "No remarks provided by applicant."
                          : controller.ck.submissionText,
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ] else ...[
                  // Submission Form
                  Row(
                    children: [
                      const Text(
                        "Evidence (IMAGES)",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryGreen,
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
                            return DottedBorder(
                              child: GestureDetector(
                                onTap: () => controller.pickImage(),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: colors.onSurface.withValues(
                                      alpha: .05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "ADD",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(
                                  controller.pickedImages[index],
                                ),
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
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Max file size: 100 MB. Accepted formats: PNG, JPG, PDF.",
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Divider(color: colors.outlineVariant, height: 10),

                // Feedback Section
                Text(
                  controller.isQC ? "QC Review Feedback" : "Submission Remarks",
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outlineVariant, width: 1),
                  ),
                  child: TextField(
                    controller: controller.remarksController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    style: TextStyle(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: controller.isQC
                          ? "Provide feedback or rejection reasons..."
                          : "Enter your submission notes...",
                      hintStyle: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.3),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Action Buttons
                if (controller.isQC)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isActionLoading.value
                                ? null
                                : () => controller.rejectCheckpoint(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isActionLoading.value
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Reject",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isActionLoading.value
                                ? null
                                : () => controller.approveCheckpoint(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isActionLoading.value
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Approve",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  CustomElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitCheckpoint(),
                    text: controller.isSubmitting.value
                        ? "Submitting..."
                        : "Submit Checkpoint",
                    height: 40,
                    icon: controller.isSubmitting.value
                        ? null
                        : Icons.send_sharp,
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Get.dialog(
      GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.black87,
          child: Center(
            child: Hero(
              tag: url,
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
      useSafeArea: false,
    );
  }
}
