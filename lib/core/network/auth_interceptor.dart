import 'package:dio/dio.dart';
import '../storage/storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<void> Function() onLogout;

  AuthInterceptor(this.dio, this.onLogout);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AppStorage.getAccessToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await onLogout();
    }
    handler.next(err);
  }
}
