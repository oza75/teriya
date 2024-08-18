import 'dart:ffi';
import 'dart:io';

import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/pages/ally/show_conversation.dart';
import 'package:Teriya/services/conversation_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({super.key});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  late Future<List<Conversation>> _conversationsFuture;
  bool _creatingConversation = false;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  void _fetchConversations() {
    setState(() {
      _conversationsFuture =
          Provider.of<ConversationService>(context, listen: false)
              .fetchConversations()
              .catchError((err) {
        showSnackbar(
            context, const Text("Error while loading conversations..."));
        return err;
      });
    });
  }

  void _openConversation(Conversation conversation) {
    Navigator.of(context).push(customPlatformPageRoute(builder: (context) {
      return ShowConversation(conversation: conversation);
    })).then((_) {
      _fetchConversations();
    });
  }

  void _talkWithAlly() {
    setState(() => _creatingConversation = true);
    Provider.of<ConversationService>(context, listen: false)
        .createNormalConversation()
        .then((res) {
      _openConversation(res);
      setState(() => _creatingConversation = false);
    }).catchError((err) {
      print(err);
      setState(() => _creatingConversation = false);
      showSnackbar(context, const Text("Error while creating conversation !"));
    });
  }

  Future<bool> _confirmDismiss(DismissDirection direction) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              title: Text(
                AppLocalizations.of(context)!
                    .ally_conversations_deletion_confirm_title,
              ),
              content: Text(
                AppLocalizations.of(context)!
                    .ally_conversations_deletion_confirm_desc,
              ),
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.of(context)!
                        .ally_conversations_deletion_confirm_cancel_btn,
                  ),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    AppLocalizations.of(context)!
                        .ally_conversations_deletion_confirm_confirm_btn,
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed with no action
  }

  void _onRemove(Conversation conversation) {
    Provider.of<ConversationService>(context, listen: false)
        .deleteConversation(conversation)
        .then((_) {
      _fetchConversations();
      showSnackbar(
        context,
        Text(
          AppLocalizations.of(context)!.ally_conversations_deleted_feedback,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF3b82f6),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context)!.ally_conversations_title),
        trailingActions: Platform.isIOS
            ? [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _talkWithAlly,
                  child: const Icon(CupertinoIcons.add),
                )
              ]
            : [],
      ),
      material: (context, pl) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: _talkWithAlly,
        child: const Icon(Icons.add),
      )),
      body: SafeArea(
        child: FutureBuilder(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: PlatformCircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrors(snapshot);
            } else {
              final conversations = snapshot.data!;
              return conversations.length > 0
                  ? _buildConversationsListing(conversations)
                  : _buildEmptyView();
            }
          },
        ),
      ),
    );
  }

  Widget _buildConversationsListing(List<Conversation> conversations) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Dismissible(
            key: Key('conversation-${conversation.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: _confirmDismiss,
            onDismissed: (direction) {
              _onRemove(conversation);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _openConversation(conversation),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title ??
                          AppLocalizations.of(context)!
                              .ally_conversation_unnamed,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!
                          .ally_conversation_start_date(
                        "${conversation.createdAt.day}/${conversation.createdAt.month}/${conversation.createdAt.year}",
                      ),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
            color: Colors.grey[200],
          );
        },
        itemCount: conversations.length,
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/animations/lottie_bot.json",
            width: 150,
            height: 150,
          ),
          Text(
            AppLocalizations.of(context)!.ally_conversations_no_data_title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.ally_conversations_no_data_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            color: CupertinoColors.activeBlue,
            onPressed: _talkWithAlly,
            child: _creatingConversation
                ? PlatformCircularProgressIndicator()
                : Text(
                    AppLocalizations.of(context)!
                        .ally_conversations_no_data_btn,
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildErrors(AsyncSnapshot<List<Conversation>> snapshot) {
    print(snapshot.error);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Error while loading conversations"),
          CupertinoButton(
            child: Text("Retry!"),
            onPressed: () {
              _fetchConversations();
            },
          )
        ],
      ),
    );
  }
}
