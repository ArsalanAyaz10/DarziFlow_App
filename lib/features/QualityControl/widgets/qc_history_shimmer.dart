import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class QCHistoryShimmer extends StatelessWidget {
  const QCHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? colors.surfaceContainerHighest : Colors.grey.shade300;
    final shimmerColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colors.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildShimmerBox(
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        width: 18,
                        height: 18,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 8),
                      _buildShimmerBox(
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        width: 80,
                        height: 14,
                      ),
                    ],
                  ),
                  _buildShimmerBox(
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    width: 70,
                    height: 11,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withValues(alpha: 0.5)),
              const SizedBox(height: 12),

              // Content Skeletons
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 180,
                height: 15,
              ),
              const SizedBox(height: 6),
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 120,
                height: 13,
              ),
              
              const SizedBox(height: 12),
              
              // Bottom Link Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildShimmerBox(
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    width: 100,
                    height: 11,
                  ),
                  const SizedBox(width: 4),
                  _buildShimmerBox(
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    width: 10,
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
}
