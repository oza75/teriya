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
  bool _showTyping = true;

  @override
  void initState() {
    super.initState();
    _internalScrollController = widget.scrollController ?? ScrollController();
    _fetchConversationFuture =
        Provider.of<ConversationService>(context, listen: false)
            .fetchConversation(widget.conversationId)
            .then((res) {
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
              int total = service.currentConversation!.messages.length;
              total = widget.topChild != null ? total + 1 : total;
              total = _showTyping ? total + 1 : total;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _internalScrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: total,
                      itemBuilder: (context, index) {
                        if (index == 0 && widget.topChild != null) {
                          return widget.topChild!;
                        }

                        if (index == (total - 1) && _showTyping) {
                          return _buildTypingIndicator();
                        }

                        int mIndex =
                            widget.topChild != null ? index - 1 : index;
                        return ChatConversationMessage(
                          message:
                              service.currentConversation!.messages[mIndex],
                        );
                      },
                    ),
                  ),
                  if (widget.showInput == true)
                    ChatConversationMessageInput(onSend: (String text) {
                      print("text: $text");
                    })
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
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    var delay = widget.message.delay;
    if (delay == null) {
      setState(() {
        _isVisible = true;
      });
    } else {
      Future.delayed(widget.message.delay!, () {
        if (mounted) {
          setState(() {
            _isVisible = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = widget.message.senderType == SenderType.user;
    return !_isVisible
        ? const SizedBox(
            height: 0,
            width: 0,
          )
        : Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin:
                  EdgeInsets.fromLTRB(isUser ? 40 : 14, 5, isUser ? 14 : 40, 5),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color.fromRGBO(29, 78, 216, 1)
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
          );
  }
}

class ChatConversationMessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool? readOnly;

  const ChatConversationMessageInput({
    super.key,
    required this.onSend,
    this.readOnly = false,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                  readOnly: true,
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
