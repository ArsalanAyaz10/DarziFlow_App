import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/services/deeplink_service.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

Future<void> appInitializer() async {
  
  // Load DeeplinkService
  Get.lazyPut<DeeplinkService>(() => DeeplinkService());

  // Initialize ApiService
  final apiService = ApiService();
  await apiService.init(() async {
    await AppStorage.clearTokens();
  });
  Get.put<ApiService>(apiService, permanent: true);

  final apiClient = ApiClient(apiService.dio);
  Get.put<ApiClient>(apiClient, permanent: true);

  Get.lazyPut<AuthService>(() => AuthService(apiClient: Get.find()));
  Get.lazyPut<AuthRepository>(() => AuthRepository(authService: Get.find()));
}
