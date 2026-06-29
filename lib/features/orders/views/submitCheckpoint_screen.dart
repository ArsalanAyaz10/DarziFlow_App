import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/features/Orders/controllers/checkpoint_controller.dart';
import 'package:dariziflow_app/features/Orders/widgets/checkpoint_history_sheet.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    StatusBadge(
                      status: controller.ck.status,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: colors.outlineVariant, height: 10),
                const SizedBox(height: 10),

                // Requirements
                if (controller.ck.allowedTypes.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "Required Formats: ",
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
                          final isImage = file.resourceType == 'image';

                          return InkWell(
                            onTap: () async {
                              try {
                                final uri = Uri.parse(file.url);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                Get.snackbar('Error', 'Could not open the file.');
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 100,
                              decoration: BoxDecoration(
                                color: colors.onSurface.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            child: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      file.url,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          file.resourceType == 'video'
                                              ? Icons.video_file
                                              : Icons.insert_drive_file,
                                          size: 30,
                                          color: AppColors.primaryGreen,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          file.resourceType.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
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
                  (() {
                    final allowed = controller.ck.allowedTypes
                        .map((e) => e.toUpperCase())
                        .toList();
                    final hasMediaAllowed =
                        allowed.isEmpty ||
                        allowed.contains('IMAGE') ||
                        allowed.contains('VIDEO') ||
                        allowed.contains('DOCUMENT') ||
                        allowed.contains('DOC') ||
                        controller.ck.submissionType != SubmissionType.text;

                    if (!hasMediaAllowed) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Evidence Files",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Obx(
                              () => Text(
                                "${controller.pickedImages.length}/${controller.maxFiles.value} Files",
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      controller.pickedImages.length <
                                          controller.minUploads.value
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              itemCount:
                                  controller.pickedImages.length <
                                      controller.maxFiles.value
                                  ? controller.pickedImages.length + 1
                                  : controller.maxFiles.value,
                              itemBuilder: (context, index) {
                                if (index == controller.pickedImages.length &&
                                    index < controller.maxFiles.value) {
                                  return DottedBorder(
                                    child: GestureDetector(
                                      onTap: () =>
                                          _mediaSelectionBottombar(context),
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: colors.onSurface.withValues(
                                            alpha: .05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.upload_file,
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

                                final file = controller.pickedImages[index];
                                final ext = file.path
                                    .split('.')
                                    .last
                                    .toLowerCase();
                                final isImage = [
                                  'jpg',
                                  'jpeg',
                                  'png',
                                ].contains(ext);

                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: colors.onSurface.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      isImage
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    [
                                                          'mp4',
                                                          'mov',
                                                          'avi',
                                                        ].contains(ext)
                                                        ? Icons.video_file
                                                        : Icons
                                                              .insert_drive_file,
                                                    size: 30,
                                                    color:
                                                        AppColors.primaryGreen,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    ext.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.removeImage(index),
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
                        const SizedBox(height: 20),
                        Divider(color: colors.outlineVariant, height: 0),
                      ],
                    );
                  }()),
                ],
                const SizedBox(height: 10),
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
                const SizedBox(height: 30),

                // Action Buttons
                if (controller.isQC)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isRejecting.value || controller.isApproving.value
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
                            child: controller.isRejecting.value
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
                            onPressed: controller.isApproving.value || controller.isRejecting.value
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
                            child: controller.isApproving.value
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

  void _mediaSelectionBottombar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final allowed = controller.ck.allowedTypes
        .map((e) => e.toUpperCase())
        .toList();

    bool canShowImage = allowed.isEmpty || allowed.contains('IMAGE');
    bool canShowVideo = allowed.isEmpty || allowed.contains('VIDEO');
    bool canShowFile =
        allowed.isEmpty ||
        allowed.contains('DOCUMENT') ||
        allowed.contains('DOC');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Media Source",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            if (canShowImage) ...[
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryGreen,
                ),
                title: const Text("Take Photo"),
                onTap: () {
                  Get.back();
                  controller.pickMedia(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryGreen,
                ),
                title: const Text("Pick from Gallery"),
                onTap: () {
                  Get.back();
                  controller.pickMedia(fromCamera: false);
                },
              ),
            ],
            if (canShowVideo) ...[
              ListTile(
                leading: const Icon(
                  Icons.videocam,
                  color: AppColors.primaryGreen,
                ),
                title: const Text("Record Video"),
                onTap: () {
                  Get.back();
                  controller.pickMedia(fromCamera: true, isVideo: true);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.video_library,
                  color: AppColors.primaryGreen,
                ),
                title: const Text("Pick Video from Gallery"),
                onTap: () {
                  Get.back();
                  controller.pickMedia(fromCamera: false, isVideo: true);
                },
              ),
            ],
            if (canShowFile)
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file,
                  color: AppColors.primaryGreen,
                ),
                title: const Text("Upload Files / Documents"),
                onTap: () {
                  Get.back();
                  controller.pickMedia(isFile: true);
                },
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
