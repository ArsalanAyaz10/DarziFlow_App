import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/core/storage/token_storage.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<ApiService>(() async {
      final apiService = ApiService();
      await apiService.init(() async {
        await TokenStorage.clearTokens();
      });

      Get.put<ApiClient>(ApiClient(apiService.dio), permanent: true);

      Get.put<AuthRepository>(
        AuthRepository(Get.find<ApiClient>()),
        permanent: true,
      );
      return apiService;
    }, permanent: true);
  }
}
