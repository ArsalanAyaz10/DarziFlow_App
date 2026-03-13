import 'package:dariziflow_app/features/auth/controllers/emailVerify_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EmailverifyScreen extends GetView<EmailverifyController> {
  const EmailverifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildBody(
              context,
              controller.status.value,
              controller.message.value,
              colors,
              isDark,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VerifyStatus status,
    String message,
    ColorScheme colors,
    bool isDark,
  ) {
    switch (status) {
      case VerifyStatus.loading:
        return _LoadingState(
          key: const ValueKey('loading'),
          colors: colors,
          isDark: isDark,
        );
      case VerifyStatus.success:
        return _SuccessState(
          key: const ValueKey('success'),
          message: message,
          colors: colors,
          isDark: isDark,
          onContinue: controller.goToLogin,
        );
      case VerifyStatus.error:
        return _ErrorState(
          key: const ValueKey('error'),
          message: message,
          colors: colors,
          isDark: isDark,
          onRetry: controller.retryWithEmail,
        );
    }
  }
}

// ──────────────────── Loading State ────────────────────

class _LoadingState extends StatelessWidget {
  final ColorScheme colors;
  final bool isDark;

  const _LoadingState({
    super.key,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoRow(colors: colors),
            const SizedBox(height: 48),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Verifying your email…',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while we confirm your email address.',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.55),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Success State ────────────────────

class _SuccessState extends StatelessWidget {
  final String message;
  final ColorScheme colors;
  final bool isDark;
  final VoidCallback onContinue;

  const _SuccessState({
    super.key,
    required this.message,
    required this.colors,
    required this.isDark,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoRow(colors: colors),
            const SizedBox(height: 48),

            // Success Icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Email Verified!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              message.isNotEmpty
                  ? message
                  : 'Your email has been successfully verified. You can now log in to your DarziFlow account.',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.6),
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Divider chip
            _StatusChip(
              label: 'Verification complete',
              icon: Icons.verified_rounded,
              color: colors.primary,
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onContinue,
                child: const Text(
                  'Continue to Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Error State ────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final ColorScheme colors;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorState({
    super.key,
    required this.message,
    required this.colors,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFE53935);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoRow(colors: colors),
            const SizedBox(height: 48),

            // Error Icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                size: 52,
                color: errorColor,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Verification Failed',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              message.isNotEmpty
                  ? message
                  : 'Something went wrong while verifying your email. The link may have expired or already been used.',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.6),
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            _StatusChip(
              label: 'Link expired or invalid',
              icon: Icons.link_off_rounded,
              color: errorColor,
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            // Back to login
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onRetry,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Request a new verification email from the login page.',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Shared Widgets ────────────────────

class _LogoRow extends StatelessWidget {
  final ColorScheme colors;

  const _LogoRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/images/Layer.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'DarziFlow',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
