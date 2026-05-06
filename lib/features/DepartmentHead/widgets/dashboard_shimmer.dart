import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? colors.surfaceContainerHighest : Colors.grey.shade300;
    final shimmerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSkeleton(baseColor, shimmerColor, colors),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatTileSkeleton(baseColor, shimmerColor, colors),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatTileSkeleton(baseColor, shimmerColor, colors),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildEfficiencyCardSkeleton(baseColor, shimmerColor, isDark, colors),
          const SizedBox(height: 30),

          _buildActivitySectionSkeleton(baseColor, shimmerColor, colors),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildShimmerBox({
    required Color baseColor,
    required Color shimmerColor,
    required double width,
    required double height,
    double borderRadius = 8,
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


  Widget _buildHeaderSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShimmerBox(
          baseColor: baseColor,
          shimmerColor: shimmerColor,
          width: 160,
          height: 24,
          borderRadius: 6,
        ),
        _buildShimmerBox(
          baseColor: baseColor,
          shimmerColor: shimmerColor,
          width: 80,
          height: 28,
          borderRadius: 20,
        ),
      ],
    );
  }


  Widget _buildStatTileSkeleton(
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
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon + label row
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // big number
            Container(
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            // sub text
            Container(
              width: 100,
              height: 12,
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


  Widget _buildEfficiencyCardSkeleton(
    Color baseColor,
    Color shimmerColor,
    bool isDark,
    ColorScheme colors,
  ) {
    final cardBaseColor = isDark
        ? colors.surfaceContainerHighest
        : Colors.grey.shade200;
    final innerPlaceholder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade300;

    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.25,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBaseColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Labels column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: innerPlaceholder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: innerPlaceholder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 90,
                      height: 22,
                      decoration: BoxDecoration(
                        color: innerPlaceholder,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                // Circular progress placeholder
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: innerPlaceholder,
                      width: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumnSkeleton(innerPlaceholder),
                _buildMetricColumnSkeleton(innerPlaceholder),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumnSkeleton(Color placeholderColor) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 14,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 10,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ─── Recent Activity Section ───

  Widget _buildActivitySectionSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Column(
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 130,
              height: 18,
              borderRadius: 6,
            ),
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 60,
              height: 14,
              borderRadius: 4,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3 activity tile skeletons
        for (int i = 0; i < 3; i++) ...[
          _buildActivityTileSkeleton(baseColor, shimmerColor, colors),
          if (i < 2) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildActivityTileSkeleton(
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
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 160,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time placeholder
            Container(
              width: 35,
              height: 10,
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
}
