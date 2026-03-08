import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:dariziflow_app/features/profile/controllers/editProfile_controller.dart';
import 'package:dariziflow_app/features/profile/repositories/profile_repository.dart';
import 'package:dariziflow_app/features/profile/services/profile_service.dart';
import 'package:get/get.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRepository(Get.find<ProfileService>()));
    Get.lazyPut(() => UploadService(Get.find<ApiClient>()));
    Get.lazyPut(
      () => EditProfileController(
        profileRepository: Get.find<ProfileRepository>(),
        uploadService: Get.find<UploadService>(),
      ),
    );
    Get.lazyPut(() => ProfileService(Get.find<ApiClient>()));
  }
}
