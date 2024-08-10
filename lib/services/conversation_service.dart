import '../models.dart';
import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class ConversationService extends ChangeNotifier {
  final ApiService apiService = ApiService();
  Conversation? currentConversation;

  ConversationService() {}

  ConversationMessage? get lastMessage {
    if (currentConversation != null && currentConversation!.messages.isEmpty) {
      return null;
    }

    return currentConversation?.messages.last;
  }

  Future<Conversation> loadConversation(String conversationId) {
    return apiService.http.get('/conversations/$conversationId').then((res) {
      var conversation = Conversation.fromJson(res.data);
      currentConversation = conversation;
      notifyListeners();
      return conversation;
    });
  }

  Future<Conversation> createOnboardingConversation() {
    return apiService.http.post("/conversations/onboarding/create").then((res) {
      var conversation = Conversation.fromJson(res.data);
      return conversation;
    });
  }

  Future<Conversation> createNormalConversation() {
    return apiService.http.post("/conversations/create").then((res) {
      return Conversation.fromJson(res.data);
    });
  }

  void setCurrentConversation(Conversation conversation) {
    currentConversation = conversation;
    notifyListeners();
  }

  Future<void> sendMessage(String? input) async {
    if (currentConversation == null) {
      print("No current conversation set.");
      return;
    }

    if (input != null) {
      var pendingMessage = ConversationMessage(
        id: -1,
        content: input,
        messageType: ConversationMessageType.text,
        senderType: ConversationMessageSenderType.user,
        timestamp: DateTime.now(),
      );

      currentConversation!.messages.add(pendingMessage);
      notifyListeners();
    }

    return apiService.http
        .post(
      '/conversations/${currentConversation!.id}/messages',
      data: input != null ? {'input': input} : {},
    )
        .then((res) {
      // print("response: ${res.data}");
      List<dynamic> messagesData = res.data['messages'];

      List<ConversationMessage> newMessages = messagesData
          .map((msgJson) => ConversationMessage.fromJson(msgJson))
          .toList();

      // Remove the placeholder message
      currentConversation!.messages.removeWhere((m) => m.id == -1);

      currentConversation!.messages.addAll(newMessages);

      notifyListeners();
    });
  }

  Future<List<Conversation>> fetchConversations() {
    return apiService.http.get("/conversations").then((res) {
      List<dynamic> conversationsJson = res.data;
      return conversationsJson
          .map((item) => Conversation.fromJson(item))
          .toList();
    });
  }
}
