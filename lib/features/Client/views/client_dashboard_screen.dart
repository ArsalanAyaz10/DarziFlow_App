import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Client/controllers/client_dashboard_controller.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/stat_tile.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/recent_activity_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dariziflow_app/features/Client/widgets/client_dashboard_shimmer.dart';
import 'dart:math' as math;

class ClientDashboardScreen extends GetView<ClientDashboardController> {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.atelierBackgroundDark
        : AppColors.atelierBackgroundLight;
    final cardColor = isDark
        ? AppColors.atelierSurfaceDark
        : AppColors.atelierSurfaceLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Obx(
          () => CustomAppBar(
            isDashboard: true,
            isTransparent: true,
            userAvatarUrl: controller.userAvatar.value,
            title: controller.userName.value,
            subtitle: "CLIENT",
            showBackButton: false,
            actions: [
              IconButton(
                onPressed: () => Get.toNamed('/notification-inbox'),
                icon: Obx(() {
                  final unreadCount =
                      Get.find<NotificationController>().unreadCount.value;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                    ),
                    backgroundColor: AppColors.error,
                    child: Icon(
                      Icons.notifications_none,
                      color: colors.onSurface,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.orders.isEmpty &&
            controller.carouselItems.isEmpty) {
          return const ClientDashboardShimmer();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Welcome back, ",
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 1),
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          controller.userName.value,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Your style, our craft. Tracking your masterpieces.",
                      style: TextStyle(
                        color: AppColors.atelierSilkGreen.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(color: colors.outlineVariant, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StatTile(
                      label: "Total Orders",
                      value: controller.totalOrdersCount.value.toString(),
                      subText: "Orders Placed",
                      color: colors.primary,
                      icon: Icons.shopping_bag_outlined,
                      showTrend: false,
                    ),
                    const SizedBox(width: 10),
                    StatTile(
                      label: "Active Orders",
                      value: controller.activeOrdersCount.value.toString(),
                      subText: "In progress now",
                      color: AppColors.atelierSilkGreen,
                      icon: Icons.pending_actions,
                      showTrend: false,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(color: colors.outlineVariant, height: 1),
                const SizedBox(height: 10),

                if (controller.orders.isNotEmpty) ...[
                  Text(
                    "ORDER PROGRESS",
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildLatestOrderCard(cardColor, colors, isDark),

                  const SizedBox(height: 10),
                  Divider(color: colors.outlineVariant, height: 1),
                  const SizedBox(height: 10),
                ],

                if (controller.carouselItems.isNotEmpty) ...[
                  Text(
                    "EXPLORE COLLECTIONS",
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCarousel(colors),
                  const SizedBox(height: 10),
                  Divider(color: colors.outlineVariant, height: 1),
                  const SizedBox(height: 10),
                ],

                RecentActivityPanel(
                  activities: controller.mappedActivities,
                  onViewAll: controller.navigateToFullActivityList,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onPressed: () => Get.snackbar('Coming Soon', 'This feature is due in next phase'),
        backgroundColor: AppColors.atelierSilkGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildLatestOrderCard(
    Color cardColor,
    ColorScheme colors,
    bool isDark,
  ) {
    final order = controller.orders.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.atelierSilkGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.atelierSilkGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "LATEST ORDER",
                      style: const TextStyle(
                        color: AppColors.atelierSilkGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            width: 160,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: order.progress / 100),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(160, 80),
                      painter: SemiCircleProgressPainter(
                        progress: value,
                        color: AppColors.atelierSilkGreen,
                        backgroundColor: colors.onSurface.withValues(
                          alpha: 0.05,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      child: Column(
                        children: [
                          Text(
                            "${(value * 100).toInt()}%",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            order.orderName,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order.displayOrderId,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: order.progress == 100 
                  ? AppColors.atelierSilkGreen.withValues(alpha: 0.1) 
                  : colors.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  order.progress == 100 ? Icons.check_circle : Icons.check_circle_outline,
                  color: order.progress == 100 
                      ? AppColors.atelierSilkGreen 
                      : colors.onSurface.withValues(alpha: 0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  order.progress == 100 ? "COMPLETED" : order.overallStatus,
                  style: TextStyle(
                    color: order.progress == 100 
                        ? AppColors.atelierSilkGreen 
                        : colors.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(ColorScheme colors) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160.0,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        initialPage: 0,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: controller.carouselItems.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: item.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: colors.primaryContainer.withValues(alpha: 0.1),
              ),
              child: item.imageUrl.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: colors.primary.withValues(alpha: 0.3),
                        size: 40,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.description != null)
                            Text(
                              item.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
            );
          },
        );
      }).toList(),
    );
  }
}

class SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  SemiCircleProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
