import 'dart:async';

import 'package:flutter/cupertino.dart';

class DelayedVisibility extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Function()? onAfter;

  const DelayedVisibility({
    super.key,
    required this.child,
    this.delay,
    this.onAfter,
  });

  @override
  State<DelayedVisibility> createState() => _DelayedVisibilityState();
}

class _DelayedVisibilityState extends State<DelayedVisibility> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == null) {
      setState(() {
        _isVisible = true;
      });
    } else {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          setState(() {
            _isVisible = true;
          });
        }
      });
    }
    if (widget.onAfter != null) {
      widget.onAfter!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isVisible ? const SizedBox.shrink() : widget.child;
  }
}
