import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderWorkflowShimmer extends StatelessWidget {
  const OrderWorkflowShimmer({super.key});

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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Shimmer(
            duration: const Duration(seconds: 2),
            color: shimmerColor,
            colorOpacity: 0.3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 18,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          for (int i = 0; i < 3; i++) ...[
            _buildOperationSkeleton(baseColor, shimmerColor, colors, isDark),
            if (i < 2) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
    bool isDark,
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
            // Operation header
            Row(
              children: [
                // Timeline dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
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
            const SizedBox(height: 16),

            // Checkpoint items
            for (int j = 0; j < 2; j++) ...[
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
              if (j < 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
