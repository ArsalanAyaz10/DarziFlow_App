import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Messages/controllers/chat_list_controller.dart';
import 'package:dariziflow_app/features/Messages/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatListController _controller = Get.find<ChatListController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Messages',
        centerTitle: false,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                prefixIcon:
                    Icon(Icons.search, color: colors.onSurfaceVariant),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.primaryGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_controller.currentUserId.value.isEmpty || _controller.isLoading.value) {
                return _buildShimmer(colors);
              }

              if (_controller.errorMessage.value.isNotEmpty) {
                return _buildError(_controller.errorMessage.value);
              }

              if (_controller.isSearching.value && _controller.searchQuery.value.trim().isNotEmpty) {
                return _buildSearchResults(theme, colors);
              }

              final rooms = _controller.rooms;

              if (rooms.isEmpty) {
                return _buildEmptyRecentChats(theme, colors);
              }

              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: _controller.fetchRooms,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  itemBuilder: (_, index) {
                    final room = rooms[index];
                    return ChatTile(
                      room: room,
                      currentUserId: _controller.currentUserId.value,
                      onTap: () =>
                          Get.toNamed(Routes.chatRoom, arguments: room),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildShimmer(ColorScheme colors) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) => Shimmer(
        duration: const Duration(seconds: 1),
        color: colors.surfaceContainerHighest,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 14,
                        width: 120,
                        color: colors.surface),
                    const SizedBox(height: 6),
                    Container(
                        height: 12,
                        width: 200,
                        color: colors.surface),
                  ],
                ),
              ),            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRecentChats(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a user to start chatting.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colors) {
    final results = _controller.searchResults;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, index) {
        final user = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
            child: user.avatarUrl.isEmpty ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?') : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.formattedRole),
          trailing: IconButton(
            icon: const Icon(Icons.chat),
            color: AppColors.primaryGreen,
            onPressed: () => _controller.startNewChat(user.id),
          ),
          onTap: () => _controller.startNewChat(user.id),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.fetchRooms,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
