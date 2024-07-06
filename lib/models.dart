enum MessageType { text, image, video, link }

enum SenderType { user, ally }

enum ConversationType { onboarding }

class TeriyaUser {
  final int id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeriyaUser(
      {required this.id,
      required this.email,
      required this.fullName,
      required this.createdAt,
      required this.updatedAt});

  String get firstName => fullName.split(' ')[0];

  factory TeriyaUser.fromJson(Map<String, dynamic> json) {
    return TeriyaUser(
        id: json["id"],
        email: json["email"],
        fullName: json["full_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]));
  }
}

class ConversationMessage {
  final String id;
  final String content;
  final MessageType messageType;
  final SenderType senderType;
  final DateTime timestamp;
  final List<String>? quickReplies; // Optional: For quick reply options
  final Duration? delay;

  ConversationMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.senderType,
    required this.timestamp,
    this.quickReplies,
    this.delay = const Duration(),
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'],
      content: json['content'],
      messageType: MessageType.values.byName(json['message_type']),
      senderType: SenderType.values.byName(json['sender_type']),
      timestamp: json['created_at'],
      delay: json.containsKey("delay")
          ? Duration(milliseconds: json['delay'])
          : const Duration(milliseconds: 0),
    );
  }
}

class Conversation {
  final String conversationId;
  final List<ConversationMessage> messages;
  final ConversationType conversationType;

  Conversation({
    required this.conversationId,
    required this.messages,
    required this.conversationType,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['id'],
      messages: json['messages'],
      conversationType: ConversationType.values.byName(json['type']),
    );
  }

  void addMessage(ConversationMessage message) {
    messages.add(message);
  }

  void removeMessage(String messageId) {
    messages.removeWhere((msg) => msg.id == messageId);
  }
}
