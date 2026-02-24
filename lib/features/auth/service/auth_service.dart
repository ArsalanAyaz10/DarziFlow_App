import 'package:dariziflow_app/core/services/api_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AuthService extends GetxService with WidgetsBindingObserver {
  final AuthRepository authRepository;
  final ApiService apiService;

  AuthService({required this.authRepository, required this.apiService});

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
     if (state == AppLifecycleState.detached) {
      await _handleTerminationLogout();
    }
  }

  Future<void> _handleTerminationLogout() async {
    await authRepository.logout(apiService.cookieJar);
  }
}