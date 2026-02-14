import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SplashController extends GetxController {
  void navigateToSignUp() {
    Get.toNamed('/signup');
  }

  // Method to handle navigation to Login
  void navigateToLogin() {
    Get.toNamed('/login');
  }
}
