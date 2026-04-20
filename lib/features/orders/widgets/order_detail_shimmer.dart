import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? colors.surfaceContainerHighest : Colors.grey.shade300;
    final shimmerColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _box(baseColor, shimmerColor,
                    width: double.infinity, height: 20),
              ),
              const SizedBox(width: 16),
              _box(baseColor, shimmerColor,
                  width: 90, height: 28, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 24),

          //Amount card
          Shimmer(
            duration: const Duration(seconds: 2),
            color: shimmerColor,
            colorOpacity: 0.3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 140,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 22,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Date info boxes (Created At + Due Date) ───
          Row(
            children: [
              Expanded(
                child: _buildDateBoxSkeleton(baseColor, shimmerColor, colors),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateBoxSkeleton(baseColor, shimmerColor, colors),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            height: 1,
            color: colors.outline.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 32),

          //client details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _box(baseColor, shimmerColor, width: 120, height: 20),
              _box(baseColor, shimmerColor,
                  width: 22, height: 22, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),

          Shimmer(
            duration: const Duration(seconds: 2),
            color: shimmerColor,
            colorOpacity: 0.3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: baseColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildButtonSkeleton(baseColor, shimmerColor),
          const SizedBox(height: 16),
          _buildButtonSkeleton(baseColor, shimmerColor),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _box(
    Color baseColor,
    Color shimmerColor, {
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildDateBoxSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 10,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSkeleton(Color baseColor, Color shimmerColor) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.3,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
