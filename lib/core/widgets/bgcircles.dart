import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';

class BackgroundCircle extends StatelessWidget {
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final double sizeMultiplier;
  final double opacity;

  const BackgroundCircle({
    super.key,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.sizeMultiplier = 0.95, // Default size ratio
    this.opacity = 0.08,        // Default subtle green
  });

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * sizeMultiplier;

    return Positioned(
      top: top != null ? MediaQuery.of(context).size.width * top! : null,
      left: left != null ? MediaQuery.of(context).size.width * left! : null,
      bottom: bottom != null ? MediaQuery.of(context).size.width * bottom! : null,
      right: right != null ? MediaQuery.of(context).size.width * right! : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}