import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool isMe;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    required this.isMe,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Set the URL source but do not play automatically
    _audioPlayer.setSourceUrl(widget.url);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color controlColor = isDark 
        ? Colors.white 
        : (widget.isMe ? Colors.black87 : Colors.black87);
        
    final Color activeTrackColor = widget.isMe 
        ? (isDark ? const Color(0xFF53BDEB) : AppColors.primaryGreen) 
        : (isDark ? AppColors.primaryGreen : AppColors.primaryGreen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      constraints: const BoxConstraints(maxWidth: 240),
      child: Row(
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play(UrlSource(widget.url));
              }
            },
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: controlColor,
              size: 36,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Slider and Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    activeTrackColor: activeTrackColor,
                    inactiveTrackColor: controlColor.withValues(alpha: 0.3),
                    thumbColor: activeTrackColor,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 100.0,
                    value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 100.0),
                    onChanged: (value) {
                      final position = Duration(milliseconds: value.toInt());
                      _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _formatDuration(_position.inMilliseconds > 0 ? _position : _duration),
                    style: TextStyle(
                      fontSize: 11,
                      color: controlColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
