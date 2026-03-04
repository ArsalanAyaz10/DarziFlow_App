import 'package:dariziflow_app/features/forgotpassword/services/password_service.dart';

class ForgotPasswordRepository {

  final ForgotPasswordService service;

  ForgotPasswordRepository(this.service);

  Future<Map<String, dynamic>> sendResetLink(String email) async {
    final data = await service.forgotPassword(email);
    return data;
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final data = await service.resetPassword(token, newPassword);
    return data;
  }
}