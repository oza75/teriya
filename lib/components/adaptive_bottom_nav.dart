import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveBottomNavItem {
  final IconData icon;
  final String label;
  final Widget page;

  AdaptiveBottomNavItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

class AdaptiveBottomNavBar extends StatefulWidget {
  final List<AdaptiveBottomNavItem> items;

  const AdaptiveBottomNavBar({
    super.key,
    required this.items,
  });

  @override
  State<AdaptiveBottomNavBar> createState() => _AdaptiveBottomNavBarState();
}

class _AdaptiveBottomNavBarState extends State<AdaptiveBottomNavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoTabScaffold()
        : _buildMaterialScaffold();
  }

  Widget _buildCupertinoTabScaffold() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 70,
        onTap: (index) {
          setState(() => currentPageIndex = index);
        },
        items: widget.items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (_) => (index == 0 || index == 1) && index == currentPageIndex
              ? Padding(
                  key: UniqueKey(),
                  padding: EdgeInsets.zero,
                  child: widget.items[index].page,
                )
              : widget.items[index].page,
        );
      },
    );
  }

  Widget _buildMaterialScaffold() {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) =>
            setState(() => currentPageIndex = index),
        selectedIndex: currentPageIndex,
        destinations: widget.items
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
      body: widget.items[currentPageIndex].page,
    );
  }
}
