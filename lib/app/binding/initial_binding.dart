import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/services/deeplink_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/notifications/repositories/notification_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    
    // DeeplinkService can remain lazy
    Get.lazyPut<DeeplinkService>(() {
      final service = DeeplinkService();
      service.init();
      return service;
    });

    // Make ApiService synchronous
    final apiService = ApiService();
    await apiService.init(() async {
      await AppStorage.clearTokens();
    });
    Get.put<ApiService>(apiService, permanent: true);

    // API client depends on ApiService
    final apiClient = ApiClient(apiService.dio);
    Get.put<ApiClient>(apiClient, permanent: true);

    // AuthService & AuthRepository are permanent global services
    final authService = AuthService(apiClient: apiClient);
    Get.put<AuthService>(authService, permanent: true);

    final authRepo = AuthRepository(authService: authService);
    Get.put<AuthRepository>(authRepo, permanent: true);

    // Initialize NotificationRepository & Controller for global badge access
    final notificationRepo = NotificationRepository(apiClient: apiClient);
    Get.put<NotificationRepository>(notificationRepo, permanent: true);
    Get.put<NotificationController>(NotificationController(repository: notificationRepo), permanent: true);
  }
}
