import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewQueueItem extends StatelessWidget {
  final String orderId;
  final String workerName;
  final String department;
  final String checkpointName;
  final String time;
  final List<String> evidenceTypes;
  final VoidCallback onTap;

  const ReviewQueueItem({
    super.key,
    required this.orderId,
    required this.workerName,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Worker Initial / Avatar Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.atelierSilkGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      workerName.isNotEmpty ? workerName[0].toUpperCase() : '?',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.atelierSilkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              checkpointName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            workerName,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDot(isDark),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : AppColors.black).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              department.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Evidence Icons
                      Row(
                        children: evidenceTypes.map((type) => _buildEvidenceIcon(type, isDark)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isDark) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade400,
        shape: BoxShape.circle,
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
      case 'document':
        iconData = Icons.description_outlined;
        label = 'Doc';
        break;
      default:
        iconData = Icons.attach_file;
        label = 'File';
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 14,
            color: AppColors.atelierSilkGreen,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.atelierTonalGrey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
