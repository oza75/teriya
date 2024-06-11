import 'package:flutter/cupertino.dart';
import 'screens/welcome.dart';

class MyAwesomeApp extends StatelessWidget {
  const MyAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: "My Awesome App",
      theme: CupertinoThemeData(),
      home: TeriyaWelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Text('Hello world !'),
      ),
    );
  }
}

void main() {
  runApp(const MyAwesomeApp());
}
