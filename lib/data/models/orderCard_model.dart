import 'package:dariziflow_app/data/models/operationModel.dart';

class OrderCardModel {
  final String orderId;
  final String orderName;
  final String uniqueId;

  final DateTime? dueDate;

  final double progress;

  final List<OperationModel> operations;

  OrderCardModel({
    required this.orderId,
    required this.orderName,
    required this.uniqueId,
    required this.progress,
    required this.operations,
    this.dueDate,
  });

  String get displayOrderId =>
      '#ORD-${uniqueId.length > 6 ? uniqueId.substring(0, 6) : uniqueId}';

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);
}
