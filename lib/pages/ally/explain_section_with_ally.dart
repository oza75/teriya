import 'package:Teriya/components/chat_conversation.dart';
import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/models.dart';
import 'package:Teriya/services/conversation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ExplainSectionWithAlly extends StatefulWidget {
  final CourseChapterSection section;
  final String language;

  const ExplainSectionWithAlly({
    super.key,
    required this.section,
    required this.language,
  });

  @override
  State<ExplainSectionWithAlly> createState() => _ExplainSectionWithAllyState();
}

class _ExplainSectionWithAllyState extends State<ExplainSectionWithAlly> {
  late Future<Conversation> _createConversationFuture;

  @override
  void initState() {
    super.initState();
    _createConversation();
  }

  void _createConversation() {
    setState(() {
      _createConversationFuture =
          Provider.of<ConversationService>(context, listen: false)
              .createNormalConversation()
              .catchError((err) {
        print(err);
        showSnackbar(
          context,
          const Text("Error while trying to explain."),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Explanation"),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _createConversationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: PlatformCircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrors(snapshot);
            } else {
              final conversation = snapshot.data!;
              return ChatConversation(
                conversationId: conversation.id,
                onConversationLoaded: () {
                  return {
                    "send_message":
                        "Can you explain deeply '${widget.section.title}' in '${widget.language}'"
                  };
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrors(snapshot) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Oups !",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Sorry, we had an error while trying to explain with Ally. We are already working to fix this asap !",
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
