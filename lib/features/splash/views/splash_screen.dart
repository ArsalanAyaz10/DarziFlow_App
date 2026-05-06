import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/core/utils/global.dart';
import 'package:dariziflow_app/core/utils/role_router.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/data/services/notifications_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController pageController = PageController();

  final SvgAssetLoader darkSplash = const SvgAssetLoader(
    'assets/images/Darksplash.svg',
  );
  final SvgAssetLoader lightSplash = const SvgAssetLoader(
    'assets/images/Lightsplash.svg',
  );
  final SvgAssetLoader darkLayer = const SvgAssetLoader(
    'assets/images/darkLayer.svg',
  );
  final SvgAssetLoader lightLayer = const SvgAssetLoader(
    'assets/images/lightLayer.svg',
  );

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() {
    bool isOnboardingDone = box.read('onboarding') ?? false;

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted || Get.currentRoute != Routes.splash) return;

      final resetToken = box.read('reset_token');
      if (resetToken != null) {
        box.remove('reset_token');
        Get.offAllNamed('/resetpassword', arguments: resetToken);
        return;
      }

      if (isOnboardingDone) {
        final token = await AppStorage.getAccessToken();
        final rememberMe = box.read('remember_me') ?? false;
        if (token != null && rememberMe) {
          Get.find<NotificationService>().syncTokenWithBackend();
          
          Get.find<NotificationController>().fetchNotifications();
          final pendingRoute = box.read('pending_route');
          if (pendingRoute != null) {
            box.remove('pending_route');
            Get.offAllNamed(pendingRoute);
          } else {
            // No pending route — route based on stored role
            final role = await AppStorage.getUserRole();
            if (role != null) {
              RoleRouter.route(role);
            } else {
              Get.offAllNamed('/login');
            }
          }
        } else {
          Get.offAllNamed('/login');
        }
      } else {
        if (pageController.hasClients) {
          pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              if (index == 1) {}
            },
            children: [
              // Page 1:  Splash Content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture(
                          isDark ? darkSplash : lightSplash,
                          width: 150.0,
                          height: 150.0,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "PRECISION IN PRODUCTION",
                          style: TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize: 14,
                            color: colors.onSurface,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'VERSION 1.0',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontFamily: AppFonts.outfit,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // PAGE 2: Welcome Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SvgPicture(
                          isDark ? darkLayer : lightLayer,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: AppFonts.outfit,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          children: [
                            TextSpan(text: "Darzi"),
                            const TextSpan(
                              text: "Flow",
                              style: TextStyle(color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Manage your workflow with precision.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppFonts.outfit,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(flex: 3),

                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/signup');
                              box.write('onboarding', true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Get.toNamed('/login');
                              box.write('onboarding', true);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Login ",
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            fontFamily: AppFonts.outfit,
                          ),
                          children: [
                            const TextSpan(
                              text: "By continuing, you agree to our ",
                            ),
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w400,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Get.toNamed(Routes.termsOfService),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
