import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.onPrimary, size: 40),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
