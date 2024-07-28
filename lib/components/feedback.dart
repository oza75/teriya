import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CupertinoSnackbar extends StatefulWidget {
  final Widget message;
  final Duration duration;

  const CupertinoSnackbar({
    Key? key,
    required this.message,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<CupertinoSnackbar> createState() => _CupertinoSnackbarState();
}

class _CupertinoSnackbarState extends State<CupertinoSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Trigger haptic feedback as the snackbar starts to show
    HapticFeedback.lightImpact();

    // Schedule a callback for reverse animation
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animationController.reverse().whenComplete(() {
          if (mounted) {
            _animationController.dispose();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 1,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  // color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  )),
              alignment: Alignment.center,
              child: widget.message,
            ),
          ),
        ),
      ],
    );
  }
}

void showSnackbar(BuildContext context, Widget message) {
  if (Platform.isIOS) {
    showCupertinoSnackbar(context, message);
  } else {
    showAndroidSnackbar(context, message);
  }
}

void showCupertinoSnackbar(BuildContext context, Widget message) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => CupertinoSnackbar(message: message),
  );
  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

void showAndroidSnackbar(BuildContext context, Widget message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: message,
    duration: const Duration(seconds: 3),
  ));
}
