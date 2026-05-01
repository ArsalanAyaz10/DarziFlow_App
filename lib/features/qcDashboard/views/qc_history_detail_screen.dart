import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/qc_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class QcHistoryDetailScreen extends StatelessWidget {
  const QcHistoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QcHistoryModel log = Get.arguments as QcHistoryModel;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color actionColor = Colors.grey;
    IconData actionIcon = Icons.info_outline;
    String actionText = log.action;

    if (log.action == 'APPROVE' || log.action == 'FINAL_APPROVE') {
      actionColor = AppColors.atelierSilkGreen;
      actionIcon = Icons.check_circle;
      actionText = "Approved";
    } else if (log.action == 'REJECT') {
      actionColor = AppColors.error;
      actionIcon = Icons.cancel;
      actionText = "Rejected";
    } else if (log.action == 'SUBMIT') {
      actionColor = Colors.blue;
      actionIcon = Icons.upload_file;
      actionText = "Submitted";
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Action Details',
        isTransparent: false,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: actionColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                children: [
                  Icon(actionIcon, color: actionColor, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    actionText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: actionColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.formattedDate,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Context
            _buildSectionTitle("ORDER CONTEXT", colors),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2), width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailItem("Order Name", log.orderName, Icons.inventory_2_outlined, colors),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Workflow Details
            _buildSectionTitle("WORKFLOW DETAILS", colors),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2), width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailItem("Department", log.departmentName, Icons.business_outlined, colors),
                  Divider(height: 24, thickness: 0.5, color: colors.outline.withValues(alpha: 0.2)),
                  _buildDetailItem("Operation", log.operationName, Icons.settings_outlined, colors),
                  Divider(height: 24, thickness: 0.5, color: colors.outline.withValues(alpha: 0.2)),
                  _buildDetailItem("Checkpoint", log.checkpointName, Icons.fact_check_outlined, colors),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("FEEDBACK", colors),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withValues(alpha: 0.2), width: 1),
              ),
              child: Text(
                log.comment.isNotEmpty ? log.comment : "No feedback provided",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 1.4,
                  color: log.comment.isNotEmpty ? colors.onSurface : colors.onSurface.withValues(alpha: 0.5),
                  fontStyle: log.comment.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: colors.primary.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.isEmpty ? "N/A" : value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
