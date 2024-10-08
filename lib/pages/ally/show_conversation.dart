import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/chat_conversation.dart';
import '../../models.dart';

class ShowConversation extends StatefulWidget {
  final Conversation conversation;

  const ShowConversation({
    super.key,
    required this.conversation,
  });

  @override
  State<ShowConversation> createState() => _ShowConversationState();
}

class _ShowConversationState extends State<ShowConversation> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          widget.conversation.title ?? AppLocalizations.of(context)!.ally_new_conversation_title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: CupertinoColors.white,
      body: SafeArea(
        child: ChatConversation(
          conversationId: widget.conversation.id,
        ),
      ),
    );
  }
}
