import 'package:flutter/material.dart';

class VoiceRecorderUi extends StatefulWidget {
  final Duration duration;
  final bool isDark;

  const VoiceRecorderUi({
    super.key,
    required this.duration,
    required this.isDark,
  });

  @override
  State<VoiceRecorderUi> createState() => _VoiceRecorderUiState();
}

class _VoiceRecorderUiState extends State<VoiceRecorderUi> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FadeTransition(
          opacity: _controller,
          child: const Icon(Icons.mic, color: Colors.red, size: 24),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(widget.duration),
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_left, color: Colors.grey[500], size: 20),
              Flexible(
                child: Text(
                  'Slide to cancel',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
