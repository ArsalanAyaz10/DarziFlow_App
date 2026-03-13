import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class AppService extends GetxService with WidgetsBindingObserver {
  
  final AuthRepository authRepository;
  final ApiService apiService;

  AppService({required this.authRepository, required this.apiService});

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
