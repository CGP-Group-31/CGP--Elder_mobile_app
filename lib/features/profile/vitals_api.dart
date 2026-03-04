import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class VitalsApi {
  static final Dio _dio = DioClient.dio;

  static Future<List<Map<String, dynamic>>> getVitalTypes() async {
    final res = await _dio.get("/api/v1/caregiver/vitals/types");
    final data = Map<String, dynamic>.from(res.data);
    final types = (data["types"] as List?) ?? [];
    return types.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<Map<String, dynamic>> getLatestVitalsByElder({
    required int elderId,
    int limitPerType = 3,
  }) async {
    final res = await _dio.get(
      "/api/v1/caregiver/vitals/elder/$elderId/latest",
      queryParameters: {"limit_per_type": limitPerType},
    );
    return Map<String, dynamic>.from(res.data);
  }


}