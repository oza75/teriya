import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool _welcomeView = true;
  bool _isLoading = false;
  double _heightFactor = 0.4;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
    return PlatformScaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final currentConversation =
        Provider.of<ConversationService>(context).currentConversation;
    if (!_welcomeView && (currentConversation?.messages.length ?? 0) >= 3) {
      setState(() {
        _heightFactor = 1;
      });
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height:
            MediaQuery.of(context).size.height * _heightFactor - bottomPadding,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 55),
              decoration: const BoxDecoration(color: CupertinoColors.white),
              child: _welcomeView
                  ? _buildWelcomeSection()
                  : ChatConversation(
                      conversationId: _conversationId!,
                      topChild: _buildTopChatIntroduction(context),
                      guidedConversation: true,
                      onConversationLoaded: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _heightFactor = 0.65;
                          });
                        });
                        return;
                      },
                    ),
            ),
            _buildTopBorderImage(),
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

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 14, right: 14, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeTitle(),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.onboarding_welcome_description,
            style: const TextStyle(
              fontSize: 18.0,
              height: 1.5,
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
        Text(
          AppLocalizations.of(context)!.onboarding_welcome,
          style: const TextStyle(
              fontSize: 36.0,
              color: CupertinoColors.darkBackgroundGray,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500),
        ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.sparkles,
                      color: Color.fromRGBO(227, 197, 114, 1.0)),
                  const SizedBox(width: 10),
                  Text(
                      AppLocalizations.of(context)!
                          .onboarding_welcome_meet_ally_btn,
                      style: const TextStyle(
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
