import 'package:dariziflow_app/app/app.dart';
import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/core/services/api_service.dart';
import 'package:dariziflow_app/core/storage/token_storage.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  await _initServices();

  runApp(const MyApp());
}

Future<void> _initServices() async {
  final apiService = ApiService();
  await apiService.init(() async {
  await TokenStorage.clearTokens();
});
  Get.put<ApiService>(apiService, permanent: true);

  final apiClient = ApiClient(apiService.dio);
  Get.put<ApiClient>(apiClient, permanent: true);

  final authRepository = AuthRepository(apiClient);
  Get.put<AuthRepository>(
    AuthRepository(Get.find<ApiClient>()),
    permanent: true,
  );

  Get.put<AuthService>(
    AuthService(authRepository: authRepository, apiService: apiService),
    permanent: true,
  );
}
