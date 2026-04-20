import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

/// Shimmer skeleton for the ViewProfileScreen.
/// Mirrors: avatar + name + role + edit button, account detail tiles,
///          system tile, and logout button.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

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
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ─── Profile Header: avatar + name + role + button ───
            _buildHeaderSkeleton(baseColor, shimmerColor, colors),
            const SizedBox(height: 30),

            // ─── Section label ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _box(baseColor, shimmerColor, width: 130, height: 12),
              ),
            ),
            const SizedBox(height: 10),

            // ─── Account detail tiles (×3) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTileSkeleton(baseColor, shimmerColor, colors),
                  const SizedBox(height: 10),
                  _buildTileSkeleton(baseColor, shimmerColor, colors),
                  const SizedBox(height: 10),
                  _buildTileSkeleton(baseColor, shimmerColor, colors),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── System section label ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _box(baseColor, shimmerColor, width: 70, height: 12),
              ),
            ),

            // ─── Language tile ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTileSkeleton(baseColor, shimmerColor, colors),
            ),
            const SizedBox(height: 30),

            // ─── Logout button ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _box(baseColor, shimmerColor,
                  width: double.infinity, height: 50, borderRadius: 15),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ────────────── Helpers ──────────────

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

  // ─── Profile Header ───

  Widget _buildHeaderSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.3,
      child: Column(
        children: [
          // Avatar circle
          CircleAvatar(
            radius: 60,
            backgroundColor: baseColor,
          ),
          const SizedBox(height: 15),
          // Name
          Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Role
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 15),
          // Edit Profile button
          Container(
            width: 140,
            height: 40,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile Tile ───

  Widget _buildTileSkeleton(
    Color baseColor,
    Color shimmerColor,
    ColorScheme colors,
  ) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: shimmerColor,
      colorOpacity: 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 170,
                    height: 12,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              width: 16,
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
}
