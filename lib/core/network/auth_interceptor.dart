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
    final refreshToken = await AppStorage.getRefreshToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    if (refreshToken != null) {
      options.headers["x-refresh-token"] = refreshToken;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final newAccessToken = response.headers.value("x-access-token");
    if (newAccessToken != null) {
      await AppStorage.saveAccessToken(newAccessToken);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await onLogout();
    }
    handler.next(err);
  }
}
