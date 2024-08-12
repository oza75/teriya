import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../components/feedback.dart';
import '../../models.dart';
import '../../services/course_service.dart';
import '../../utils.dart';

class Quizz extends StatefulWidget {
  final List<SectionActivityQuizzQuestion> questions;
  final Function() onFinish;

  const Quizz({
    super.key,
    required this.questions,
    required this.onFinish,
  });

  @override
  State<Quizz> createState() => _QuizzState();
}

class _QuizzState extends State<Quizz> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Material(
                color: platformScaffoldBackgroundColor(context),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: question.possibleAnswers.map((answer) {
                    final bool isCorrect = answer == question.solution;
                    final bool isSelected = answer == _selectedAnswer;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[500]!,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: ListTile(
                        tileColor: _answered
                            ? isCorrect
                                ? Colors.green.withOpacity(0.2)
                                : isSelected
                                    ? Colors.red.withOpacity(0.2)
                                    : null
                            : null,
                        title: Text(
                          answer,
                          textAlign: TextAlign.center,
                        ),
                        leading: _answered
                            ? isCorrect
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : isSelected
                                    ? const Icon(Icons.cancel,
                                        color: Colors.red)
                                    : null
                            : null,
                        onTap: () => onSelectAnswer(question, answer),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSelectAnswer(SectionActivityQuizzQuestion question, String answer) {
    // if (_answered) {
    //   return;
    // }

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          final passed = _selectedAnswer == question.solution;
          var actionText = "Next Question";
          var onPressed = onMoveToNextQuestion;

          if (_currentQuestionIndex == widget.questions.length - 1) {
            actionText = "Next";
            onPressed = widget.onFinish;
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.31,
              color: const Color(0XFF172554),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.cancel,
                        color: passed ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        passed ? "Correct" : "Incorrect",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explanation:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    question.explanation,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  if (passed) const SizedBox(height: 20),
                  if (passed)
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onPressed();
                        },
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }

  void onMoveToNextQuestion() {
    return setState(() {
      _currentQuestionIndex++;
      _answered = false;
      _selectedAnswer = null;
    });
  }
}

class SummaryActivity extends StatefulWidget {
  final CourseChapterSection section;
  final CourseChapter chapter;
  final Function() onFinish;

  const SummaryActivity({
    super.key,
    required this.section,
    required this.chapter,
    required this.onFinish,
  });

  @override
  State<SummaryActivity> createState() => _SummaryActivityState();
}

class _SummaryActivityState extends State<SummaryActivity> {
  bool _validating = false;
  SectionSummaryValidationResult? _result;

  void _validateSummary(File image) {
    setState(() => _validating = true);
    Provider.of<CourseService>(context, listen: false)
        .validateChapterSectionSummary(
      widget.chapter,
      widget.section,
      image,
    )
        .then((result) {
      setState(() {
        _validating = false;
        _result = result;
      });
    }).catchError((err) {
      setState(() {
        _validating = false;
      });
      showSnackbar(context, const Text("Error while validating..."));
    });
  }

  void _onRetry() {
    setState(() {
      _result = null;
      _validating = false;
    });
  }

  void _handleTakePicture() async {
    try {
      // Ensure the camera is available
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
       File file = File(photo.path); // Convert XFile to a File
        _validateSummary(file);
      } else {
        print('No photo captured.');
      }
    } catch (e) {
      // Handle any errors or exceptions
      print('Failed to take photo: $e');
    }
  }

  void _handleChoosePicture() async {
    try {
      // Create an instance of ImagePicker
      final ImagePicker picker = ImagePicker();

      // Open image gallery and allow user to pick an image
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      // Check if an image is selected
      if (image != null) {
        File file = File(image.path); // Convert XFile to a File
        _validateSummary(file);
      }
    } catch (e) {
      showSnackbar(context, const Text("Failed to load picture."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Summarize Activity"),
        trailingActions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: _result == null
            ? _buildSummarizeView(context)
            : _buildValidationView(context),
      ),
    );
  }

  Widget _buildSummarizeView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/animations/summarizing.json",
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 10),
          const Text(
            "Summarize",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Take a moment to write down a summary of '${widget.section.title}' using pen and paper. Once you're done, snap a picture and let Ally review your work.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (!_validating)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  onPressed: _handleTakePicture,
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt, color: CupertinoColors.activeBlue),
                      SizedBox(width: 4),
                      Text("Take Picture"),
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: _handleChoosePicture,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: CupertinoColors.activeBlue,
                      ),
                      SizedBox(width: 4),
                      Text("Choose Picture"),
                    ],
                  ),
                ),
              ],
            ),
          if (_validating)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Validating...",
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
                PlatformCircularProgressIndicator()
              ],
            )
        ],
      ),
    );
  }

  Widget _buildValidationView(BuildContext context) {
    final success = _result!.score >= 80;
    var btnText = "Next";
    var btnAction = widget.onFinish;
    if (!success) {
      btnText = "Retry";
      btnAction = _onRetry;
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          SizedBox(
            width: 180,
            height: 180,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 100,
                      color: Colors.grey[300],
                    ),
                    GaugeRange(
                      startValue: 0,
                      endValue: _result!.score,
                      color: success ? Colors.green : Colors.red,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Container(
                          child: Text(_result!.score.toString(),
                              style: TextStyle(
                                color: success ? Colors.green : Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ))),
                      angle: 90,
                      positionFactor: 0,
                    ),
                  ],
                )
              ],
            ),
          ),
          Text(
            success ? "Well Done!" : "Try Again!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: success ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _result!.feedback,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              ..._result!.points.take(3).map((point) {
                return Material(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: ListTile(
                      leading: Icon(
                        point.passed ? Icons.check_circle : Icons.cancel,
                        color: point.passed ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        point.title,
                        style: TextStyle(
                          color: point.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  onPressed: btnAction,
                  child: Text(btnText),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
