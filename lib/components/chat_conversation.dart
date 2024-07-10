import 'dart:ui';

import 'package:Teriya/components/delayed_visibility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/conversation_service.dart';

class ChatConversation extends StatefulWidget {
  final String conversationId;
  final Widget? topChild;
  final ScrollController? scrollController;
  final bool? showInput;
  final Function()? onConversationLoaded;

  const ChatConversation({
    super.key,
    required this.conversationId,
    this.topChild,
    this.scrollController,
    this.showInput = true,
    this.onConversationLoaded,
  });

  @override
  State<ChatConversation> createState() => _ChatConversationState();
}

class _ChatConversationState extends State<ChatConversation> {
  late Future<void> _fetchConversationFuture;
  late ScrollController _internalScrollController;
  bool _showTyping = false;

  @override
  void initState() {
    super.initState();
    _internalScrollController = widget.scrollController ?? ScrollController();
    _fetchConversationFuture =
        Provider.of<ConversationService>(context, listen: false)
            .loadConversation(widget.conversationId)
            .then((conversation) {
      if (conversation.messages.isEmpty) {
        _sendMessage();
      }

      if (widget.onConversationLoaded != null) {
        widget.onConversationLoaded!();
      }
    });
  }

  @override
  void dispose() {
    // Only dispose the internal controller if it's not provided externally
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    super.dispose();
  }

  void _sendMessage([String? text]) {
    setState(() => _showTyping = true);

    Provider.of<ConversationService>(context, listen: false)
        .sendMessage(text)
        .then((res) {
      setState(() => _showTyping = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchConversationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CupertinoActivityIndicator(
            color: CupertinoColors.black, // Loader color
            radius: 14,
          ));
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error loading conversation: ${snapshot.error}"),
          );
        } else {
          return Consumer<ConversationService>(
            builder: (context, service, child) {
              var mListReversed =
                  service.currentConversation!.messages.reversed.toList();
              int total = service.currentConversation!.messages.length;
              total = widget.topChild != null ? total + 1 : total;
              total = _showTyping ? total + 1 : total;
              return Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        controller: _internalScrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount: total,
                        reverse: true,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index == total - 1 && widget.topChild != null) {
                            return widget.topChild!;
                          }

                          if (index == 0 && _showTyping) {
                            return _buildTypingIndicator();
                          }

                          int mIndex = _showTyping ? index - 1 : index;
                          var message = mListReversed[mIndex];
                          return ChatConversationMessage(
                            key: ValueKey("conversation-message-${message.id}"),
                            message: message,
                          );
                        },
                      ),
                    ),
                  ),
                  if (widget.showInput == true)
                    ChatConversationMessageInput(
                      onSend: _sendMessage,
                      quickReplies: service.lastMessage?.quickReplies,
                      quickRepliesDelay: service.lastMessage?.delay != null
                          ? service.lastMessage!.delay! +
                              const Duration(milliseconds: 1000)
                          : null,
                    )
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Lottie.asset("assets/animations/lottie_typing.json", width: 50),
      ),
    );
  }
}

class ChatConversationMessage extends StatefulWidget {
  final ConversationMessage message;

  const ChatConversationMessage({super.key, required this.message});

  @override
  State<ChatConversationMessage> createState() =>
      _ChatConversationMessageState();
}

class _ChatConversationMessageState extends State<ChatConversationMessage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isUser =
        widget.message.senderType == ConversationMessageSenderType.user;
    return DelayedVisibility(
      delay: widget.message.delay,
      onAfter: () => widget.message.delay = null,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(isUser ? 40 : 14, 5, isUser ? 14 : 40, 5),
          decoration: BoxDecoration(
            color: isUser
                ? CupertinoColors.activeBlue
                : const Color.fromRGBO(245, 246, 250, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.message.content,
            style: TextStyle(
              fontSize: 16,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatConversationMessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool? readOnly;
  final List<String>? quickReplies;
  final Duration? quickRepliesDelay;

  const ChatConversationMessageInput({
    super.key,
    required this.onSend,
    this.readOnly = false,
    this.quickReplies,
    this.quickRepliesDelay,
  });

  @override
  State<ChatConversationMessageInput> createState() =>
      _ChatConversationMessageInputState();
}

class _ChatConversationMessageInputState
    extends State<ChatConversationMessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear(); // Clear the input field after message is sent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (widget.quickReplies != null && widget.quickReplies!.isNotEmpty)
              DelayedVisibility(
                delay: widget.quickRepliesDelay,
                child: _buildQuickReplies(),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // Placeholder for file upload functionality
                    },
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      readOnly: widget.readOnly ?? false,
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5,
                      // Allows text field to expand up to 5 lines
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSubmitted,
                      placeholder: "Type your message here...",
                      placeholderStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Background color of the text field
                        borderRadius: BorderRadius.circular(12.0),
                        // Rounded corners
                        border: Border.all(
                          color: Colors.grey[300] as Color,
                        ), // Removes default underline on iOS
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.end,
          children: widget.quickReplies!
              .map((reply) => CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: CupertinoColors.activeBlue,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Text(reply,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        )),
                    onPressed: () => _handleSubmitted(reply),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}