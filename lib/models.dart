import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';

enum ConversationMessageType { text, image, video, link }

enum ConversationMessageSenderType { user, ally }

enum ConversationType { onboarding }

class TeriyaUser {
  final int id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? onboardingFinishedAt;

  TeriyaUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    required this.onboardingFinishedAt,
  });

  String get firstName => fullName.split(' ')[0];

  factory TeriyaUser.fromJson(Map<String, dynamic> json) {
    return TeriyaUser(
      id: json["id"],
      email: json["email"],
      fullName: json["full_name"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      onboardingFinishedAt: json["onboarding_finished_at"] != null
          ? DateTime.parse(json["onboarding_finished_at"])
          : null,
    );
  }
}

class ConversationMessageReply {
  final String text;
  final String? action;

  ConversationMessageReply({required this.text, this.action});

  factory ConversationMessageReply.fromJson(Map<String, dynamic> json) {
    return ConversationMessageReply(text: json['text'], action: json['action']);
  }
}

class ConversationMessage {
  final int id;
  final String content;
  final ConversationMessageType messageType;
  final ConversationMessageSenderType senderType;
  final DateTime timestamp;
  final List<ConversationMessageReply>?
      quickReplies; // Optional: For quick reply options
  Duration? delay;

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
    List<dynamic> quickReplies = json['quick_replies'] ?? [];
    return ConversationMessage(
      id: json['id'],
      content: json['content'],
      messageType: ConversationMessageType.values.byName(json['content_type']),
      senderType: json['user_id'] != null
          ? ConversationMessageSenderType.user
          : ConversationMessageSenderType.ally,
      timestamp: DateTime.parse(json['created_at']),
      quickReplies: quickReplies
          .map((elem) => ConversationMessageReply.fromJson(elem))
          .toList(),
      delay: json.containsKey("delay")
          ? Duration(milliseconds: json['delay'])
          : const Duration(milliseconds: 0),
    );
  }
}

class Conversation {
  final String id;
  final List<ConversationMessage> messages;
  final ConversationType conversationType;

  Conversation({
    required this.id,
    required this.messages,
    required this.conversationType,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<dynamic> messages = json['messages'];

    return Conversation(
      id: json['id'],
      messages:
          messages.map((elem) => ConversationMessage.fromJson(elem)).toList(),
      conversationType: ConversationType.values.byName(json['type']),
    );
  }

  void addMessage(ConversationMessage message) {
    messages.add(message);
  }

  void removeMessage(int messageId) {
    messages.removeWhere((msg) => msg.id == messageId);
  }
}

class Course {
  final int id;
  final String name;
  final String major;
  final MajorIconData majorIconData;
  final List<CourseDocument>? documents;
  final List<CourseChapter>? chapters;

  Course({
    required this.id,
    required this.name,
    required this.major,
    required this.majorIconData,
    List<CourseDocument>? documents,
    List<CourseChapter>? chapters,
  })  : documents = documents ?? [],
        chapters = chapters ?? [];

  factory Course.fromJson(Map<String, dynamic> json) {
    List<dynamic> documentsJson = json['documents'] ?? [];
    List<dynamic> chaptersJson = json['chapters'] ?? [];
    return Course(
      id: json['id'],
      name: json['name'],
      major: json['major'],
      majorIconData: majorIconsMap[json['major'].toString().toLowerCase()] ??
          MajorIconData.raw(),
      documents:
          documentsJson.map((elem) => CourseDocument.fromJson(elem)).toList(),
      chapters:
          chaptersJson.map((elem) => CourseChapter.fromJson(elem)).toList(),
    );
  }
}

class CourseDocument {
  final int id;
  final String name;
  final String path;
  final String documentType;
  final int courseId;
  final bool processed;

  CourseDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.documentType,
    required this.processed,
    required this.courseId,
  });

  factory CourseDocument.fromJson(Map<String, dynamic> json) {
    return CourseDocument(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      courseId: json['course_id'],
      documentType: json['document_type'],
      processed: json['processed'],
    );
  }
}

class CourseChapter {
  final int id;
  final int courseId;
  final String name;
  final String description;
  final int order;
  final String heroImageUrl;
  final List<String> documents;

  CourseChapter({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.order,
    required this.documents,
    required this.heroImageUrl,
  });

  factory CourseChapter.fromJson(Map<String, dynamic> json) {
    return CourseChapter(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      description: json['description'],
      order: json['order'],
      heroImageUrl: json['hero_image_url'],
      documents: List<String>.from(json['documents']),
    );
  }
}

class CourseChapterSection {
  final String title;
  final String content;

  CourseChapterSection({
    required this.title,
    required this.content,
  });

  factory CourseChapterSection.fromJson(Map<String, dynamic> json) {
    return CourseChapterSection(
      title: json['title'],
      content: json['text'],
    );
  }
}
