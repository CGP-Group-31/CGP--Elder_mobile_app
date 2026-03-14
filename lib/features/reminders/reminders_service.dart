import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class RemindersService {

  Future<int> _getElderId() async {
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) {
      throw Exception("No elder ID found in session.");
    }
    return elderId;
  }

  // =============================
  // MEDICINE REMINDERS
  // =============================

  Future<List<Map<String, dynamic>>> fetchTodayScheduled() async {
    final elderId = await _getElderId();

    final response = await DioClient.dio.get(
      '/api/v1/caregiver/medicine/elder/$elderId/today-scheduled',
    );

    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchTodayTaken() async {
    final elderId = await _getElderId();

    final response = await DioClient.dio.get(
      '/api/v1/caregiver/medicine/elder/$elderId/today-taken',
    );

    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchTodayMissed() async {
    final elderId = await _getElderId();

    final response = await DioClient.dio.get(
      '/api/v1/caregiver/medicine/elder/$elderId/today-missed',
    );

    return List<Map<String, dynamic>>.from(response.data);
  }


  // =============================
  // UPCOMING APPOINTMENTS (NEXT 7 DAYS)
  // =============================

  Future<List<Map<String, dynamic>>> fetchUpcomingAppointments() async {
    final elderId = await _getElderId();

    final response = await DioClient.dio.get(
      '/api/v1/caregiver/appointments/elder/$elderId/upcoming-7-days',
    );

    return List<Map<String, dynamic>>.from(response.data);
  }

}