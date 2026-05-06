import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/features/Cilent/controllers/client_dashboard_controller.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/Notifications/repositories/notification_repository.dart';
import 'package:get/get.dart';

class ClientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientDashboardController>(() => ClientDashboardController());
    Get.lazyPut<NotificationRepository>(
        () => NotificationRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<NotificationController>(
        () => NotificationController(repository: Get.find<NotificationRepository>()));
  }
}
