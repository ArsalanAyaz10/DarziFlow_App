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
    final color = _getEventColor(event.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimelineIndicator(theme, color, isLast, isFirst),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bubble Tail
                  Positioned(
                    left: -8,
                    top: 14, // Roughly center of dot
                    child: CustomPaint(
                      painter: _BubbleTailPainter(
                        color: theme.colorScheme.surface,
                        borderColor: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      size: const Size(8, 12),
                    ),
                  ),
                  // The Bubble
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
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
                                fontSize: 10,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 12,
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

  Widget _buildTimelineIndicator(ThemeData theme, Color color, bool isLast, bool isFirst) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          Container(
            width: 1.5,
            height: 16,
            color: isFirst ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.1),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 1.5,
              color: isLast ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.1),
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
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    // Path remains open on the right side to blend with the container
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Join line to hide the right border of the triangle
    final joinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width, 0.5),
      Offset(size.width, size.height - 0.5),
      joinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
