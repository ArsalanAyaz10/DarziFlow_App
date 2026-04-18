import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/submissionModel.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class OrderDetailController extends GetxController {
  final OrderRepository repository;
  OrderDetailController(this.repository);

  var order = Rxn<OrderModel>();
  var isLoading = false.obs;
  var progress = 0.obs;
  var currentPhase = 'N/A'.obs;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is OrderModel) {
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

        order.value = OrderModel.fromJson(orderData);

        progress.value = order.value!.progress.round();
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



  String _calculateCurrentPhase(OrderModel data) {
    for (var op in data.operations) {
      for (var cp in op.checkpoints) {
        if (cp.isRejected) return "REWORK REQUIRED";
        if (cp.isQcPending) return op.name.toUpperCase();
      }
    }
    return "COMPLETED";
  }
}
