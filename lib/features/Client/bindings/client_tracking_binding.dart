import 'package:dariziflow_app/features/Client/controllers/client_tracking_controller.dart';
import 'package:dariziflow_app/features/Client/services/client_service.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:get/get.dart';

class ClientTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientService>(() => ClientService());
    Get.lazyPut<ClientTrackingController>(
      () => ClientTrackingController(Get.find<OrderRepository>()),
    );
  }
}

