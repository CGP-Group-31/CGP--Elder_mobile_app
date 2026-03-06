import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MessageService {
  Future<Map<String, dynamic>> getMessages({
    required int relationshipId,
    int afterId = 0,
    int limit = 200,
  }) async {
    try {
      final Response res = await DioClient.dio.get(
        "/api/messages",
        queryParameters: {
          "relationship_id": relationshipId,
          "after_id": afterId,
          "limit": limit,
        },
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e){
      throw Exception(e.response?.data ?? e.message ?? "Failed to load messages");
    }
  }

  Future<void> sendMessage({
    required int relationshipId,
    required int senderId,
    required String messageText,
  }) async {
    try {
      await DioClient.dio.post(
        "/api/messages/send",
        data: {
          "relationship_id": relationshipId,
          "sender_id": senderId,
          "message_text": messageText,
        },
      );
    } on DioException catch (e){
      throw Exception(e.response?.data ?? e.message ?? "Failed to send message");
    }
  }

  Future<void> markRead({
    required int relationshipId,
    required int readerId,
    required List<int> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    try {
      await DioClient.dio.put(
        "/api/messages/read",
        data: {
          "relationship_id": relationshipId,
          "reader_id": readerId,
          "message_ids": messageIds,
        },
      );
    } on DioException catch (_) {
      //ignore
    }
  }
}