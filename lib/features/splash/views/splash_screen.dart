import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/core/widgets/bgcircles.dart';
import 'package:dariziflow_app/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
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
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/splash.svg',
                        width: 200.0,
                        height: 200.0,
                      ),
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

              // PAGE 2
              SafeArea(
                child: Form(
                  autovalidateMode: AutovalidateMode.always,
                  canPop: true,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          backgroundBlendMode: BlendMode.color,
                        ),
                      ),
                      const Spacer(),
                      Container(),
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
