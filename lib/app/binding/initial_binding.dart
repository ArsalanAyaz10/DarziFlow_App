import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/services/deeplink_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeeplinkService>(() {
      final service = DeeplinkService();
      service.init();
      return service;
    });

    Get.putAsync<ApiService>(() async {
      final apiService = ApiService();

      await apiService.init(() async {
        await AppStorage.clearTokens();
      });

      return apiService;
    }, permanent: true);

    Get.lazyPut<ApiClient>(() {
      final apiService = Get.find<ApiService>();
      return ApiClient(apiService.dio);
    });

    Get.lazyPut<AuthService>(() => AuthService(apiClient: Get.find()));

    Get.lazyPut<AuthRepository>(() => AuthRepository(authService: Get.find()));
  }
}
