import 'package:flutter/cupertino.dart';

class ImageFadeAnimation extends StatefulWidget {
  final List<String> imageList;
  final Duration fadeDuration;
  final Duration changeInterval;

  // Constructor with default values for durations
  const ImageFadeAnimation({
    super.key,
    required this.imageList,
    this.fadeDuration = const Duration(seconds: 3),
    this.changeInterval = const Duration(seconds: 10),
  });

  @override
  ImageFadeAnimationState createState() => ImageFadeAnimationState();
}

class ImageFadeAnimationState extends State<ImageFadeAnimation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Schedule the image change with initial delay
    Future.delayed(widget.changeInterval, _changeImage);
  }

  void _changeImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.imageList.length;
    });
    Future.delayed(widget.changeInterval, _changeImage); // Keep looping
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.fadeDuration, // Duration of the fade animation
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: Container(
        key: ValueKey<int>(_currentIndex),
        // Key is important for AnimatedSwitcher to work
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.imageList[_currentIndex]),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(0, 0, 0, 0.2), // Your RGBA color filter
              BlendMode.darken,
            ),
          ),
        ),
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
