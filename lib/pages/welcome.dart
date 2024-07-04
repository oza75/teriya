import 'dart:io';
import 'dart:ui';

import 'package:Teriya/services/auth_service.dart';
import 'package:go_router/go_router.dart';

import '../components/image_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeriyaWelcomeScreen extends StatefulWidget {
  const TeriyaWelcomeScreen({super.key});

  @override
  TeriyaWelcomeScreenState createState() => TeriyaWelcomeScreenState();
}

class TeriyaWelcomeScreenState extends State<TeriyaWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(
            child: ImageFadeAnimation(imageList: [
              'assets/images/welcome_screen/pexels-mkvisuals-2781195.jpg',
              'assets/images/welcome_screen/pexels-polina-zimmerman-3747462.jpg',
              'assets/images/welcome_screen/pexels-tatianasyrikova-3975590.jpg',
            ]),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 1),
              const Text(
                'Teriya',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w900,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A new way to learn',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.white,
                ),
              ),
              const Spacer(flex: 3),
              CupertinoButton(
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset('assets/images/icons/g-logo.png', height: 24),
                    // Google logo image,
                    // Google logo image
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  authService.signInWithGoogle().then((user) {
                    context.goNamed("onboarding");
                  });
                },
              ),
              const SizedBox(height: 20),
              if (Platform.isAndroid)
                const Text("Register or Login with your Google Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: CupertinoColors.extraLightBackgroundGray,
                    )),
              if (!Platform.isAndroid)
                CupertinoButton(
                  color: CupertinoColors.black,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.apple, size: 24, color: CupertinoColors.white),
                      SizedBox(width: 12),
                      Text(
                        'Sign in with Apple',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    authService.signInWithApple().then((user) {
                      context.goNamed("onboarding");
                    });
                  },
                ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}
