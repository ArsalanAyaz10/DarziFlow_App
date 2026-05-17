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
        
        final double dotSize = 16.0;
        final double trackHeight = 6.0;
        
        final double usableWidth = width - dotSize; // Leave half dot size on each edge
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
                            color: widget.activeLineColor.withValues(alpha: _glowAnimation.value),
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
                final double leftPos = n > 1 ? index * stepDistance : usableWidth / 2;
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
                      // Percentage label for all dots
                      Positioned(
                        top: 40 + dotSize,
                        child: Text(
                          "${(stepProg * 100).round()}%",
                          style: TextStyle(
                            fontSize: 10,
                            color: isCompleted ? widget.activeColor : widget.inactiveColor.withValues(alpha: 0.6),
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
                          color: isCompleted ? widget.activeColor : widget.inactiveColor,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: widget.activeColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Tooltips for nearest step (rendered last to be on top)
              ...List.generate(n, (index) {
                final double leftPos = n > 1 ? index * stepDistance : usableWidth / 2;
                final bool isNearest = index == nearestStepIndex;
                if (!isNearest) return const SizedBox.shrink();
                
                double? left;
                double? right;
                Offset translation = Offset.zero;

                final bool isFirst = index == 0 && n > 1;
                final bool isLast = index == n - 1 && n > 1;

                if (isFirst) {
                  left = 0.0;
                } else if (isLast) {
                  right = 0.0;
                } else {
                  left = leftPos + dotSize / 2;
                  translation = const Offset(-0.5, 0.0);
                }

                return Positioned(
                  bottom: 80 - 40 + dotSize / 2 + 4,
                  left: left,
                  right: right,
                  child: FractionalTranslation(
                    translation: translation,
                    child: CustomPaint(
                      painter: _BubblePainter(
                        color: widget.activeColor,
                        isFirst: isFirst,
                        isLast: isLast,
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 12),
                        child: const Text(
                          "We're here!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black, 
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final bool isFirst;
  final bool isLast;

  _BubblePainter({
    required this.color,
    this.isFirst = false,
    this.isLast = false,
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
    double tailCenterX = size.width / 2;
    if (isFirst) {
      tailCenterX = 8.0; // Pointing to the first dot
    } else if (isLast) {
      tailCenterX = size.width - 8.0; // Pointing to the last dot
    }

    path.moveTo(tailCenterX - tailWidth / 2, size.height - tailHeight);
    path.lineTo(tailCenterX, size.height);
    path.lineTo(tailCenterX + tailWidth / 2, size.height - tailHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
