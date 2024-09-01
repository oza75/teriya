import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
    print("Locale: ${WidgetsBinding.instance.platformDispatcher.locale}");
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://aa45515bef744af966ec8e3618d00084@o4507878192578560.ingest.us.sentry.io/4507878195068928';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const AppEntryPoint()),
  );
}
