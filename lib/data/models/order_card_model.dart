import 'package:flutter/material.dart';

enum OrderStatus {
  PENDING,
  IN_PROGRESS,
  COMPLETED,
  OVERDUE,
  HIGH_PRIORITY,
  NEEDS_ATTENTION,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'PENDING';
      case OrderStatus.IN_PROGRESS:
        return 'IN PROGRESS';
      case OrderStatus.COMPLETED:
        return 'COMPLETED';
      case OrderStatus.OVERDUE:
        return 'OVERDUE';
      case OrderStatus.HIGH_PRIORITY:
        return 'HIGH PRIORITY';
      case OrderStatus.NEEDS_ATTENTION:
        return 'NEEDS ATTENTION';
    }
  }

  Color getColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    switch (this) {
      case OrderStatus.IN_PROGRESS:
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
      case OrderStatus.COMPLETED:
        return isDark ? const Color(0xFF81C784) : const Color(0xFF388E3C);
      case OrderStatus.OVERDUE:
        return isDark ? const Color(0xFFE57373) : const Color(0xFFD32F2F);
      case OrderStatus.HIGH_PRIORITY:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00);
      case OrderStatus.PENDING:
        return isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);
      case OrderStatus.NEEDS_ATTENTION:
        return isDark ? const Color(0xFFBA68C8) : const Color(0xFF7B1FA2);
    }
  }

  Color getBackgroundColor(ThemeData theme) {
    return getColor(theme).withValues(alpha: 0.1);
  }
}

class OrderCardModel {
  final String orderId;
  final String orderName;
  final String uniqueId;
  final DateTime? dueDate;
  final OrderStatus status;
  final int progress;
  final Map<String, dynamic>? rawData;

  OrderCardModel({
    required this.orderId,
    required this.orderName,
    required this.uniqueId,
    this.dueDate,
    required this.status,
    required this.progress,
    this.rawData,
  }) : assert(
         progress >= 0 && progress <= 100,
         'Progress must be between 0 and 100',
       );

  String get displayOrderId =>
      '#ORD-${uniqueId.length > 4 ? uniqueId.substring(0, 4) : uniqueId}';

  String get displayDueDate {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final difference = dueDate!.difference(now);

    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return 'Due: ${_formatDate(dueDate!)} (Delayed)';
    } else {
      return 'Due: ${_formatDate(dueDate!)}';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  bool get isOverdue => status == OrderStatus.OVERDUE;
  bool get isHighPriority => status == OrderStatus.HIGH_PRIORITY;
  bool get isPending => status == OrderStatus.PENDING;
  bool get isInProgress => status == OrderStatus.IN_PROGRESS;
  bool get isCompleted => status == OrderStatus.COMPLETED;

  @override
  String toString() {
    return 'OrderCardModel(orderId: $orderId, name: $orderName, status: ${status.displayName}, progress: $progress%)';
  }
}
