import 'package:Teriya/services/course_service.dart';
import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'services/conversation_service.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ConversationService>(
          create: (_) => ConversationService(),
        ),
        ChangeNotifierProvider<CourseService>(
          create: (_) => CourseService(),
        ),
      ],
      child: TeriyaApp(),
    );
  }
}

class TeriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    print("building teriya app!");
    return CupertinoApp.router(
      routerConfig: appRouter.router,
      title: "Teriya",
      theme: const CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}

void main() {
  runApp(const AppEntryPoint());
}
