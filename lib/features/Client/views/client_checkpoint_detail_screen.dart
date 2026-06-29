import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/core/widgets/status_badge.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:dariziflow_app/features/Client/controllers/client_department_review_controller.dart';

class ClientCheckpointDetailScreen
    extends GetView<ClientDepartmentReviewController> {
  final CheckpointModel checkpoint;

  const ClientCheckpointDetailScreen({super.key, required this.checkpoint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppBar(
        title: 'Checkpoint Review',
        showBackButton: true,
        isTransparent: true,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Table(
            border: TableBorder.all(
              color: colors.outline.withValues(alpha: 0.5),
              width: 1,
            ),
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _headerRow(colors),
              _dataRow(
                'Checkpoint Name',
                Text(
                  checkpoint.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colors.onSurface,
                  ),
                ),
              ),
              _dataRow(
                'Status',
                StatusBadge(
                  status: checkpoint.status,
                  fontSize: 10,
                  showDot: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              _dataRow(
                'Uploads Allowed',
                Text(
                  '${checkpoint.minUploads}',
                  style: TextStyle(fontSize: 13, color: colors.onSurface),
                ),
              ),
              _dataRow(
                'Required Format',
                Text(
                  checkpoint.allowedTypes.isEmpty
                      ? 'Any'
                      : checkpoint.allowedTypes.join(', ').toUpperCase(),
                  style: TextStyle(fontSize: 13, color: colors.onSurface),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.8),
            height: 1,
          ),
          const SizedBox(height: 20),

          _buildContainerField(
            label: 'Submission Instructions',
            child: Text(
              checkpoint.description.isEmpty
                  ? 'No submission instructions provided.'
                  : checkpoint.description,
              style: TextStyle(fontSize: 13, color: colors.onSurface),
            ),
            colors: colors,
            borderColor: colors.outline.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 15),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.8),
            height: 1,
          ),
          const SizedBox(height: 15),

          _buildContainerField(
            label: 'Submitted Evidence',
            child: checkpoint.submissionFiles.isEmpty
                ? Text(
                    'No media files submitted.',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  )
                : SizedBox(
                    height: Get.height * 0.18,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: checkpoint.submissionFiles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, i) => _buildMediaThumb(
                        context,
                        checkpoint.submissionFiles[i],
                        colors,
                        theme.brightness == Brightness.dark,
                      ),
                    ),
                  ),
            colors: colors,
            borderColor: colors.outline.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 10),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.8),
            height: 1,
          ),
          const SizedBox(height: 10),

          _buildContainerField(
            label: 'Submitted Remarks',
            child: Text(
              checkpoint.submissionText.isEmpty
                  ? 'No remarks provided.'
                  : checkpoint.submissionText,
              style: TextStyle(fontSize: 13, color: colors.onSurface),
            ),
            colors: colors,
            borderColor: colors.outline.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.atelierAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.atelierAmber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.atelierAmber,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For queries, please contact support.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (theme.brightness == Brightness.dark)
                          ? AppColors.atelierAmber
                          : AppColors.atelierAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _headerRow(ColorScheme colors) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: colors.onSurface.withValues(alpha: 0.5),
    );
    return TableRow(
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.04),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text('HEADING', style: style),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text('DETAIL', style: style),
        ),
      ],
    );
  }

  TableRow _dataRow(String label, Widget value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: value,
        ),
      ],
    );
  }

  Widget _buildContainerField({
    required String label,
    required Widget child,
    required ColorScheme colors,
    required Color borderColor,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
      child: child,
    );
  }

  Widget _buildMediaThumb(
    BuildContext context,
    SubmissionFile file,
    ColorScheme colors,
    bool isDark,
  ) {
    final isImage = file.resourceType.toLowerCase().contains('image');
    final isVideo = file.resourceType.toLowerCase().contains('video');
    final isPdf = file.resourceType.toLowerCase().contains('pdf');
    final isDoc =
        file.resourceType.toLowerCase().contains('word') ||
        file.resourceType.toLowerCase().contains('document');

    final label = file.publicId.replaceAll('_', ' ').toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            if (isImage) {
              _showFullScreenImage(context, file.url);
            } else {
              final Uri url = Uri.parse(file.url);
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                dev.log('Error opening file: $e');
                Get.snackbar('Error', 'Could not open the file.');
              }
            }
          },
          child: Container(
            width: 120,
            height: 110,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ─── Background / Main Display ───
                if (isImage)
                  Image.network(
                    file.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, p) => p == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.atelierSilkGreen,
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.grey,
                        size: 28,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      isVideo
                          ? Icons.video_file_rounded
                          : isPdf
                          ? Icons.picture_as_pdf_rounded
                          : isDoc
                          ? Icons.description_rounded
                          : Icons.insert_drive_file_rounded,
                      size: 40,
                      color: isVideo
                          ? AppColors.atelierAmber
                          : isPdf
                          ? Colors.redAccent
                          : isDoc
                          ? Colors.blueAccent
                          : AppColors.atelierSilkGreen,
                    ),
                  ),

                // ─── Hover Icon Overlay ───
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(file.url);
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            dev.log('Error opening file: $e');
                            Get.snackbar('Error', 'Could not open the file.');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          margin: EdgeInsets.only(
                            right: (isImage || isVideo) ? 4 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      if (isImage || isVideo)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isImage
                                ? Icons.zoom_in_rounded
                                : Icons.play_arrow_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 120,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppBar(
            backgroundColor: AppColors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.atelierSilkGreen,
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.grey,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
