import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/features/Profile/controllers/profile_view_controller.dart';
import 'package:dariziflow_app/features/Profile/repositories/profile_repository.dart';
import 'package:dariziflow_app/features/Profile/services/profile_service.dart';
import 'package:get/get.dart';

class ProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    // Only put the dependencies if they don't already exist.
    if (!Get.isRegistered<ProfileService>()) {
      Get.lazyPut(() => ProfileService(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut(() => ProfileRepository(Get.find<ProfileService>()));
    }
    
    Get.lazyPut<ProfileViewController>(
      () => ProfileViewController(repository: Get.find<ProfileRepository>()),
    );
  }
}
