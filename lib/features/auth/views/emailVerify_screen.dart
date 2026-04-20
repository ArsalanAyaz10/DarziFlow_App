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
          final status = controller.status.value;
          final message = controller.message.value;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Center(
              key: ValueKey(status),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                    ),
                    const SizedBox(height: 48),

                    if (status == VerifyStatus.loading)
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
                      )
                    else
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
                      status == VerifyStatus.loading
                          ? 'Verifying your email…'
                          : 'Email Verified!',
                      style: TextStyle(
                        fontSize: status == VerifyStatus.loading ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      status == VerifyStatus.loading
                          ? 'Please wait while we confirm your email address.'
                          : message.isNotEmpty
                              ? message
                              : 'Your email has been successfully verified. You can now log in to your DarziFlow account.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurface.withValues(alpha: 0.55),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (status == VerifyStatus.success) ...[
                      const SizedBox(height: 48),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Verification complete',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      //Button
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
                          onPressed: controller.goToLogin,
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
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
