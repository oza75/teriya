import 'package:Teriya/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hello world !'),
            CupertinoButton(
                child: const Text('Logout'),
                onPressed: () {
                  Provider.of<AuthService>(context, listen: false)
                      .logout()
                      .then((_) {
                    context.goNamed("welcome");
                  });
                })
          ],
        ),
      ),
    );
  }
}
