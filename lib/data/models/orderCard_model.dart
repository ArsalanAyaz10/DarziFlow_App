import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';

class OrderModel {
  final String orderId;
  final String orderName;


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

  OrderModel({
    required this.orderId,
    required this.orderName,

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
      '#ORD-${orderId.length > 6 ? orderId.substring(orderId.length - 6) : orderId}';

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawOperations = [];
    if (json.containsKey('workflow')) {
      final List<dynamic> workflow = json['workflow'] ?? [];
      rawOperations = workflow.expand((dept) => (dept['operations'] as List? ?? [])).toList();
    } else {
      rawOperations = json['operations'] as List? ?? [];
    }

    final operationsList = rawOperations.map((op) {
      return OperationModel(
        id: op['_id'] ?? '',
        name: op['name'] ?? '',
        status: op['status'] ?? 'PENDING',
        checkpoints: (op['checkpoints'] as List? ?? []).map((cp) {
          String typeString = 'TEXT';
          if (cp['allowedSubmissionTypes'] != null &&
              (cp['allowedSubmissionTypes'] as List).isNotEmpty) {
            typeString = cp['allowedSubmissionTypes'][0].toString();
          } else if (cp['submissionType'] != null) {
            typeString = cp['submissionType'].toString();
          }

          final List<String> allowedTypesList = (cp['allowedSubmissionTypes'] as List? ?? [])
              .map((e) => e.toString())
              .toList();

          return CheckpointModel(
            id: cp['_id'] ?? '',
            name: cp['name'] ?? '',
            status: cp['status'] ?? 'PENDING',
            description: cp['description'] ?? '',
            submissionText: cp['submissionText'] ?? '',
            qcRequired: cp['qcRequired'] ?? false,
            submissionType: _parseSubmissionType(typeString),
            minUploads: num.tryParse(cp['minRequiredUploads']?.toString() ?? '0')?.toInt() ?? 0,
            allowedTypes: allowedTypesList,
            submissionFiles: (cp['submissionFiles'] as List? ?? [])
                .map((f) => SubmissionFile.fromJson(f as Map<String, dynamic>))
                .toList(),
            history: (cp['history'] as List? ?? []).map((h) {
              return HistoryItem(
                action: h['action'] ?? '',
                actedBy: h['actedBy']?.toString() ?? '',
                actedAt: DateTime.tryParse(h['actedAt']?.toString() ?? '') ?? DateTime.now(),
                comment: h['comment'],
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    double progressVal = num.tryParse(json['progress']?.toString() ?? '0')?.toDouble() ?? 0.0;
    if (progressVal == 0.0 && rawOperations.isNotEmpty) {
      progressVal = _calculateProgressFromOperations(operationsList).toDouble();
    }

    return OrderModel(
      orderId: json['_id'] ?? json['id'] ?? '',
      orderName: json['orderName'] ?? json['name'] ?? 'Unknown Order',

      overallStatus: json['overallStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      progress: progressVal,
      clientName: json['clientName'] ?? 'Unknown Client',
      clientEmail: json['clientEmail'] ?? 'No email provided',
      clientId: json['clientId']?.toString(),
      amount: num.tryParse(json['amount']?.toString() ?? '0')?.toInt() ?? 0,
      currency: json['currency'] ?? 'Rs',
      operations: operationsList,
    );
  }

  static SubmissionType _parseSubmissionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return SubmissionType.image;
      case 'video':
        return SubmissionType.video;
      case 'document':
      case 'doc':
        return SubmissionType.document;
      case 'text':
      default:
        return SubmissionType.text;
    }
  }

  static int _calculateProgressFromOperations(List<OperationModel> operations) {
    int total = 0;
    int done = 0;
    for (var op in operations) {
      total += op.checkpoints.length;
      for (var cp in op.checkpoints) {
        if (cp.status == 'COMPLETED' || cp.status == 'QC_APPROVED' || cp.status == 'APPROVED') {
          done++;
        }
      }
    }
    return total == 0 ? 0 : ((done / total) * 100).round();
  }
}
