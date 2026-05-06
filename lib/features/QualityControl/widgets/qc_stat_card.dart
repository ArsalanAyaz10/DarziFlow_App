import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class QCStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final IconData icon;
  final Color accentColor;

  const QCStatCard({
    super.key,
    required this.label,
    required this.value,
    this.subText = '',
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.atelierSurfaceDark
        : AppColors.atelierSurfaceLight;

    final labelColor = isDark
        ? AppColors.atelierTonalGrey
        : Colors.grey.shade600;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
                if (subText.isNotEmpty)
                  Expanded(
                    child: Text(
                      subText,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
