import 'package:Teriya/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoadingSplashScreen extends StatefulWidget {
  const LoadingSplashScreen({super.key});

  @override
  LoadingSplashScreenState createState() => LoadingSplashScreenState();
}

class LoadingSplashScreenState extends State<LoadingSplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _opacity;

  @override
  void initState() {
    super.initState();
    animateLogo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        Provider.of<AuthService>(context, listen: false).getUser().then((user) {
          if (mounted) {
            context.goNamed(user != null ? 'home' : 'welcome');
          }
        }).catchError((res) {
          if (mounted) {
            context.goNamed('welcome');
          }
        });
      });
    });
  }

  void animateLogo() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener(_animationStatusListener);

    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _animationController!.forward();
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController!.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController!.removeStatusListener(_animationStatusListener);
      _animationController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
      child: FadeTransition(
        opacity: _opacity!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logos/logo_teriya.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 8),
            const Text(
              'Teriya',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Poppins',
                color: Color.fromRGBO(30, 58, 138, 1),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
