import 'package:cached_network_image/cached_network_image.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/date_formatter.dart';
import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/features/Messages/widgets/typing_indicator_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatTile extends StatelessWidget {
  final ChatRoomModel room;
  final String currentUserId;
  final VoidCallback onTap;
  final bool isTyping;

  const ChatTile({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final other = room.otherParticipant(currentUserId);
    final displayName = room.displayName(currentUserId);
    final avatarUrl = other?.avatar ?? '';
    final lastMsg = room.lastMessage;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            _buildAvatar(avatarUrl, displayName, other?.id ?? '', isDark),
            const SizedBox(width: 14),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Name + Timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark ? Colors.white : colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(room.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Row: Last message preview with sender prefix + check
                  if (lastMsg != null)
                    Row(
                      children: [
                        // Double check for sent messages
                        if (_isMySentMessage(lastMsg) && !isTyping) ...[
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF53BDEB)
                                : const Color(0xFF53BDEB),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: isTyping 
                            ? Row(
                                children: [
                                  TypingIndicatorBubble(
                                    isDark: isDark,
                                    isSmall: true,
                                  ),
                                ],
                              )
                            : Text(
                                _buildPreview(lastMsg),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.55)
                                      : colors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, String name, String otherId, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (otherId.isNotEmpty) {
          Get.toNamed('/profile-view', arguments: {
            'userId': otherId,
            'fallbackName': name,
            'fallbackAvatar': url,
          });
        }
      },
      child: Hero(
        tag: 'avatar_$otherId',
        child: CircleAvatar(
          radius: 28,
          backgroundColor: isDark
              ? AppColors.primaryGreen.withValues(alpha: 0.2)
              : AppColors.primaryGreen.withValues(alpha: 0.12),
          child: url.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 28,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.primaryGreen,
                ),
        ),
      ),
    );
  }

  String _buildPreview(dynamic lastMsg) {
    if (lastMsg == null) return '';

    String senderPrefix = '';
    if (lastMsg.sender.id == currentUserId) {
      senderPrefix = 'You: ';
    }

    if (lastMsg.media.isNotEmpty && lastMsg.text.isEmpty) {
      return '$senderPrefix📎 Media';
    }
    if (lastMsg.media.isNotEmpty) return '$senderPrefix📎 ${lastMsg.text}';
    return '$senderPrefix${lastMsg.text}';
  }

  bool _isMySentMessage(dynamic lastMsg) {
    if (lastMsg == null) return false;
    return lastMsg.sender.id == currentUserId;
  }

  String _formatTimestamp(DateTime dt) {
    return formatChatListTimestamp(dt);
  }
}
