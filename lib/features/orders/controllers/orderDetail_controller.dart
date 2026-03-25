import 'package:dariziflow_app/data/models/order_card_model.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderDetailController extends GetxController {
  final OrderRepository repository;
  OrderDetailController(this.repository);

  var orderData = {}.obs;
  var isLoading = false.obs; // Start false because we use arguments
  var progress = 0.obs;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is OrderCardModel) {
      OrderCardModel order = Get.arguments;
      orderId = order.orderId;

      // 1. Immediately fill the UI with data we already have
      orderData.value = order.rawData!;
      progress.value = order.progress;

      // 2. Fetch fresh data in the background (no full-screen loader)
      refreshOrderDetails();
    } else {
      // If no arguments, then we show a loader and fetch
      isLoading.value = true;
      // fetchOrderDetails(); // Logic for deep-linking
    }
  }

  Future<void> refreshOrderDetails() async {
    try {
      // You mentioned fetchActiveWorkflows requires a Dept ID. 
      // Ensure you pass a valid ID here or implement getOrderById in Service.
      final data = await repository.fetchActiveWorkflows("YOUR_DEPT_ID_HERE"); 
      
      final specificOrder = data.firstWhere(
        (o) => o['_id'] == orderId,
        orElse: () => {},
      );

      if (specificOrder.isNotEmpty) {
        orderData.value = specificOrder;
        progress.value = _calculateProgress(specificOrder);
      }
    } catch (e) {
      print("Error refreshing details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int _calculateProgress(Map<String, dynamic> data) {
    int totalCheckpoints = 0;
    int completedCheckpoints = 0;
    final operations = data['operations'] as List? ?? [];

    for (var op in operations) {
      final checkpoints = op['checkpoints'] as List? ?? [];
      totalCheckpoints += checkpoints.length;
      for (var cp in checkpoints) {
        final status = cp['status'] ?? '';
        if (['COMPLETED', 'QC_APPROVED', 'APPROVED'].contains(status)) {
          completedCheckpoints++;
        }
      }
    }
    return totalCheckpoints == 0 ? 0 : ((completedCheckpoints / totalCheckpoints) * 100).round();
  }
}