import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart'; // For HistoryItem
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class OrderDetailController extends GetxController {
  final OrderRepository repository;
  OrderDetailController(this.repository);

  var order = Rxn<OrderCardModel>();
  var isLoading = false.obs;
  var progress = 0.obs;
  var currentPhase = 'N/A'.obs;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is OrderCardModel) {
      orderId = args.orderId;
      order.value = args;
    } else if (args is Map && args.containsKey('orderId')) {
      orderId = args['orderId'].toString();
    } else {
      orderId = args.toString();
    }

    _initialize();
  }

  Future<void> _initialize() async {
    await refreshOrderDetails();
  }

  Future<void> refreshOrderDetails() async {
    try {
      isLoading.value = true;
      final user = await AppStorage.getUser();
      final deptId = user?['department']?.toString();

      if (deptId == null || orderId.isEmpty) return;

      final data = await repository.fetchActiveWorkflows(deptId);

      final Map<String, dynamic>? specificOrderJson = data.firstWhere(
        (o) => o['_id']?.toString().trim() == orderId.trim(),
        orElse: () => null,
      );

      if (specificOrderJson != null) {
        order.value = _mapToModel(specificOrderJson);

        progress.value = _calculateProgress(order.value!);
        currentPhase.value = _calculateCurrentPhase(order.value!);
      }
    } catch (e) {
      dev.log("Error refreshing order details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  HistoryItem? get latestRejection {
    if (order.value == null) return null;
    for (var op in order.value!.operations) {
      for (var cp in op.checkpoints) {
        if (cp.isRejected) {
          return cp.history.reversed.firstWhere(
            (h) => h.action == "REJECT",
            orElse: () => cp.history.last,
          );
        }
      }
    }
    return null;
  }

  OrderCardModel _mapToModel(Map<String, dynamic> json) {
    return OrderCardModel(
      orderId: json['_id'] ?? '',
      orderName: json['orderName'] ?? '',
      uniqueId: json['orderUniqueId'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
      operations: (json['operations'] as List? ?? [])
          .map(
            (op) => OperationModel(
              id: op['_id'] ?? '',
              name: op['name'] ?? '',
              status: op['status'] ?? 'PENDING',
              checkpoints: (op['checkpoints'] as List? ?? [])
                  .map(
                    (cp) => CheckpointModel(
                      id: cp['_id'] ?? '',
                      name: cp['name'] ?? '',
                      status: cp['status'] ?? 'PENDING',
                      submissionText: cp['submissionText'] ?? '',
                      qcRequired: cp['qcRequired'] ?? false,
                      submissionType: _parseSubmissionType(
                        cp['submissionType'],
                      ),
                      minUploads: cp['minUploads'] ?? 0,
                      
                      submissionFiles: [],
                      history: (cp['history'] as List? ?? [])
                          .map(
                            (h) => HistoryItem(
                              action: h['action'] ?? '',
                              actedBy: h['actedBy'] ?? '',
                              actedAt:
                                  DateTime.tryParse(h['actedAt'] ?? '') ??
                                  DateTime.now(),
                              comment: h['comment'],
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
  static SubmissionType _parseSubmissionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return SubmissionType.image;
      case 'video':
        return SubmissionType.video;
      case 'document':
        return SubmissionType.document;
      case 'text':
      default:
        return SubmissionType.text;
    }
  }

  int _calculateProgress(OrderCardModel data) {
    int total = 0;
    int done = 0;
    for (var op in data.operations) {
      total += op.checkpoints.length;
      done += op.checkpoints.where((cp) => cp.isApproved).length;
    }
    return total == 0 ? 0 : ((done / total) * 100).round();
  }

  String _calculateCurrentPhase(OrderCardModel data) {
    for (var op in data.operations) {
      for (var cp in op.checkpoints) {
        if (cp.isRejected) return "REWORK REQUIRED";
        if (cp.isQcPending) return op.name.toUpperCase();
      }
    }
    return "COMPLETED";
  }
}
