import '../models.dart';
import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class ConversationService extends ChangeNotifier {
  final ApiService apiService = ApiService();
  Conversation? currentConversation;

  ConversationService() {
    final List<List<String>> messages = [
      // ['Hello Aboubacar, 👋 Welcome to Teriya !', 'ally'],
      [
        'I’m Ally, your personal guide and study pal 📚. I’m here to help you make the most of your learning experience.',
        'ally'
      ],
      // ['Nice to meet you!', 'user'],
      // [
      //   'My goal is to tailor your learning experience to your personal style. Whether you’re a visual learner, love listening, or prefer hands-on activities, I’ve got you covered.',
      //   'ally'
      // ],
      // [
      //   'Everyone has their own unique way of learning, and tapping into your personal learning style is the best guide to truly understanding new concepts quickly and deeply.',
      //   'ally'
      // ],
      // [
      //   'By understanding your learning preferences, I can customize your study sessions to be more effective and enjoyable. This approach not only helps you grasp concepts faster but also ensures that learning feels more like a discovery than a chore.',
      //   'ally'
      // ],
    ];

    currentConversation = Conversation(
      conversationId: 'test-conv',
      messages: messages.asMap().entries.map((entry) {
        List<String> elem = entry.value;
        int index = entry.key;
        return ConversationMessage(
          id: 'elem-$index',
          content: elem[0],
          messageType: MessageType.text,
          senderType: SenderType.values.byName(elem[1]),
          timestamp: DateTime.now(),
          delay: const Duration(milliseconds: 500)
        );
      }).toList(),
      conversationType: ConversationType.onboarding,
    );
  }

  Future<void> fetchConversation(String conversationId) {
    // return apiService.http.get('/conversations/{$conversationId}').then((res) {
    //   currentConversation = Conversation.fromJson(res.data);
    //   notifyListeners();
    // });
    return Future.delayed(const Duration(seconds: 1), () {});
  }

  Future<Conversation> createOnboardingConversation() {
    return Future.delayed(const Duration(seconds: 1), () {
      return Conversation(
        conversationId: 'test-conv',
        messages: currentConversation!.messages,
        conversationType: currentConversation!.conversationType,
      );
    });
  }
}
