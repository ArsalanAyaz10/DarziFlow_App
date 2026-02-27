import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/core/widgets/bgcircles.dart';
import 'package:dariziflow_app/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          BackgroundCircle(top: -0.3, left: -0.2),
          BackgroundCircle(bottom: -0.3, right: -0.2),

          PageView(
            controller: pageController,
            onPageChanged: (index) {
              if (index == 1) {}
            },
            children: [
              // PAGE 1: The Splash Content
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/splash.svg',
                          width: 150.0,
                          height: 150.0,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "PRECISION IN PRODUCTION",
                          style: TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize: 14,
                            color: AppColors.black,
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
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.5, // Represents Page 1 of 2
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
                              color: AppColors.grey,
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

              // PAGE 2: Welcome/Onboarding Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // Central Icon Container
                      Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/Layer.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // App Name/Branding
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: AppFonts.outfit,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          children: const [
                            TextSpan(text: "Darzi"),
                            TextSpan(
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
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(flex: 3),

                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => Get.toNamed('/signup'),
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
                          // Login Button
                          OutlinedButton(
                            onPressed: () => Get.toNamed('/login'),
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
                      // Footer Terms
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                            fontFamily: AppFonts.outfit,
                          ),
                          children: const [
                            TextSpan(text: "By continuing, you agree to our "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w400,
                              ),
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
