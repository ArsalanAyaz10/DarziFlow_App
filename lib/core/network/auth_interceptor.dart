import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<void> Function() onLogout;

  AuthInterceptor(this.dio, this.onLogout);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    final token = await TokenStorage.getAccessToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {

    if (err.response?.statusCode == 401) {
      try {
        // Call refresh endpoint (refresh cookie automatically sent)
        final response = await dio.post("/auth/refresh");

        final newToken = response.headers["x-access-token"]?.first;

        if (newToken != null) {
          await TokenStorage.saveAccessToken(newToken);

          // Retry original request
          final requestOptions = err.requestOptions;

          requestOptions.headers["Authorization"] = "Bearer $newToken";

          final clone = await dio.fetch(requestOptions);

          return handler.resolve(clone);
        }
      } catch (_) {
        await onLogout();
      }
    }

    handler.next(err);
  }
}
