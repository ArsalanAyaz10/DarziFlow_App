import 'package:dariziflow_app/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';


class ApiService {
  late Dio dio;
  late PersistCookieJar cookieJar;

  Future<void> init(Future<void> Function() onLogout) async {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL']!,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {"Content-Type": "application/json"},
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage("${dir.path}/cookies"),
    );

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      AuthInterceptor(dio, onLogout),
    );
  }
}