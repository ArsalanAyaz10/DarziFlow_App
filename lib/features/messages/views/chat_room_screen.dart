import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/date_formatter.dart';
import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/features/Messages/controllers/chat_controller.dart';
import 'package:dariziflow_app/features/Messages/widgets/media_preview_bar.dart';
import 'package:dariziflow_app/features/Messages/widgets/message_bubble.dart';
import 'dart:async';
import 'package:dariziflow_app/features/Messages/widgets/reply_preview_banner.dart';
import 'package:dariziflow_app/features/Messages/widgets/typing_indicator_bubble.dart';
import 'package:dariziflow_app/features/Messages/widgets/voice_recorder_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'dart:developer' as dev;

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatController _controller = Get.find<ChatController>();
  final TextEditingController _textController = TextEditingController();
  final RxString _inputText = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();

  // Voice Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  final RxBool _isRecording = false.obs;
  final Rx<Duration> _recordingDuration = Duration.zero.obs;
  Timer? _recordTimer;
  String? _audioPath;

  // ─── WhatsApp-style dark-mode-aware colors ──────────────────────────────
  static const _waChatBgDark = Color(0xFF0B141A);
  static const _waChatBgLight = Color(0xFFECE5DD);
  static const _waHeaderDark = Color(0xFF1F2C34);
  static const _waHeaderLight = Color(0xFF075E54);
  static const _waInputBgDark = Color(0xFF1F2C34);
  static const _waInputBgLight = Color(0xFFFFFFFF);
  static const _waInputFieldDark = Color(0xFF2A3942);
  static const _waInputFieldLight = Color(0xFFF0F0F0);

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  // ── Room info helpers ──────────────────────────────────────────────────────

  ChatRoomModel get _room => _controller.room;

  String get _otherName {
    final other = _room.otherParticipant(_controller.currentUserId.value);
    return other?.name ?? _room.displayName(_controller.currentUserId.value);
  }

  String get _otherRole {
    final other = _room.otherParticipant(_controller.currentUserId.value);
    return other?.formattedRole ?? '';
  }

  String get _otherAvatar {
    final other = _room.otherParticipant(_controller.currentUserId.value);
    return other?.avatar ?? '';
  }

  // ── Media Picker ──────────────────────────────────────────────────────────

  Future<void> _showAttachmentSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? _waInputBgDark : _waInputBgLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  color: AppColors.primaryGreen),
              title: const Text('Photo from Gallery'),
              onTap: () async {
                Get.back();
                final XFile? picked = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 75,
                );
                if (picked != null) {
                  _controller.setPendingMedia(File(picked.path), 'image');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primaryGreen),
              title: const Text('Camera'),
              onTap: () async {
                Get.back();
                final XFile? picked = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 75,
                );
                if (picked != null) {
                  _controller.setPendingMedia(File(picked.path), 'image');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_outlined,
                  color: AppColors.primaryGreen),
              title: const Text('Document'),
              onTap: () async {
                Get.back();
                final FilePickerResult? result =
                    await FilePicker.pickFiles(
                  type: FileType.any,
                  allowMultiple: false,
                );
                if (result != null && result.files.single.path != null) {
                  _controller.setPendingMedia(
                    File(result.files.single.path!),
                    'document',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text;
    _textController.clear();
    _inputText.value = '';
    _controller.sendMessage(text);
  }

  Future<void> _startRecording() async {
    try {
      dev.log('[Voice] Requesting to start recording...');
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        dev.log('[Voice] Starting recording at path: $_audioPath');
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );
        _isRecording.value = true;
        _recordingDuration.value = Duration.zero;
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration.value = Duration(seconds: timer.tick);
        });
      } else {
        Get.snackbar('Permission Denied', 'Microphone permission is required.');
      }
    } catch (e) {
      dev.log('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    dev.log('[Voice] _stopRecording called. isRecording: ${_isRecording.value}');
    if (!_isRecording.value) return;
    _recordTimer?.cancel();
    final path = await _audioRecorder.stop();
    _isRecording.value = false;
    dev.log('[Voice] Recording stopped. Result path: $path');
    if (path != null) {
      _controller.setPendingMedia(File(path), 'audio');
      _sendMessage();
    } else {
      dev.log('[Voice] Path was null after stopping recording!');
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording.value) return;
    _recordTimer?.cancel();
    await _audioRecorder.stop();
    _isRecording.value = false;
    if (_audioPath != null) {
      final file = File(_audioPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _waChatBgDark : _waChatBgLight,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // ── Message List ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Background Logo
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.05,
                      child: SvgPicture.asset(
                        isDark ? 'assets/images/Darksplash.svg' : 'assets/images/Lightsplash.svg',
                        width: 250,
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (_controller.isLoading.value ||
                      _controller.currentUserId.value.isEmpty) {
                    return _buildShimmer(isDark);
                  }
                  return _buildMessageList(isDark);
                }),

                // Load more indicator at top
                Obx(() {
                  if (!_controller.isLoadingMore.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      color: AppColors.primaryGreen,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      minHeight: 2,
                    ),
                  );
                }),

                // Scroll-to-bottom FAB
                Obx(() {
                  if (!_controller.showScrollToBottom.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? _waInputBgDark
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey[700],
                        ),
                        onPressed: _controller.scrollToBottom,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Typing Indicator removed from here (moved to AppBar)

          // ── Reply Preview ──────────────────────────────────────────────
          Obx(() {
            final reply = _controller.replyToMessage.value;
            if (reply == null) return const SizedBox.shrink();
            return ReplyPreviewBanner(
              message: reply,
              onDismiss: _controller.clearReply,
            );
          }),

          // ── Media Preview ──────────────────────────────────────────────
          Obx(() {
            final file = _controller.pendingMediaFile.value;
            if (file == null || _controller.pendingMediaType.value == 'audio') {
              return const SizedBox.shrink();
            }
            return MediaPreviewBar(
              file: file,
              mediaType: _controller.pendingMediaType.value,
              onRemove: _controller.clearPendingMedia,
            );
          }),

          // ── Input Bar ─────────────────────────────────────────────────
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? _waHeaderDark : _waHeaderLight,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: 22,
          color: isDark ? Colors.white : Colors.white,
        ),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        if (_controller.currentUserId.value.isEmpty) {
          return const SizedBox.shrink();
        }
        final avatarUrl = _otherAvatar;
        final otherParticipant = _room.otherParticipant(_controller.currentUserId.value);
        final otherId = otherParticipant?.id ?? '';
        
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                if (otherId.isNotEmpty) {
                  Get.toNamed('/profile-view', arguments: {
                    'userId': otherId,
                    'fallbackName': _otherName,
                    'fallbackAvatar': avatarUrl,
                  });
                }
              },
              child: Hero(
                tag: 'avatar_$otherId',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_otherRole.isNotEmpty)
                    Text(
                      _otherRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            Get.snackbar(
              'Coming Soon',
              'Voice call is a feature for Cohort 2 / next phase!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primaryGreen,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(bool isDark) {
    return Obx(() {
      final msgs = _controller.messages;
      if (msgs.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A2730)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No messages yet. Say hello! 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        );
      }

      // Build items list with date dividers
      final items = _buildItemsWithDateDividers(msgs);

      return ListView.builder(
        controller: _controller.scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: items.length + 1,
        itemBuilder: (_, index) {
          if (index == items.length) {
            return Obx(() {
              if (_controller.typingUser.value.isNotEmpty) {
                return TypingIndicatorBubble(isDark: isDark);
              }
              return const SizedBox.shrink();
            });
          }
          final item = items[index];
          if (item is _DateDivider) {
            return _buildDateDivider(item.label, isDark);
          }
          final entry = item as _MessageEntry;
          return MessageBubble(
            message: entry.message,
            isMe: entry.isMe,
            isFirstInGroup: entry.isFirstInGroup,
            onSwipeReply: () => _controller.setReplyTo(entry.message),
            onTap: entry.message.isPending 
                ? () => _controller.resendMessage(entry.message) 
                : null,
          );
        },
      );
    });
  }

  /// Groups messages by date and inserts divider markers
  List<Object> _buildItemsWithDateDividers(List<MessageModel> msgs) {
    final items = <Object>[];
    String? lastDateLabel;

    for (int i = 0; i < msgs.length; i++) {
      final msg = msgs[i];
      final dateLabel = formatChatDate(msg.createdAt);

      // Insert date divider if this is a new date
      if (dateLabel != lastDateLabel) {
        items.add(_DateDivider(dateLabel));
        lastDateLabel = dateLabel;
      }

      // Determine if this is the first message in a sender group
      final isFirstInGroup = i == 0 ||
          msgs[i - 1].sender.id != msg.sender.id ||
          formatChatDate(msgs[i - 1].createdAt) != dateLabel;

      final isMe = msg.sender.id == _controller.currentUserId.value;
      items.add(_MessageEntry(
        message: msg,
        isMe: isMe,
        isFirstInGroup: isFirstInGroup,
      ));
    }

    return items;
  }

  Widget _buildDateDivider(String label, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2730)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF667781),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
      color: isDark ? _waInputBgDark : _waInputBgLight,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field with embedded icons
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? _waInputFieldDark : _waInputFieldLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text field or Voice Recorder UI
                    Expanded(
                      child: Obx(() => _isRecording.value 
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
                            child: VoiceRecorderUi(
                              duration: _recordingDuration.value,
                              isDark: isDark,
                            ),
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                              onChanged: (val) {
                                _inputText.value = val;
                                _controller.onTextChanged(val);
                              },
                              decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.grey[500],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 16, right: 4, top: 12, bottom: 12),
                              ),
                            ),
                          ),
                      ),
                    ),

                    // Attachment icon
                    Obx(() => _controller.isSendingMedia.value
                        ? SizedBox(
                            height: 48,
                            width: 44,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 48,
                            width: 44,
                            child: Center(
                              child: GestureDetector(
                                onTap: _showAttachmentSheet,
                                child: Icon(
                                  Icons.attach_file_rounded,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.grey[600],
                                  size: 22,
                                ),
                              ),
                            ),
                          )),

                    // Camera icon
                    SizedBox(
                      height: 48,
                      width: 44,
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? picked =
                                await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 75,
                            );
                            if (picked != null) {
                              _controller.setPendingMedia(
                                  File(picked.path), 'image');
                            }
                          },
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.grey[600],
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4), // extra right spacing
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Send / Mic button
            Obx(() {
              final hasText = _inputText.value.trim().isNotEmpty;
              final hasMedia = _controller.pendingMediaFile.value != null;
              final canSend = hasText || hasMedia;

              return GestureDetector(
                onTap: canSend 
                    ? _sendMessage 
                    : () {
                        Get.snackbar(
                          'Hold to record',
                          'Press and hold to record a voice message.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primaryGreen,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                        );
                      },
                onLongPressStart: canSend ? null : (_) => _startRecording(),
                onLongPressEnd: canSend ? null : (_) => _stopRecording(),
                onHorizontalDragUpdate: canSend ? null : (details) {
                  if (details.primaryDelta! < -5) {
                    _cancelRecording();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                  ),
                  child: Center(
                    child: Icon(
                      canSend ? Icons.send_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final shimmerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final baseColor = isDark
        ? const Color(0xFF1A2730)
        : Colors.grey[200]!;

    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      itemBuilder: (_, index) {
        final isRight = index % 3 == 0;
        return Align(
          alignment:
              isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer(
            duration: const Duration(seconds: 1),
            color: shimmerColor,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: isRight ? 200 : 240,
              height: 44,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Internal data classes for date divider grouping ─────────────────────────

class _DateDivider {
  final String label;
  const _DateDivider(this.label);
}

class _MessageEntry {
  final MessageModel message;
  final bool isMe;
  final bool isFirstInGroup;
  const _MessageEntry({
    required this.message,
    required this.isMe,
    required this.isFirstInGroup,
  });
}
