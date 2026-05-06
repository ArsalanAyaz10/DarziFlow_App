import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/Cilent/controllers/client_dashboard_controller.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/stat_tile.dart';
import 'package:dariziflow_app/features/DepartmentHead/widgets/recent_activity_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class ClientDashboardScreen extends GetView<ClientDashboardController> {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.atelierBackgroundDark : AppColors.atelierBackgroundLight;
    final cardColor = isDark ? AppColors.atelierSurfaceDark : AppColors.atelierSurfaceLight;

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
                  final unreadCount = Get.find<NotificationController>().unreadCount.value;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
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
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Greeting Section
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "Your style, our craft. Tracking your masterpieces.",
                  style: TextStyle(
                    color: AppColors.atelierSilkGreen.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 10),

            _buildSummaryCards(cardColor, colors),
            
            const SizedBox(height: 10),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 10),

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

            Text(
              "PREVIOUS ORDERS",
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            _buildPreviousOrdersList(cardColor, colors),
            
            const SizedBox(height: 10),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 10),

            RecentActivityPanel(
              activities: controller.processedActivities,
              onViewAll: controller.navigateToFullActivityList,
            ),
            const SizedBox(height: 10),
          ],
        ),
      )),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSummaryCards(Color cardColor, ColorScheme colors) {
    return Row(
      children: [
        Obx(() => StatTile(
          label: "Total Orders",
          value: controller.completedOrdersCount.value.toString(),
          subText: "Orders Completed",
          color: colors.primary,
          icon: Icons.shopping_bag_outlined,
          showTrend: false,
        )),
        const SizedBox(width: 10),
        Obx(() => StatTile(
          label: "Active Orders",
          value: controller.activeOrdersCount.value.toString(),
          subText: "In progress now",
          color: AppColors.atelierSilkGreen,
          icon: Icons.pending_actions,
          showTrend: false,
        )),
      ],
    );
  }


  Widget _buildLatestOrderCard(Color cardColor, ColorScheme colors, bool isDark) {
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      style: TextStyle(
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
              tween: Tween<double>(begin: 0.0, end: 0.85),
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
                        backgroundColor: colors.onSurface.withValues(alpha: 0.05),
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
                          Text(
                            "Hand-Stitching",
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.5),
                              fontSize: 10,
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
          const SizedBox(height: 12),
          Text(
            "Navy Silk Tuxedo",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "DF-2024-0912",
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colors.onSurface.withValues(alpha: 0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  "4/5 Checkpoints Completed",
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
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

  Widget _buildPreviousOrdersList(Color cardColor, ColorScheme colors) {
    final orders = [
      {'name': 'Wool Overcoat', 'status': 'Completed', 'image': 'assets/images/navy_suit_1777995278931.png'},
      {'name': 'Linen Overcoat', 'status': 'Delivered', 'image': 'assets/images/grey_suit_1777995295110.png'},
      {'name': 'Lazy Flat Suit', 'status': 'Completed', 'image': 'assets/images/silk_gown_1777995259644.png'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(order['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  order['name']!,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (order['status'] == 'Delivered' ? Colors.blue : AppColors.atelierSilkGreen).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order['status']!,
                    style: TextStyle(
                      color: order['status'] == 'Delivered' ? Colors.blue : AppColors.atelierSilkGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
