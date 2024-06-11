import 'package:flutter/cupertino.dart';
import 'services/auth/auth_service_abstract.dart';
import 'services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'router.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthServiceAbstract>(
        create: (_) => AuthService(), child: TeriyaApp());
  }
}

class TeriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServiceAbstract>(context);
    final appRouter = AppRouter(authService: authService);

    return CupertinoApp.router(
      routerConfig: appRouter.router,
      title: "Teriya",
      theme: const CupertinoThemeData(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const AppEntryPoint());
}
