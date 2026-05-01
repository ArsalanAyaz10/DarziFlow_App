import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class OrderDetailController extends GetxController {
  final OrderRepository repository;
  OrderDetailController(this.repository);

  final order = Rxn<OrderModel>();
  final isLoading = false.obs;
  final progress = 0.obs;
  final currentPhase = 'N/A'.obs;
  final userRole = ''.obs;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is OrderModel) {
      orderId = args.orderId;
      order.value = args;
      progress.value = args.progress.round();
      
      // Calculate current phase
      String phase = "COMPLETED";
      for (var op in args.operations) {
        for (var cp in op.checkpoints) {
          if (cp.isRejected) {
            phase = "REWORK REQUIRED";
            break;
          }
          if (cp.isQcPending) {
            phase = op.name.toUpperCase();
            break;
          }
        }
        if (phase != "COMPLETED") break;
      }
      currentPhase.value = phase;
    } else {
      orderId = (args is Map) ? args['orderId'].toString() : args.toString();
    }

    AppStorage.getUserRole().then((role) => userRole.value = role?.toUpperCase() ?? '');
    refreshOrderDetails();
  }

  Future<void> refreshOrderDetails() async {
    try {
      isLoading.value = true;
      if (orderId.isEmpty) return;

      final response = await repository.fetchOrderById(orderId);
      if (response != null) {
        final data = (response as Map<String, dynamic>).containsKey('order') 
            ? response['order'] as Map<String, dynamic> 
            : response;

        final newOrder = OrderModel.fromJson(data);
        order.value = newOrder;
        progress.value = newOrder.progress.round();

        String phase = "COMPLETED";
        for (var op in newOrder.operations) {
          for (var cp in op.checkpoints) {
            if (cp.isRejected) {
              phase = "REWORK REQUIRED";
              break;
            }
            if (cp.isQcPending) {
              phase = op.name.toUpperCase();
              break;
            }
          }
          if (phase != "COMPLETED") break;
        }
        currentPhase.value = phase;
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
          return cp.history.reversed.where((h) => h.action == "REJECT").firstOrNull ?? cp.history.lastOrNull;
        }
      }
    }
    return null;
  }
}
