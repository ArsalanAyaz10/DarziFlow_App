import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';
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

      if (orderId.isEmpty) {
        dev.log("Error: orderId is empty");
        return;
      }

      final dynamic specificOrderJson = await repository.fetchOrderById(
        orderId,
      );

      if (specificOrderJson != null) {
        final Map<String, dynamic> responseMap =
            specificOrderJson as Map<String, dynamic>;

        final Map<String, dynamic> orderData = responseMap.containsKey('order')
            ? responseMap['order'] as Map<String, dynamic>
            : responseMap;

        dev.log("Unwrapped Order Data: ${orderData.toString()}");

        order.value = _mapToModel(orderData);

        progress.value = _calculateProgress(order.value!);
        currentPhase.value = _calculateCurrentPhase(order.value!);
      } else {
        dev.log("No data returned for Order ID: $orderId");
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
    final List<dynamic> workflow = json['workflow'] ?? [];
    final List<dynamic> allOperations = workflow.expand((dept) {
      return (dept['operations'] as List? ?? []);
    }).toList();

    return OrderCardModel(
      orderId: json['_id'] ?? json['id'] ?? '',
      orderName: json['name'] ?? json['orderName'] ?? '',
      uniqueId: json['uniqueId'] ?? json['orderUniqueId'] ?? '',
      overallStatus: json['overallStatus'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      progress:
          num.tryParse(json['progress']?.toString() ?? '0')?.toDouble() ?? 0.0,
      amount: num.tryParse(json['amount']?.toString() ?? '0')?.toInt() ?? 0,

      clientName: json['clientName'] ?? 'Unknown Client',
      clientEmail: json['clientEmail'] ?? 'No email provided',
      clientId: json['clientId']?.toString(),
      currency: json['currency'] ?? 'Rs',

      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,

      operations: allOperations.map((op) {
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

            return CheckpointModel(
              id: cp['_id'] ?? '',
              name: cp['name'] ?? '',
              status: cp['status'] ?? 'PENDING',
              submissionText: cp['submissionText'] ?? '',
              qcRequired: cp['qcRequired'] ?? false,
              submissionType: _parseSubmissionType(typeString),
              minUploads:
                  num.tryParse(cp['minUploads']?.toString() ?? '0')?.toInt() ??
                  0,
              submissionFiles: [],
              history: (cp['history'] as List? ?? []).map((h) {
                return HistoryItem(
                  action: h['action'] ?? '',
                  actedBy: h['actedBy']?.toString() ?? '',
                  actedAt:
                      DateTime.tryParse(h['actedAt']?.toString() ?? '') ??
                      DateTime.now(),
                  comment: h['comment'],
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
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
