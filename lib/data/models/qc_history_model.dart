import 'package:intl/intl.dart';

class QcHistoryModel {
  final String id;
  final String orderName;
  final String orderId;
  final String departmentName;
  final String operationName;
  final String checkpointName;
  final String action;
  final String comment;
  final DateTime createdAt;

  QcHistoryModel({
    required this.id,
    required this.orderName,
    required this.orderId,
    required this.departmentName,
    required this.operationName,
    required this.checkpointName,
    required this.action,
    required this.comment,
    required this.createdAt,
  });

  factory QcHistoryModel.fromJson(Map<String, dynamic> json) {
    String parsedId = '';
    if (json['_id'] is Map) {
      parsedId = json['_id']['\$oid'] ?? '';
    } else if (json['_id'] != null) {
      parsedId = json['_id'].toString();
    }

    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] is Map && json['createdAt']['\$date'] != null) {
      parsedDate = DateTime.parse(json['createdAt']['\$date'].toString()).toLocal();
    } else if (json['createdAt'] is String) {
      parsedDate = DateTime.parse(json['createdAt']).toLocal();
    }

    return QcHistoryModel(
      id: parsedId,
      orderName: json['orderName'] ?? 'Unknown Order',
      orderId: json['orderId'] ?? '',
      departmentName: json['departmentName'] ?? '',
      operationName: json['operationName'] ?? '',
      checkpointName: json['checkpointName'] ?? '',
      action: json['action'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: parsedDate,
    );
  }

  // Helper for UI
  String get formattedDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(createdAt);
  }
}
