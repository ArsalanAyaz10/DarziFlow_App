import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  bool isRead;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['read'] == true || json['isRead'] == true,
      data:
          (json['metadata'] as Map<String, dynamic>?) ??
          (json['data'] as Map<String, dynamic>?) ??
          {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
                DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('MMM d, h:mm a').format(createdAt);
  }
}
