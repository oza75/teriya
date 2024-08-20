import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:Teriya/pages/ally/explain_section_with_ally.dart';
import 'package:Teriya/pages/courses/ChapterDocumentsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models.dart';
import '../../services/course_service.dart';
import '../../utils.dart';
import 'activities.dart';

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
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness:
                  _isExpanded ? Brightness.dark : Brightness.light,
            ),
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
                                Text(AppLocalizations.of(context)!
                                    .course_chapter_nb_documents(
                                  widget.chapter.documents.length,
                                ))
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                customPlatformPageRoute(
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
                                  AppLocalizations.of(context)!
                                      .course_chapter_nb_sections(
                                    sections.length,
                                  ),
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

class ChapterSection extends StatefulWidget {
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
  State<ChapterSection> createState() => _ChapterSectionState();
}

class _ChapterSectionState extends State<ChapterSection> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.section.audioUrl != null) {
      setState(() {
        _player.setUrl(widget.section.audioUrl!);
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.disabled ? _buildDisabled() : _buildEnabled(context);
  }

  void onStartQuizz(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      context: context,
      builder: (content) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Quizz(
            questions: widget.section.activity!.questions,
            onFinish: () {
              Navigator.of(context).pop();
              widget.onNext(context);
            },
          ),
        );
      },
    );
  }

  void onStartSummary(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: SummaryActivity(
            section: widget.section,
            chapter: widget.chapter,
            onFinish: () {
              Navigator.of(context).pop();
              widget.onNext(context);
            },
          ),
        );
      },
    );
  }

  void _explainWithAlly(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      context: context,
      builder: (content) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: ExplainSectionWithAlly(
            section: widget.section,
            language: widget.chapter.language,
          ),
        );
      },
    );
  }

  Widget _buildDisabled() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        widget.section.title,
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
            widget.section.title,
            style: const TextStyle(
              fontSize: 23,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MarkdownBody(
            data: widget.section.content,
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
              if (widget.section.audioUrl != null)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red[100],
                  ),
                  child: StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;
                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return SizedBox(
                          width: 30,
                          height: 30,
                          child: PlatformCircularProgressIndicator(),
                        );
                      } else if (playing != true) {
                        return IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.red[800]),
                          iconSize: 30.0,
                          onPressed: _player.play,
                        );
                      } else if (processingState != ProcessingState.completed) {
                        return IconButton(
                          icon: Icon(Icons.pause, color: Colors.red[800]),
                          iconSize: 30.0,
                          onPressed: _player.pause,
                        );
                      } else {
                        return IconButton(
                          icon: Icon(Icons.replay, color: Colors.red[800]),
                          iconSize: 30.0,
                          onPressed: () => _player.seek(Duration.zero),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0XFFBFDBFE),
                ),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Symbols.quickreply),
                  color: const Color(0XFF3B82F6),
                  onPressed: () => _explainWithAlly(context),
                ),
              ),
              if (widget.active) const Spacer(),
              if (widget.active) _buildActionButton(context)
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final activity = widget.section.activity;
    var btnText = AppLocalizations.of(context)!.next;
    var btnAction = widget.onNext;

    if (activity != null && activity.type == SectionActivityTypes.quizz) {
      btnText = AppLocalizations.of(context)!.quiz;
      btnAction = onStartQuizz;
    } else if (activity != null &&
        activity.type == SectionActivityTypes.summary) {
      btnText = AppLocalizations.of(context)!.activity;
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
