import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final String? label;
  final bool showLabel;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.label,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hintColor = colors.onSurfaceVariant.withValues(alpha: 0.6);
    final iconColor = colors.onSurfaceVariant.withValues(alpha: 0.8);
    final _ = colors.onSurface.withValues(alpha:0.7);

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel && label != null) ...[
            _buildLabel(label!, context),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(fontSize: 14, color: colors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              prefixIcon: Icon(icon, color: iconColor, size: 18),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                        size: 18,
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colors.onSurface.withValues(alpha: 0.7),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
