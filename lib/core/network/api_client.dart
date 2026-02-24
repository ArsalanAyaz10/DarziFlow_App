import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response> get(String path,
      {Map<String, dynamic>? query}) {
    return dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path,
      {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path,
      {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }

  Future<Response> upload(
      String path,
      FormData formData) {
    return dio.post(path, data: formData);
  }
}
