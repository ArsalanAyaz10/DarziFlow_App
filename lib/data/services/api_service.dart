import 'package:dariziflow_app/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late Dio dio;
  late PersistCookieJar cookieJar;
  DateTime? _azureLastFailTime;
  late String primaryUrl;
  late String backupUrl;

  String get currentBaseUrl {
    final now = DateTime.now();
    if (_azureLastFailTime != null &&
        now.difference(_azureLastFailTime!).inSeconds < 30) {
      return backupUrl;
    } else {
      return primaryUrl;
    }
  }

  void triggerFallback() {
    _azureLastFailTime = DateTime.now();
    debugPrint("Azure fallback triggered manually (e.g. from Socket). Using Backup: $backupUrl");
  }

  Future<void> init(Future<void> Function() onLogout) async {
    final String rawPrimary = dotenv.env['AZURE_BASE_URL'] ?? '';
    final String rawBackup = dotenv.env['LOCAL_BASE_URL'] ?? rawPrimary;

    primaryUrl = rawPrimary.endsWith('/') ? rawPrimary : '$rawPrimary/';
    backupUrl = rawBackup.endsWith('/') ? rawBackup : '$rawBackup/';

    dio = Dio(
      BaseOptions(
        baseUrl: primaryUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(storage: FileStorage("${dir.path}/cookies"));

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final now = DateTime.now();
          if (_azureLastFailTime != null &&
              now.difference(_azureLastFailTime!).inSeconds < 30) {
            options.baseUrl = backupUrl;
          } else {
            options.baseUrl = primaryUrl;
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          if (_isNetworkError(err) &&
              err.requestOptions.baseUrl == primaryUrl) {
            _azureLastFailTime = DateTime.now();

            debugPrint("Azure failed. Retrying with Backup: $backupUrl");
            final retryOptions = err.requestOptions.copyWith(
              baseUrl: backupUrl,
            );

            try {
              final response = await dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(err);
            }
          }
          return handler.next(err);
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor(dio, onLogout));
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown ||
        err.response?.statusCode == 403 || // Azure "Stopped" status
        err.response?.statusCode == 503; // Service Unavailable
  }
}
