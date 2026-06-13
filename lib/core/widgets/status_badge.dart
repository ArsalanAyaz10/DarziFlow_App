import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toUpperCase();

    Color baseColor;
    if (cleanStatus == 'COMPLETED' ||
        cleanStatus == 'APPROVED' ||
        cleanStatus == 'DELIVERED' ||
        cleanStatus == 'QC_APPROVED' ||
        cleanStatus == 'ACTIVE') {
      baseColor = const HSLColor.fromAHSL(1.0, 142, 0.70, 0.45).toColor(); // Premium Success Green
    } else if (cleanStatus == 'IN_PROGRESS' || cleanStatus == 'PRODUCTION') {
      baseColor = const HSLColor.fromAHSL(1.0, 211, 1.0, 0.50).toColor(); // Premium Blue
    } else if (cleanStatus == 'PENDING' ||
        cleanStatus == 'CLIENT_APPROVAL_PENDING' ||
        cleanStatus == 'SUBMITTED' ||
        cleanStatus == 'QC_PENDING') {
      baseColor = const HSLColor.fromAHSL(1.0, 45, 0.93, 0.47).toColor(); // Premium Amber/Yellow
    } else if (cleanStatus == 'CANCELLED' ||
        cleanStatus == 'REJECTED' ||
        cleanStatus == 'QC_REJECTED') {
      baseColor = const HSLColor.fromAHSL(1.0, 0, 0.84, 0.60).toColor(); // Premium Error Red
    } else {
      baseColor = const HSLColor.fromAHSL(1.0, 215, 0.15, 0.50).toColor(); // Slate Grey
    }

    final displayText = status.replaceAll('_', ' ');

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            displayText,
            style: TextStyle(
              color: baseColor,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
