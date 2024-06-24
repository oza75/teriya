import 'services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'router.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
        create: (_) => AuthService(), child: TeriyaApp());
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
    );
  }
}

void main() {
  runApp(const AppEntryPoint());
}
