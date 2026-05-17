import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class QCDashboardShimmer extends StatelessWidget {
  const QCDashboardShimmer({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // --- Header Skeleton ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 160,
                  height: 20,
                ),
                const SizedBox(height: 6),
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 240,
                  height: 14,
                ),
                const SizedBox(height: 10),
                Divider(color: colors.outlineVariant, height: 10),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- Stat Cards Row ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatCardSkeleton(baseColor, shimmerColor, colors),
                const SizedBox(width: 10),
                _buildStatCardSkeleton(baseColor, shimmerColor, colors),
                const SizedBox(width: 10),
                _buildStatCardSkeleton(baseColor, shimmerColor, colors),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: colors.outlineVariant, height: 10),
          ),
          const SizedBox(height: 10),

          // --- Assigned Orders Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 120,
              height: 18,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 240,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerBox(
                      baseColor: baseColor,
                      shimmerColor: shimmerColor,
                      width: 140,
                      height: 14,
                    ),
                    const SizedBox(height: 6),
                    _buildShimmerBox(
                      baseColor: baseColor,
                      shimmerColor: shimmerColor,
                      width: 80,
                      height: 12,
                    ),
                    const SizedBox(height: 12),
                    _buildShimmerBox(
                      baseColor: baseColor,
                      shimmerColor: shimmerColor,
                      width: 70,
                      height: 20,
                      borderRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: colors.outlineVariant, height: 10),
          ),
          const SizedBox(height: 10),

          // --- Reviews Needed Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 130,
                  height: 18,
                ),
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 60,
                  height: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Review List ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildReviewItemSkeleton(baseColor, shimmerColor, theme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required Color baseColor,
    required Color shimmerColor,
    required double width,
    required double height,
    double borderRadius = 4,
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

  Widget _buildStatCardSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 32,
                  height: 32,
                  borderRadius: 10,
                ),
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 40,
                  height: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 50,
              height: 12,
            ),
            const SizedBox(height: 4),
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 35,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItemSkeleton(Color baseColor, Color shimmerColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 140,
                height: 14,
              ),
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 60,
                height: 11,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 100,
            height: 10,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 70,
                height: 16,
                borderRadius: 6,
              ),
              const Spacer(),
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 50,
                height: 14,
              ),
              const SizedBox(width: 10),
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 50,
                height: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
