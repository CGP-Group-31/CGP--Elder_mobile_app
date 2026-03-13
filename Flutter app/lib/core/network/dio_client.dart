import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DioClient {
  // Private constructor
  DioClient._();

  static final Dio _dio = Dio()
    ..interceptors.add(LogInterceptor(responseBody: true))
    ..options.baseUrl = ApiConfig.baseUrl;

  static Dio get dio => _dio;
}
