import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? colors.surfaceContainerHighest : Colors.grey.shade300;
    final shimmerColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            color: shimmerColor,
            colorOpacity: 0.3,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            color: shimmerColor,
            colorOpacity: 0.3,
            child: Row(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: [60.0, 75.0, 80.0, 70.0][i],
                    height: 32,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ─── Order card skeletons ───
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderCardSkeleton(
                baseColor,
                shimmerColor,
                colors,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCardSkeleton(
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
            // ID + status badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 22,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Order name
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Progress label row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 130,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 30,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            // Due date + arrow row
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
