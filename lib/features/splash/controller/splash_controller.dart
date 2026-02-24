import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SplashController extends GetxController {
  final AuthRepository repo;

  SplashController(this.repo);

  @override
  void onInit() {
    super.onInit();
  }
}
