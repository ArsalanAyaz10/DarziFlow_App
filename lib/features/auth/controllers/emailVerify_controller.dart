import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get.dart';

enum VerifyStatus { loading, success, error }

class EmailverifyController extends GetxController {
  final AuthRepository repository;

  EmailverifyController(this.repository);

  final status = VerifyStatus.loading.obs;
  final message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final token = Get.arguments as String?;
    if (token != null && token.isNotEmpty) {
      _verifyEmail(token);
    } else {
      status.value = VerifyStatus.error;
      message.value = 'No verification token found. Please use the link from your email.';
    }
  }

  Future<void> _verifyEmail(String token) async {
    try {
      status.value = VerifyStatus.loading;
      final result = await repository.verifyEmail(token);
      message.value = result;
      status.value = VerifyStatus.success;
    } catch (e) {
      final raw = e.toString();
      message.value = raw.length > 80
          ? 'Verification failed. Your link may have expired or already been used.'
          : raw.replaceAll('Exception: ', '');
      status.value = VerifyStatus.error;
    }
  }

  void goToLogin() => Get.offAllNamed('/login');

  void retryWithEmail() => Get.offAllNamed('/login');
}