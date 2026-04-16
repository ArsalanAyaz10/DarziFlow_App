import 'package:dariziflow_app/data/models/operationModel.dart';

class OrderCardModel {
  final String orderId;
  final String orderName;
  final String uniqueId;

  final DateTime? dueDate;
  final double progress;

  final String clientName;
  final String clientEmail;
  final String? clientId;
  final int amount;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String overallStatus;

  final List<OperationModel> operations;

  OrderCardModel({
    required this.orderId,
    required this.orderName,
    required this.uniqueId,
    required this.progress,
    required this.operations,
    this.dueDate,
    required this.clientName,
    required this.clientEmail,
    required this.overallStatus,
    this.clientId,
    this.amount = 0,
    this.currency = 'Rs',
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayOrderId =>
      '#ORD-${uniqueId.length > 6 ? uniqueId.substring(0, 6) : uniqueId}';

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);
}
