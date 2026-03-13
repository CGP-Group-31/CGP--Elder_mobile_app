class ChatMessage {
  final int messageId;
  final int relationshipId;
  final int senderId;
  final String text;
  final bool isRead;
  final DateTime sentAt;

  ChatMessage({
    required this.messageId,
    required this.relationshipId,
    required this.senderId,
    required this.text,
    required this.isRead,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json){
    return ChatMessage(
      messageId: json["message_id"] ?? json["MessageID"] ?? 0,
      relationshipId: json["relationship_id"] ?? json["RelationshipID"] ?? 0,
      senderId: json["sender_id"] ?? json["SenderID"] ?? 0,
      text: (json["message_text"] ?? json["message_text"] ?? "").toString(),
      isRead: (json["is_read"] ?? json["IsRead"] ?? false) == true,
      sentAt: DateTime.tryParse((json["sent_at"] ?? json["SentAt"] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}