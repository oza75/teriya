import 'package:Teriya/components/adaptive_bottom_nav.dart';
import 'package:Teriya/pages/ally/conversation_list.dart';
import 'package:Teriya/pages/courses/CourseList.dart';
import 'package:Teriya/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBottomNavBar(items: [
      AdaptiveBottomNavItem(
        icon: Icons.home,
        label: "Home",
        page: const Center(
          child: Text("Home page"),
        ),
      ),
      AdaptiveBottomNavItem(
        icon: CupertinoIcons.book,
        label: "Courses",
        page: const CourseList(),
      ),
      AdaptiveBottomNavItem(
        icon: Symbols.neurology,
        label: "Talk with Ally",
        page: const Center(
          child: ConversationList(),
        ),
      ),
      AdaptiveBottomNavItem(
        icon: Icons.person,
        label: "Profile",
        page: const Center(
          child: Text("Profile page"),
        ),
      ),
    ]);
  }
}
