import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/Client/controllers/client_tracking_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackingEventCard extends StatelessWidget {
  final TrackingEvent event;
  final bool isLast;
  final bool isFirst;

  const TrackingEventCard({
    super.key,
    required this.event,
    required this.isLast,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getEventColor(event.type);

    final bubbleColor = theme.colorScheme.surface;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            timelineIndicator(theme, color, isLast, isFirst),
            const SizedBox(width: 5),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -8,
                    top: 12,
                    child: CustomPaint(
                      painter: _BubbleTailPainter(
                        fillColor: bubbleColor,
                        borderColor: borderColor,
                      ),
                      size: const Size(10, 15),
                    ),
                  ),
                  // Bubble
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(event.date),
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (event.description != null &&
                            event.description!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.hintColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timelineIndicator(
    ThemeData theme,
    Color color,
    bool isLast,
    bool isFirst,
  ) {
    return SizedBox(
      width: 25,
      child: Column(
        children: [
          Container(
            width: 1.5,
            height: 15,
            color: isFirst
                ? Colors.transparent
                : theme.dividerColor.withValues(alpha: 0.15),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 1.5,
              color: isLast
                  ? Colors.transparent
                  : theme.dividerColor.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(TrackingEventType type) {
    if (type == TrackingEventType.completed) return AppColors.atelierSilkGreen;
    if (type == TrackingEventType.rejected) return AppColors.error;
    return Colors.orange;
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  const _BubbleTailPainter({
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0) // top-right
      ..lineTo(0, size.height / 2) // tip
      ..lineTo(size.width, size.height) // bottom-right
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height / 2)
        ..lineTo(size.width, size.height),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 10.0,
    );

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}
