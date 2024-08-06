import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:Teriya/pages/courses/ChapterDocumentsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

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
            .chapterSections(widget.chapter);
      });
    }
  }

  void _moveToNextSection() {
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
                final sectionWidgets = sections.indexed
                    .map<Widget>((item) => ChapterSection(
                          section: item.$2,
                          disabled: item.$1 > _currentSection,
                          active: item.$1 == _currentSection &&
                              item.$1 < sections.length - 1,
                          onNext: _moveToNextSection,
                        ))
                    .toList();

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

  Widget _buildTextHeader(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ChapterSection extends StatelessWidget {
  final CourseChapterSection section;
  final bool disabled;
  final bool active;
  final Function() onNext;

  const ChapterSection({
    super.key,
    required this.section,
    required this.disabled,
    required this.active,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return disabled ? _buildDisabled() : _buildEnabled();
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

  Widget _buildEnabled() {
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
              if (active)
                CupertinoButton(
                  color: Colors.orange,
                  onPressed: onNext,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  child: const Row(
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.navigate_next),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
