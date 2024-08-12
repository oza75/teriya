import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../components/chat_conversation.dart';
import '../models.dart';
import '../services/conversation_service.dart';
import '../services/auth_service.dart';

class MeetAllyOnboarding extends StatefulWidget {
  const MeetAllyOnboarding({super.key});

  @override
  State<MeetAllyOnboarding> createState() => _MeetAllyOnboardingState();
}

class _MeetAllyOnboardingState extends State<MeetAllyOnboarding> {
  late final DraggableScrollableController _draggableController;

  bool _welcomeView = true;
  bool _isLoading = false;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  void _extendDraggableToFullSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_draggableController.isAttached && _draggableController.size < 1.0) {
        _draggableController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startOnboardingProcess() {
    setState(() => _isLoading = true);
    Provider.of<ConversationService>(context, listen: false)
        .createOnboardingConversation()
        .then((conversation) {
      setState(() {
        _conversationId = conversation.id;
        _welcomeView = false;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() => _isLoading = false);
      print("Error starting conversation: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoScaffold(
        body: Stack(
          children: [
            _buildBackgroundImage(),
            _buildDraggableScrollableSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fromRelativeRect(
      rect: const RelativeRect.fromLTRB(0, 0, 0, 200),
      child: Image.asset(
        "assets/images/onboarding/study_illustration.webp",
        fit: BoxFit.cover,
      ),
    );
  }

  DraggableScrollableSheet _buildDraggableScrollableSheet(
      BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.40,
      maxChildSize: 1.0,
      controller: _draggableController,
      builder: (BuildContext context, ScrollController scrollController) {
        return Consumer<ConversationService>(
          builder: (context, service, child) {
            var currentConversation = service.currentConversation;
            if (!_welcomeView &&
                (currentConversation?.messages.length ?? 0) >= 3) {
              _extendDraggableToFullSize();
            }
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 55),
                  decoration: const BoxDecoration(color: CupertinoColors.white),
                  child: _welcomeView
                      ? _buildWelcomeSection()
                      : ChatConversation(
                          conversationId: _conversationId!,
                          topChild: _buildTopChatIntroduction(context),
                          scrollController: scrollController,
                          guidedConversation: true,
                          onConversationLoaded: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _draggableController.animateTo(
                                0.65,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            });
                            return;
                          },
                        ),
                ),
                _buildTopBorderImage(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeTitle(),
          const SizedBox(height: 18),
          const Text(
            "Click below to meet Ally, your personal guide and study pal.",
            style: TextStyle(
              fontSize: 18.0,
              color: CupertinoColors.darkBackgroundGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          _buildMeetAllyButton(),
        ],
      ),
    );
  }

  Widget _buildWelcomeTitle() {
    final TeriyaUser? user = Provider.of<AuthService>(context).user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Welcome, ",
            style: TextStyle(
                fontSize: 36.0,
                color: CupertinoColors.darkBackgroundGray,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500)),
        Text(
          user!.firstName,
          style: const TextStyle(
              fontSize: 36.0,
              color: CupertinoColors.activeBlue,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildMeetAllyButton() {
    return SizedBox(
      width: double.infinity, // Ensures the button and loader take full width
      height: 52,
      child: _isLoading
          ? Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoColors.white, // Loader color
                  radius: 14,
                ),
              ),
            )
          : CupertinoButton(
              color: CupertinoColors.activeBlue,
              onPressed: _startOnboardingProcess,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.sparkles,
                      color: Color.fromRGBO(227, 197, 114, 1.0)),
                  SizedBox(width: 10),
                  Text("Meet Ally",
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildTopChatIntroduction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeTitle(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTopBorderImage() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/images/onboarding/onboarding_top_border.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
