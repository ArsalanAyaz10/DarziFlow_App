import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/notifications/repositories/notification_repository.dart';
import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
        () => NotificationRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<NotificationController>(
        () => NotificationController(repository: Get.find<NotificationRepository>()));
  }
}
