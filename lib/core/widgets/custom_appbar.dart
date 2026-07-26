import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final bool isTransparent;
  final String? userAvatarUrl;
  final bool isDashboard;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.centerTitle = false,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPress,
    this.isTransparent = true,
    this.userAvatarUrl,
    this.isDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      backgroundColor: isTransparent ? Colors.transparent : colors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading ?? _buildLeading(context, colors),
      title: _buildTitle(theme, colors),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: colors.primary.withValues(
            alpha: 0.3,
          ), // Primary highlight line
          height: 1.0,
        ),
      ),
      systemOverlayStyle:
          theme.appBarTheme.systemOverlayStyle ??
          (theme.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark),
    );
  }

  Widget? _buildLeading(BuildContext context, ColorScheme colors) {
    if (isDashboard) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed("/profile"),
          child: _buildAvatar(colors),
        ),
      );
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18, color: colors.onSurface),
        onPressed: onBackPress ?? () => Get.back(),
      );
    }
    return null;
  }

  Widget _buildAvatar(ColorScheme colors) {
    final bool hasImage = userAvatarUrl != null && userAvatarUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 20,
      backgroundColor: colors.onSurface.withValues(alpha: 0.1),
      backgroundImage: hasImage ? CachedNetworkImageProvider(userAvatarUrl!) : null,
      child: !hasImage
          ? Icon(Icons.person, size: 20, color: colors.primary)
          : null,
    );
  }

  Widget _buildTitle(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: const Offset(-5, 0),
          child: Text(
            title ?? "",
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: isDashboard ? 14 : 16,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Transform.translate(
            offset: const Offset(-5, 0),
            child: Text(
              subtitle!,
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
