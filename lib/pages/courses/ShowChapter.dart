import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/pages/courses/ChapterDocumentsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../models.dart';
import '../../services/course_service.dart';
import '../../utils.dart';

class ShowChapter extends StatefulWidget {
  final CourseChapter chapter;

  const ShowChapter({
    super.key,
    required this.chapter,
  });

  @override
  State<ShowChapter> createState() => _ShowChapterState();
}

class _ShowChapterState extends State<ShowChapter> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<CourseChapterSection>> _sectionsFuture;
  int _currentSection = 0;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _isExpanded) {
        setState(() {
          _isExpanded = false;
        });
      } else if (_scrollController.offset <= 100 && !_isExpanded) {
        setState(() {
          _isExpanded = true;
        });
      }
    });
  }

  void _fetchSections() {
    if (mounted) {
      setState(() {
        _sectionsFuture = Provider.of<CourseService>(context, listen: false)
            .chapterSections(widget.chapter)
            .then((sections) {
          if (sections.isNotEmpty) {
            var lastPosition =
                sections.indexWhere((section) => !section.passed);
            _currentSection =
                lastPosition != -1 ? lastPosition : sections.length - 1;
          }
          setState(() {});
          return sections;
        });
      });
    }
  }

  void _moveToNextSection(BuildContext context, CourseChapterSection section) {
    Provider.of<CourseService>(context, listen: false)
        .updateChapterProgression(widget.chapter, section)
        .then((res) {
      section.passed = true;
    });

    setState(() {
      _currentSection += 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.offset + 300,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _reGenerateContents() {
    Provider.of<CourseService>(context, listen: false)
        .reGenerateChapterContents(widget.chapter);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              iconSize: 30,
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back,
                color: _isExpanded
                    ? Colors.white
                    : (Platform.isIOS
                        ? CupertinoColors.activeBlue
                        : Colors.black),
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.chapter.name,
                maxLines: _isExpanded ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _isExpanded ? Colors.white : Colors.black,
                  fontSize: _isExpanded ? 25 : 18,
                  fontWeight: _isExpanded ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              expandedTitleScale: 1,
              titlePadding: EdgeInsets.symmetric(
                vertical: _isExpanded ? 20 : 18,
                horizontal: _isExpanded ? 16 : 65,
              ),
              centerTitle: !_isExpanded,
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      widget.chapter.heroImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<CourseChapterSection>>(
              future: _sectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: PlatformCircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final sections = snapshot.data!;
                final sectionWidgets = sections.indexed.map<Widget>((item) {
                  var index = item.$1;
                  var section = item.$2;
                  return ChapterSection(
                    section: section,
                    chapter: widget.chapter,
                    disabled: index > _currentSection,
                    active:
                        index == _currentSection && index < sections.length - 1,
                    onNext: (context) => _moveToNextSection(
                      context,
                      section,
                    ),
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 100,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chapter.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0,
                            ),
                            child: Row(
                              children: [
                                const Icon(Symbols.article),
                                const SizedBox(width: 10),
                                Text(
                                  "${widget.chapter.documents.length} documents",
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                FadeTransitionPageRoute(
                                  builder: (context) => ChapterDocumentList(
                                    chapter: widget.chapter,
                                  ),
                                ),
                              ).then((_) => _fetchSections());
                            },
                          ),
                          const SizedBox(width: 30),
                          CupertinoButton(
                            disabledColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0,
                            ),
                            onPressed: null,
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.featured_video,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${sections.length} sections",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _reGenerateContents,
                                  child: const Icon(
                                    CupertinoIcons.refresh,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...sectionWidgets
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterSection extends StatelessWidget {
  final CourseChapterSection section;
  final CourseChapter chapter;
  final bool disabled;
  final bool active;
  final Function(BuildContext context) onNext;

  const ChapterSection({
    super.key,
    required this.section,
    required this.disabled,
    required this.active,
    required this.onNext,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return disabled ? _buildDisabled() : _buildEnabled(context);
  }

  void onStartQuizz(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (content) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Quizz(
            questions: section.activity!.questions,
            onFinish: () {
              Navigator.of(context).pop();
              onNext(context);
            },
          ),
        );
      },
    );
  }

  void onStartSummary(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: SummaryActivity(
            section: section,
            chapter: chapter,
            onFinish: () {
              Navigator.of(context).pop();
              onNext(context);
            },
          ),
        );
        return const Center(child: Text("Hello summary"));
      },
    );
  }

  Widget _buildDisabled() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        section.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 23,
          color: Colors.grey[400],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEnabled(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 23,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MarkdownBody(
            data: section.content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                height: 1.5,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red[100],
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(CupertinoIcons.play_rectangle_fill),
                  color: Colors.red[800],
                  onPressed: () {
                    // Handle play button press
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0XFFBFDBFE),
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Symbols.neurology),
                  color: const Color(0XFF3B82F6),
                  onPressed: () {
                    // Handle another action
                  },
                ),
              ),
              if (active) const Spacer(),
              if (active) _buildActionButton(context)
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final activity = section.activity;
    var btnText = "Next";
    var btnAction = onNext;

    if (activity != null && activity.type == SectionActivityTypes.quizz) {
      btnText = "Quizz";
      btnAction = onStartQuizz;
    } else if (activity != null &&
        activity.type == SectionActivityTypes.summary) {
      btnText = "Activity";
      btnAction = onStartSummary;
    }

    return CupertinoButton(
      color: Colors.orange,
      onPressed: () => btnAction(context),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      child: Row(
        children: [
          Text(
            btnText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.navigate_next),
        ],
      ),
    );
  }
}

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
            'Question ${_currentQuestionIndex + 1}/${widget.questions.length}'),
        trailingActions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
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
              color: Colors.white,
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
                                  ? const Icon(Icons.cancel, color: Colors.red)
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

          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            height: MediaQuery.of(context).size.height * 0.3,
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
        // You can use the path of the photo for further processing
        print('Photo taken: ${photo.path}');
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
      showSnackbar(context, Text("Failed to load picture."));
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
      body: _result == null
          ? _buildSummarizeView(context)
          : _buildValidationView(context),
    );
  }

  Widget _buildSummarizeView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
      padding: EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
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
