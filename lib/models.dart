import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';

enum ConversationMessageType { text, image, video, link }

enum ConversationMessageSenderType { user, ally }

enum ConversationType { onboarding, normal }

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
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ConversationMessage> messages;
  final ConversationType conversationType;

  Conversation({
    required this.id,
    required this.messages,
    required this.conversationType,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<dynamic> messages = json['messages'] ?? [];

    return Conversation(
      id: json['id'],
      title: json['title'],
      messages:
          messages.map((elem) => ConversationMessage.fromJson(elem)).toList(),
      conversationType: ConversationType.values.byName(json['type']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final String language;
  final String major;
  final MajorIconData majorIconData;
  final List<CourseDocument>? documents;
  final List<CourseChapter>? chapters;

  Course({
    required this.id,
    required this.name,
    required this.major,
    required this.majorIconData,
    required this.language,
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
      language: json['language'],
      majorIconData: majorIconsMap[json['major'].toString().toLowerCase()] ??
          MajorIconData.raw(),
      documents:
          documentsJson.map((elem) => CourseDocument.fromJson(elem)).toList(),
      chapters: chaptersJson.map((elem) {
        elem['language'] = json['language'];
        return CourseChapter.fromJson(elem);
      }).toList(),
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
  final String language;
  final String description;
  final Course? course;
  final double? progress;
  final int order;
  final String heroImageUrl;
  final List<String> documents;

  CourseChapter({
    required this.id,
    required this.courseId,
    required this.name,
    required this.language,
    required this.description,
    required this.order,
    required this.documents,
    required this.heroImageUrl,
    this.course,
    this.progress,
  });

  factory CourseChapter.fromJson(Map<String, dynamic> json) {
    return CourseChapter(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      language: json['language'],
      description: json['description'],
      order: json['order'],
      heroImageUrl: json['hero_image_url'],
      documents: List<String>.from(json['documents']),
      course: (json.containsKey('course') && json['course'] != null)
          ? Course.fromJson(json['course'])
          : null,
      progress: json.containsKey('progress') ? json['progress'] : null,
    );
  }
}

enum SectionActivityTypes { quizz, summary }

class SectionActivityQuizzQuestion {
  final String question;
  final List<String> possibleAnswers;
  final String solution;
  final String explanation;

  SectionActivityQuizzQuestion({
    required this.question,
    required this.possibleAnswers,
    required this.solution,
    required this.explanation,
  });

  factory SectionActivityQuizzQuestion.fromJson(Map<String, dynamic> json) {
    return SectionActivityQuizzQuestion(
      question: json['question'],
      possibleAnswers: List<String>.from(json['possible_answers']),
      solution: json['solution'],
      explanation: json['explanation'],
    );
  }
}

class SectionActivity {
  final SectionActivityTypes type;
  final List<SectionActivityQuizzQuestion> questions;

  SectionActivity({
    required this.type,
    required this.questions,
  });

  factory SectionActivity.fromJson(Map<String, dynamic> json) {
    List<dynamic> questionsJson = json['questions'] ?? [];
    return SectionActivity(
      type: json['type'] == "quizz"
          ? SectionActivityTypes.quizz
          : SectionActivityTypes.summary,
      questions: questionsJson
          .map((item) => SectionActivityQuizzQuestion.fromJson(item))
          .toList(),
    );
  }
}

class CourseChapterSection {
  final String title;
  final String content;
  final SectionActivity? activity;
  bool passed = false;

  CourseChapterSection({
    required this.title,
    required this.content,
    required this.passed,
    this.activity,
  });

  factory CourseChapterSection.fromJson(Map<String, dynamic> json) {
    return CourseChapterSection(
      title: json['title'],
      content: json['content'],
      passed: json.containsKey("passed") ? json['passed'] : false,
      activity: (json.containsKey("activity") &&
              json["activity"] != null &&
              (json["activity"] as Map<String, dynamic>).isNotEmpty)
          ? SectionActivity.fromJson(json['activity'])
          : null,
    );
  }
}

class SectionSummaryValidationPoint {
  final String title;
  final bool passed;

  SectionSummaryValidationPoint({
    required this.title,
    required this.passed,
  });

  factory SectionSummaryValidationPoint.fromJson(Map<String, dynamic> json) {
    return SectionSummaryValidationPoint(
      title: json['title'],
      passed: json['passed'],
    );
  }
}

class SectionSummaryValidationResult {
  final List<SectionSummaryValidationPoint> points;
  final double score;
  final String feedback;

  SectionSummaryValidationResult({
    required this.points,
    required this.score,
    required this.feedback,
  });

  factory SectionSummaryValidationResult.fromJson(Map<String, dynamic> json) {
    List<dynamic> pointsJson = json['validation_points'];
    return SectionSummaryValidationResult(
      points: pointsJson
          .map((item) => SectionSummaryValidationPoint.fromJson(item))
          .toList(),
      score: json['score'],
      feedback: json['feedback'],
    );
  }
}
