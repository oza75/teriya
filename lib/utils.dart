import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class MajorIconData {
  final IconData icon;
  final Color bgColor;
  final Color color;

  MajorIconData({
    required this.icon,
    required this.bgColor,
    required this.color,
  });

  factory MajorIconData.raw() {
    return MajorIconData(
      icon: Symbols.book_2,
      bgColor: Colors.blue[200]!,
      color: Colors.blue[800]!,
    );
  }
}

Map<String, MajorIconData> majorIconsMap = {
  'biology': MajorIconData(
    icon: Symbols.genetics,
    bgColor: const Color(0xFFbbf7d0),
    color: const Color(0xFF166534),
  ),
  'computer science': MajorIconData(
    icon: Symbols.terminal,
    bgColor: const Color(0xFFe2e8f0),
    color: const Color(0xFF334155),
  ),
  'economic': MajorIconData(
    icon: Symbols.account_balance_wallet_rounded,
    bgColor: const Color(0xFFd1fae5),
    color: const Color(0xFF059669),
  ),
  'engineering': MajorIconData(
    icon: Symbols.engineering,
    bgColor: const Color(0xFFcffafe),
    color: const Color(0xFF0891b2),
  ),
  'mathematics': MajorIconData(
    icon: Symbols.calculate,
    bgColor: const Color(0xFFfce7f3),
    color: const Color(0xFF9d174d),
  ),
};

class FadeTransitionPageRoute extends PageRouteBuilder {
  final Function(BuildContext) builder;

  FadeTransitionPageRoute({required this.builder})
      : super(pageBuilder: (context, __, ___) => builder(context));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
