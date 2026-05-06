import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/QualityControl/controllers/qc_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewBottomSheet extends StatefulWidget {
  final Map<String, dynamic> submission;

  const ReviewBottomSheet({super.key, required this.submission});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final QcDashboardController controller = Get.find<QcDashboardController>();
  String? _selectedTag;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.atelierSurfaceDark : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Review Submission",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.submission['checkpointName']} for Order ${widget.submission['orderName']}",
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle("REJECTION REASONS (IF REJECTING)", isDark),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.rejectionReasons.map((tag) => ChoiceChip(
                label: Text(tag),
                selected: _selectedTag == tag,
                onSelected: (selected) {
                  setState(() {
                    _selectedTag = selected ? tag : null;
                    if (selected) {
                      _commentController.text = tag;
                    }
                  });
                },
                labelStyle: GoogleFonts.manrope(
                  fontSize: 12,
                  color: _selectedTag == tag 
                    ? Colors.white 
                    : (isDark ? Colors.white70 : Colors.black87),
                ),
                selectedColor: AppColors.error,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
              )).toList(),
            )),
            
            const SizedBox(height: 24),
            _buildSectionTitle("FEEDBACK COMMENT", isDark),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: GoogleFonts.manrope(
                color: isDark ? Colors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: "Add details about the quality issue...",
                hintStyle: GoogleFonts.manrope(color: Colors.grey.shade500),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: "Reject",
                    color: AppColors.error,
                    isOutline: true,
                    isLoading: controller.isActionLoading.value,
                    onTap: () {
                      controller.rejectSubmission(
                        widget.submission['orderId'],
                        widget.submission['operationId'],
                        widget.submission['checkpointId'],
                        _commentController.text,
                      ).then((_) => Get.back());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: "Approve",
                    color: AppColors.atelierSilkGreen,
                    isLoading: controller.isActionLoading.value,
                    onTap: () {
                      controller.approveSubmission(
                        widget.submission['orderId'],
                        widget.submission['operationId'],
                        widget.submission['checkpointId'],
                      ).then((_) => Get.back());
                    },
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade500,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    bool isOutline = false,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          foregroundColor: isOutline ? color : Colors.white,
          elevation: isOutline ? 0 : 2,
          side: isOutline ? BorderSide(color: color) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
