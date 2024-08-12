import 'package:Teriya/components/adaptive_bottom_nav.dart';
import 'package:Teriya/pages/accounts/user_account.dart';
import 'package:Teriya/pages/ally/conversation_list.dart';
import 'package:Teriya/pages/courses/CourseList.dart';
import 'package:Teriya/pages/home/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: AdaptiveBottomNavBar(items: [
        AdaptiveBottomNavItem(
          icon: Icons.home,
          label: "Home",
          page: const Home(),
        ),
        AdaptiveBottomNavItem(
          icon: CupertinoIcons.book,
          label: "Courses",
          page: const CourseList(),
        ),
        AdaptiveBottomNavItem(
          icon: Symbols.neurology,
          label: "Talk with Ally",
          page: const ConversationList(),
        ),
        AdaptiveBottomNavItem(
          icon: Icons.person,
          label: "Account",
          page: const UserAccount(),
        ),
      ]),
    );
  }
}
