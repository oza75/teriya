import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
        ChangeNotifierProvider<SocketService>(
          create: (_) => SocketService(),
        ),
      ],
      child: TeriyaApp(),
    );
  }
}

class TeriyaApp extends StatelessWidget {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    print("building teriya app!");
    return PlatformApp.router(
      routerConfig: appRouter.router,
      title: "Teriya",
      material: (context, pl) => MaterialAppRouterData(
        theme: ThemeData(brightness: Brightness.light),
      ),
      cupertino: (context, pl) => CupertinoAppRouterData(
        theme: const CupertinoThemeData(brightness: Brightness.light),
      ),
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
