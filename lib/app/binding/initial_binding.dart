import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/services/deeplink_service.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:dariziflow_app/features/Notifications/controllers/notification_controller.dart';
import 'package:dariziflow_app/features/Notifications/repositories/notification_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    
    // DeeplinkService 
    final deeplinkService = DeeplinkService();
    await deeplinkService.init();
    Get.put<DeeplinkService>(deeplinkService, permanent: true);

    // ApiService 
    final apiService = ApiService();
    await apiService.init(() async {
      await AppStorage.clearTokens();
    });
    Get.put<ApiService>(apiService, permanent: true);

    final apiClient = ApiClient(apiService.dio);
    Get.put<ApiClient>(apiClient, permanent: true);

    final authService = AuthService(apiClient: apiClient);
    Get.put<AuthService>(authService, permanent: true);

    final authRepo = AuthRepository(authService: authService);
    Get.put<AuthRepository>(authRepo, permanent: true);

    final notificationRepo = NotificationRepository(apiClient: apiClient);
    Get.put<NotificationRepository>(notificationRepo, permanent: true);
    Get.put<NotificationController>(NotificationController(repository: notificationRepo), permanent: true);

    // UploadService (used globally for media uploads across features)
    final uploadService = UploadService(apiClient);
    Get.put<UploadService>(uploadService, permanent: true);

    // SocketService (real-time chat)
    SocketService socketService;
    if (Get.isRegistered<SocketService>()) {
      socketService = Get.find<SocketService>();
    } else {
      socketService = SocketService(apiClient: apiClient);
      Get.put<SocketService>(socketService, permanent: true);
    }
    
    if (socketService.socket?.connected != true) {
      await socketService.connect();
    }
  }
}
