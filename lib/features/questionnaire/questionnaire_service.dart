import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class QuestionnaireService {
  Future<Map<String, dynamic>> submitElderForm({
    required int elderId,
    required String mood,
    required String sleepQuantity,
    required String waterIntake,
    required String appetiteLevel,
    required String energyLevel,
    required String overallDay,
    required String movementToday,
    required String lonelinessLevel,
    required String talkInteraction,
    required String stressLevel,
    required List<String> painAreas,
    required List<String> activities,
    required DateTime infoDate,
  }) async {
    try {
      final res = await DioClient.dio.post(
        "/api/v1/elder/elder-form/",
        data: {
          "elder_id": elderId,
          "mood": mood,
          "sleep_quantity": sleepQuantity,
          "water_intake": waterIntake,
          "appetite_level": appetiteLevel,
          "energy_level": energyLevel,
          "overall_day": overallDay,
          "movement_today": movementToday,
          "loneliness_level": lonelinessLevel,
          "talk_interaction": talkInteraction,
          "stress_level": stressLevel,
          "pain_areas": painAreas,
          "activities": activities,
          "info_date": infoDate.toIso8601String().split("T").first,
        },
      );

      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? (e.response?.data["detail"] ?? "Failed to submit elder form")
            : (e.response?.data ?? e.message ?? "Failed to submit elder form"),
      );
    }
  }

  Future<Map<String, dynamic>> getLatestElderForm({
    required int elderId,
  }) async {
    try {
      final res = await DioClient.dio.get("/api/v1/elder/elder-form/elder/$elderId/latest");
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? (e.response?.data["detail"] ?? "Failed to get elder form")
            : (e.response?.data ?? e.message ?? "Failed to get elder form"),
      );
    }
  }
}