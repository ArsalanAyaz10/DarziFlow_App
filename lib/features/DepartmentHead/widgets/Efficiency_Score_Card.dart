import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/deptHead_controller.dart';
import 'package:flutter/material.dart';

class EfficiencyScoreCard extends StatelessWidget {
  final DeptHeadController controller;
  final ColorScheme colors;
  final bool isDark;

  const EfficiencyScoreCard({super.key, 
    required this.controller,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primaryContainer,
                  colors.primaryContainer.withValues(alpha: 0.8),
                ]
              : [AppColors.primaryGreen, const Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.green).withValues(
              alpha: 0.3,
            ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Department Performance",
                    style: TextStyle(
                      color: isDark
                          ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                          : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Efficiency Score",
                    style: TextStyle(
                      color: isDark ? colors.onPrimaryContainer : AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.onSurface.withValues(alpha: 0.1)
                          : AppColors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Quality: ${controller.qualityScore.value}%",
                      style: TextStyle(
                        color: isDark ? colors.onPrimaryContainer : AppColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: controller.efficiencyScore.value / 100,
                ),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          backgroundColor:
                              (isDark ? colors.onPrimaryContainer : AppColors.white)
                                  .withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? colors.onPrimaryContainer : Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(value * 100).toInt()}",
                            style: TextStyle(
                              color: isDark ? colors.onPrimaryContainer : AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "%",
                            style: TextStyle(
                              color: isDark
                                  ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                                  : Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Operations
              Column(
                children: [
                  Icon(
                    Icons.checklist,
                    color: isDark
                        ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                        : Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.completedOps.value}/${controller.totalOperationsHandled.value}",
                    style: TextStyle(
                      color: isDark ? colors.onPrimaryContainer : AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Operations",
                    style: TextStyle(
                      color: isDark
                          ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                          : Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              // Checkpoints
              Column(
                children: [
                  Icon(
                    Icons.task_alt,
                    color: isDark
                        ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                        : Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.completedCheckpoints.value}/${controller.totalCheckpoints.value}",
                    style: TextStyle(
                      color: isDark ? colors.onPrimaryContainer : AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Checkpoints",
                    style: TextStyle(
                      color: isDark
                          ? colors.onPrimaryContainer.withValues(alpha: 0.7)
                          : Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
