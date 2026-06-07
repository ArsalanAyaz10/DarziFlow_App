import 'package:cached_network_image/cached_network_image.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/date_formatter.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onSwipeReply;
  final bool isFirstInGroup;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onSwipeReply,
    this.isFirstInGroup = false,
  });

  // ─── WhatsApp-style dark-mode-aware colors ──────────────────────────────
  static const _waSentBubbleDark = Color(0xFF005C4B);
  static const _waReceivedBubbleDark = Color(0xFF1F2C34);
  static const _waSentBubbleLight = Color(0xFFD9FDD3);
  static const _waReceivedBubbleLight = Color(0xFFFFFFFF);

  Color _bubbleColor(Brightness brightness) {
    if (isMe) {
      return brightness == Brightness.dark
          ? _waSentBubbleDark
          : _waSentBubbleLight;
    }
    return brightness == Brightness.dark
        ? _waReceivedBubbleDark
        : _waReceivedBubbleLight;
  }

  Color _textColor(Brightness brightness) {
    if (brightness == Brightness.dark) return Colors.white;
    return isMe ? const Color(0xFF111B21) : const Color(0xFF111B21);
  }

  Color _metaColor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return isMe
          ? Colors.white.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.5);
    }
    return isMe
        ? const Color(0xFF667781)
        : const Color(0xFF667781);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bubbleColor = _bubbleColor(brightness);
    final textCol = _textColor(brightness);
    final metaCol = _metaColor(brightness);

    // Tail radius: sharp corner on the tail side for first message in group
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(!isMe && isFirstInGroup ? 0 : 8),
      topRight: Radius.circular(isMe && isFirstInGroup ? 0 : 8),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          onSwipeReply();
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: isFirstInGroup ? 12 : 2,
            bottom: 2,
            left: isMe ? 72 : 12,
            right: isMe ? 12 : 72,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name for other's messages (first in group only)
              if (!isMe && isFirstInGroup)
                _buildSenderHeader(brightness),

              // Bubble
              Container(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply-to preview
                    if (message.replyTo != null)
                      _buildReplyBanner(message.replyTo!, brightness),

                    // Media
                    if (message.media.isNotEmpty)
                      _buildMedia(message.media.first),

                    // Text + inline timestamp
                    if (message.text.isNotEmpty)
                      _buildTextWithMeta(textCol, metaCol, brightness)
                    else
                      _buildMetaOnly(metaCol, brightness),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// WhatsApp-style inline timestamp at the end of the last line of text
  Widget _buildTextWithMeta(
      Color textCol, Color metaCol, Brightness brightness) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          message.text,
          style: TextStyle(
            color: textCol,
            fontSize: 14.5,
            height: 1.35,
          ),
        ),
        // Invisible spacer so the meta doesn't touch text
        const SizedBox(width: 8),
        // Timestamp + check marks
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatChatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: metaCol,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: brightness == Brightness.dark
                      ? const Color(0xFF53BDEB)
                      : const Color(0xFF53BDEB),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// For media-only messages with no text
  Widget _buildMetaOnly(Color metaCol, Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          formatChatTime(message.createdAt),
          style: TextStyle(fontSize: 11, color: metaCol),
        ),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(
            Icons.done_all,
            size: 16,
            color: brightness == Brightness.dark
                ? const Color(0xFF53BDEB)
                : const Color(0xFF53BDEB),
          ),
        ],
      ],
    );
  }

  Widget _buildSenderHeader(Brightness brightness) {
    final senderColor = _senderNameColor(message.sender.name);
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 2),
      child: Text(
        message.sender.name,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: senderColor,
        ),
      ),
    );
  }

  Widget _buildReplyBanner(
      ReplyToModel replyTo, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: _senderNameColor(replyTo.senderName),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyTo.senderName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _senderNameColor(replyTo.senderName),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            replyTo.text.isNotEmpty ? replyTo.text : '📎 Media',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : const Color(0xFF667781),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(MediaItemModel media) {
    if (media.type == 'image') {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: const BoxConstraints(maxWidth: 260, maxHeight: 240),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: media.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 120,
              child:
                  Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          ),
        ),
      );
    }
    // Document / video fallback
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            media.type == 'video'
                ? Icons.videocam_rounded
                : Icons.insert_drive_file_rounded,
            size: 20,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Text(
            media.type == 'video' ? 'Video' : 'Document',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Assigns a consistent WhatsApp-style color to each sender name
  Color _senderNameColor(String name) {
    final colors = [
      const Color(0xFFE17076), // red
      const Color(0xFF7BC862), // green
      const Color(0xFF6EC9CB), // teal
      const Color(0xFF65AADD), // blue
      const Color(0xFFEE7AAE), // pink
      const Color(0xFFE4AE4F), // amber
      const Color(0xFF9B86E3), // purple
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }
}
