import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ClientDashboardShimmer extends StatelessWidget {
  const ClientDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? colors.surfaceContainerHighest : Colors.grey.shade300;
    final shimmerColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Greeting Section Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildShimmerBox(
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    width: 100,
                    height: 15,
                  ),
                  const SizedBox(width: 5),
                  _buildShimmerBox(
                    baseColor: baseColor,
                    shimmerColor: shimmerColor,
                    width: 80,
                    height: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 250,
                height: 13,
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 10),

          // Stat Cards Row Skeleton
          Row(
            children: [
              _buildStatTileSkeleton(baseColor, shimmerColor, colors),
              const SizedBox(width: 10),
              _buildStatTileSkeleton(baseColor, shimmerColor, colors),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 10),

          // Order Progress Section Skeleton
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 120,
            height: 12,
          ),
          const SizedBox(height: 10),
          _buildLatestOrderCardSkeleton(baseColor, shimmerColor, colors, isDark),

          const SizedBox(height: 10),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 10),

          // Carousel Section Skeleton
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 150,
            height: 12,
          ),
          const SizedBox(height: 10),
          _buildCarouselSkeleton(baseColor, shimmerColor, colors),

          const SizedBox(height: 10),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 10),

          // Recent Activity Panel Skeleton
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 130,
            height: 18,
          ),
          const SizedBox(height: 15),
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildShimmerBox(
                      baseColor: baseColor,
                      shimmerColor: shimmerColor,
                      width: 40,
                      height: 40,
                      borderRadius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(
                            baseColor: baseColor,
                            shimmerColor: shimmerColor,
                            width: 150,
                            height: 14,
                          ),
                          const SizedBox(height: 6),
                          _buildShimmerBox(
                            baseColor: baseColor,
                            shimmerColor: shimmerColor,
                            width: 200,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  Widget _buildStatTileSkeleton(Color baseColor, Color shimmerColor, ColorScheme colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 16,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(width: 4),
                _buildShimmerBox(
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  width: 60,
                  height: 12,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 50,
              height: 26,
            ),
            const SizedBox(height: 8),
            _buildShimmerBox(
              baseColor: baseColor,
              shimmerColor: shimmerColor,
              width: 80,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestOrderCardSkeleton(Color baseColor, Color shimmerColor, ColorScheme colors, bool isDark) {
    final cardColor = isDark ? AppColors.atelierSurfaceDark : AppColors.atelierSurfaceLight;
    
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
              _buildShimmerBox(
                baseColor: baseColor,
                shimmerColor: shimmerColor,
                width: 90,
                height: 22,
                borderRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Semi-circle placeholder
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 140,
            height: 70,
            borderRadius: 70, // Semi-circle representation
          ),
          const SizedBox(height: 20),
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 180,
            height: 18,
          ),
          const SizedBox(height: 8),
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 100,
            height: 12,
          ),
          const SizedBox(height: 16),
          _buildShimmerBox(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            width: 120,
            height: 32,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSkeleton(Color baseColor, Color shimmerColor, ColorScheme colors) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.primaryContainer.withValues(alpha: 0.1),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        color: shimmerColor,
        colorOpacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
