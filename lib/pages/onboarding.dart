import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class MeetAllyOnboarding extends StatefulWidget {
  const MeetAllyOnboarding({super.key});

  @override
  State<MeetAllyOnboarding> createState() => _MeetAllyOnboardingState();
}

class _MeetAllyOnboardingState extends State<MeetAllyOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fromRelativeRect(
              rect: const RelativeRect.fromLTRB(0, 0, 0, 200),
              child: Image.asset(
                "assets/images/onboarding/study_illustration.webp",
                fit: BoxFit.cover,
              )),
          DraggableScrollableSheet(
            initialChildSize: 0.40, // Initial size of the scrollable sheet.
            minChildSize: 0.40,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 55),
                    decoration:
                        const BoxDecoration(color: CupertinoColors.white),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      controller: scrollController,
                      itemCount: 21,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          // Check if it's the first item
                          return _buildWelcomeSection();
                        }
                        return ListTile(title: Text('Item ${index - 1}'));
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/onboarding/onboarding_top_border.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome, ",
              style: TextStyle(
                  fontSize: 36.0,
                  color: CupertinoColors.darkBackgroundGray,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500)),
          const Text(
            "Aboubacar",
            style: TextStyle(
                fontSize: 36.0,
                color: CupertinoColors.activeBlue,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          const Text(
            "Scroll up to meet Ally, your personal guide and study pal.",
            style: TextStyle(
              fontSize: 18.0,
              color: CupertinoColors.darkBackgroundGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: CupertinoColors.activeBlue,
              // color: const Color.fromRGBO(29, 78, 216, 1),
              onPressed: () {
                // Implement what happens when you tap 'Meet Ally'
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    color: Color.fromRGBO(227, 197, 114, 1.0),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Meet Ally",
                    style: TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
