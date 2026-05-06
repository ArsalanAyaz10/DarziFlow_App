import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewQueueItem extends StatelessWidget {
  final String orderName;
  final String department;
  final String checkpointName;
  final String time;
  final List<String> evidenceTypes;
  final VoidCallback onTap;

  const ReviewQueueItem({
    super.key,
    required this.orderName,
    required this.department,
    required this.checkpointName,
    required this.time,
    required this.evidenceTypes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.atelierSurfaceDark
        : AppColors.atelierSurfaceLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        checkpointName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppColors.black.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      time,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.atelierTonalGrey
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  orderName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : AppColors.black)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        department.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.atelierTonalGrey
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ...evidenceTypes.map(
                      (type) => _buildEvidenceIcon(type, isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceIcon(String type, bool isDark) {
    IconData iconData;
    String label;

    switch (type.toLowerCase()) {
      case 'photo':
        iconData = Icons.photo_outlined;
        label = 'Photo';
        break;
      case 'video':
        iconData = Icons.videocam_outlined;
        label = 'Video';
        break;
      case 'text':
        iconData = Icons.notes;
        label = 'Text';
        break;
      case 'document':
        iconData = Icons.description_outlined;
        label = 'Doc';
        break;
      default:
        iconData = Icons.attach_file;
        label = 'File';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Icon(iconData, size: 14, color: AppColors.atelierSilkGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
