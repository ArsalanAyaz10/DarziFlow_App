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
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header with name, status and history
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  // Submission Requirements
                  _buildRequirements(),
                  const SizedBox(height: 16),
                  // Instructions
                  _buildInstructions(),
                  const SizedBox(height: 30),

                  if (controller.isQC) ...[
                    _buildSubmittedEvidence(context),
                  ] else ...[
                    _buildSubmissionForm(),
                  ],

                  const SizedBox(height: 40),
                  _buildFeedbackSection(),
                  const SizedBox(height: 24),

                  _buildActionButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.ck.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.history, color: Colors.white54, size: 20),
            tooltip: 'View History',
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 4, backgroundColor: AppColors.primaryGreen),
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
    );
  }

  Widget _buildRequirements() {
    if (controller.ck.allowedTypes.isEmpty) return const SizedBox.shrink();
    
    return Row(
      children: [
        const Text(
          "Required Evidence: ",
          style: TextStyle(fontSize: 12, color: Colors.white54),
        ),
        Wrap(
          spacing: 6,
          children: controller.ck.allowedTypes.map((type) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                type,
                style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Obx(() => Text(
          controller.checkpointDescription.value.isEmpty
              ? "No submission instructions provided."
              : controller.checkpointDescription.value,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ));
  }

  Widget _buildSubmissionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Evidence (IMAGES)",
              style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Obx(() => Text(
                  "${controller.pickedImages.length}/${controller.minUploads} Files",
                  style: const TextStyle(fontSize: 10),
                )),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pickedImages.length < 10 ? controller.pickedImages.length + 1 : 10,
                itemBuilder: (context, index) {
                  if (index == controller.pickedImages.length && index < 10) {
                    return _addButton();
                  }
                  return _imagePreview(index);
                },
              )),
        ),
        const SizedBox(height: 8),
        const Text(
          "Max file size: 100 MB. Accepted formats: PNG, JPG, PDF.",
          style: TextStyle(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildSubmittedEvidence(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SUBMITTED EVIDENCE",
          style: TextStyle(fontSize: 14, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (controller.ck.submissionFiles.isEmpty)
          const Text("No media files uploaded.", style: TextStyle(color: Colors.white38, fontSize: 12))
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.ck.submissionFiles.length,
              itemBuilder: (context, index) {
                final file = controller.ck.submissionFiles[index];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, file.url),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 120,
                    decoration: BoxDecoration(
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
        const SizedBox(height: 24),
        const Text(
          "SUBMITTED REMARKS",
          style: TextStyle(fontSize: 14, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            controller.ck.submissionText.isEmpty ? "No remarks provided by applicant." : controller.ck.submissionText,
            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.isQC ? "QC Review Feedback" : "Submission Remarks",
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: TextField(
            controller: controller.remarksController,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: controller.isQC ? "Provide feedback or rejection reasons..." : "Enter your submission notes...",
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (controller.isQC) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              onPressed: () => controller.rejectCheckpoint(),
              text: "Reject",
              color: Colors.redAccent,
              isLoading: controller.isActionLoading.value,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              onPressed: () => controller.approveCheckpoint(),
              text: "Approve",
              color: AppColors.primaryGreen,
              isLoading: controller.isActionLoading.value,
            ),
          ),
        ],
      );
    }

    return Obx(() => CustomElevatedButton(
          onPressed: controller.isSubmitting.value ? null : () => controller.submitCheckpoint(),
          text: controller.isSubmitting.value ? "Submitting..." : "Submit Checkpoint",
          height: 52,
          icon: controller.isSubmitting.value ? null : Icons.send_sharp,
        ));
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required Color color,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _imagePreview(int index) {
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

  Widget _addButton() {
    return DottedBorder(
      child: GestureDetector(
        onTap: () => controller.pickImage(),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, color: AppColors.primaryGreen, size: 28),
              const SizedBox(height: 8),
              const Text("ADD", style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
            ],
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
