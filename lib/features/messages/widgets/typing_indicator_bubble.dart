import 'package:flutter/material.dart';

class TypingIndicatorBubble extends StatefulWidget {
  final bool isDark;
  final bool isSmall;
  const TypingIndicatorBubble({super.key, required this.isDark, this.isSmall = false});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: widget.isSmall 
            ? EdgeInsets.zero 
            : const EdgeInsets.only(left: 12, bottom: 8, top: 4),
        padding: widget.isSmall 
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1F2C34) : const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
            bottomLeft: Radius.circular(0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            SizedBox(width: widget.isSmall ? 3 : 4),
            _buildDot(1),
            SizedBox(width: widget.isSmall ? 3 : 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Simple wave logic
        final offset = index * 0.2;
        var progress = (_controller.value - offset) % 1.0;
        if (progress < 0) progress += 1.0;

        double yOffset = 0;
        if (progress < 0.4) {
          // Bounce up and down
          yOffset = -4 * (0.2 - (progress - 0.2).abs()) / 0.2;
        }

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.isDark 
                  ? Colors.white.withValues(alpha: 0.5) 
                  : Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
