import 'package:flutter/material.dart';

class StepProgressIndicator extends StatefulWidget {
  final List<String> stepNames;
  final int currentStep;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeLineColor;
  final Color inactiveLineColor;

  const StepProgressIndicator({
    super.key,
    required this.stepNames,
    required this.currentStep,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeLineColor,
    required this.inactiveLineColor,
  });

  @override
  State<StepProgressIndicator> createState() => _StepProgressIndicatorState();
}

class _StepProgressIndicatorState extends State<StepProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stepNames.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int n = widget.stepNames.length;

        final double dotSize = 15;
        final double trackHeight = 5;

        final double usableWidth =
            width - dotSize; // Leave half dot size on each edge
        final double stepDistance = n > 1 ? usableWidth / (n - 1) : 0;

        // Clamp progress
        final double p = widget.progress.clamp(0.0, 1.0);
        final double activeWidth = p * usableWidth;

        // Find the "nearest" step to the current progress
        int nearestStepIndex = 0;
        double minDistance = double.infinity;
        for (int i = 0; i < n; i++) {
          double stepPos = n > 1 ? i / (n - 1) : 0.5;
          double dist = (p - stepPos).abs();
          if (dist < minDistance) {
            minDistance = dist;
            nearestStepIndex = i;
          }
        }

        // Tooltip positioned exactly on the progress value
        final double progressTipX = dotSize / 2 + activeWidth;
        final double bubbleWidth = 100.0;
        
        double bubbleLeft = progressTipX - (bubbleWidth / 2);
        bubbleLeft = bubbleLeft.clamp(0.0, width - bubbleWidth);

        final double relativeTipX = progressTipX - bubbleLeft;

        final Widget tooltipWidget = Positioned(
          bottom: 80 - 40 + dotSize / 2 + 4,
          left: bubbleLeft,
          width: bubbleWidth,
          child: CustomPaint(
            painter: _BubblePainter(
              color: widget.activeColor,
              tailCenterX: relativeTipX,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 6,
                bottom: 12,
              ),
              child: Text(
                "${(p * 100).round()}% Completed",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );

        return SizedBox(
          width: double.infinity,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Inactive Background Track
              Positioned(
                left: dotSize / 2,
                right: dotSize / 2,
                top: 40 - (trackHeight / 2),
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: widget.inactiveLineColor,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),
              ),

              // Active Glow Track
              Positioned(
                left: dotSize / 2,
                top: 40 - (trackHeight / 2),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      height: trackHeight,
                      width: activeWidth,
                      decoration: BoxDecoration(
                        color: widget.activeLineColor,
                        borderRadius: BorderRadius.circular(trackHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.activeLineColor.withValues(
                              alpha: _glowAnimation.value,
                            ),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots
              ...List.generate(n, (index) {
                final double leftPos = n > 1
                    ? index * stepDistance
                    : usableWidth / 2;
                final double stepProg = n > 1 ? index / (n - 1) : 0.5;
                final bool isCompleted = p >= stepProg;
                final bool isNearest = index == nearestStepIndex;

                return Positioned(
                  left: leftPos,
                  top: 0,
                  bottom: 0,
                  width: dotSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Percentage label for dots
                      if (n <= 5 || index == 0 || index == n - 1)
                        Positioned(
                          top: 40 + dotSize,
                          child: Text(
                            "${(stepProg * 100).round()}%",
                            style: TextStyle(
                              fontSize: 10,
                              color: isCompleted
                                  ? widget.activeColor
                                  : widget.inactiveColor.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      // The Dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isNearest ? dotSize + 6 : dotSize,
                        height: isNearest ? dotSize + 6 : dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? widget.activeColor
                              : widget.inactiveColor,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: widget.activeColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Tooltip positioned exactly on the progress value
              tooltipWidget,
            ],
          ),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double tailCenterX;

  _BubblePainter({
    required this.color,
    required this.tailCenterX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final radius = 8.0;
    final tailWidth = 10.0;
    final tailHeight = 6.0;

    // Draw rounded rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - tailHeight),
      Radius.circular(radius),
    );
    path.addRRect(rect);

    // Draw tail
    // Clamp the tail to be within the bubble boundaries so it doesn't draw outside the bubble
    final double clampedTailCenterX = tailCenterX.clamp(tailWidth / 2 + radius, size.width - tailWidth / 2 - radius);

    path.moveTo(clampedTailCenterX - tailWidth / 2, size.height - tailHeight);
    path.lineTo(clampedTailCenterX, size.height);
    path.lineTo(clampedTailCenterX + tailWidth / 2, size.height - tailHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.tailCenterX != tailCenterX;
}
