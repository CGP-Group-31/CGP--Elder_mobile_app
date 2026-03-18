import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DioClient {
  // Private constructor
  DioClient._();

  static final Dio _dio = Dio()
    ..interceptors.add(LogInterceptor(responseBody: true))
    ..options.baseUrl = ApiConfig.baseUrl;

  static Dio get dio => _dio;

  // AI backend (PORT 8001)
  static final Dio _dioSecond = Dio()
    ..interceptors.add(LogInterceptor(responseBody: true))
    ..options.baseUrl = ApiConfig.secondBaseUrl;

  static Dio get dioSecond => _dioSecond;
}