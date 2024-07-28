import 'dart:io';

import 'package:Teriya/pages/courses/CourseDocumentsList.dart';
import 'package:Teriya/pages/courses/ShowChapter.dart';
import 'package:Teriya/screens/courses.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../components/feedback.dart';
import '../../models.dart';

class ShowCourse extends StatefulWidget {
  final int courseId;

  const ShowCourse({super.key, required this.courseId});

  @override
  State<ShowCourse> createState() => _ShowCourseState();
}

class _ShowCourseState extends State<ShowCourse> {
  late Future<Course> fetchCourseFuture;

  @override
  void initState() {
    super.initState();
    _fetchCourse();
  }

  void _fetchCourse() {
    if (mounted) {
      setState(() {
        fetchCourseFuture = Provider.of<CourseService>(context, listen: false)
            .fetchCourse(widget.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchCourseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: PlatformCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var course = snapshot.data!;
          var isProcessingDocuments =
              course.documents?.any((doc) => !doc.processed) ?? false;
          return PlatformScaffold(
            appBar: PlatformAppBar(
              title: Text(
                course.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailingActions: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.square_pencil),
                  onPressed: () => Navigator.push(
                    context,
                    FadeTransitionPageRoute(
                      builder: (context) => UpdateCourse(
                        course: course,
                        onUpdate: (course) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            FadeTransitionPageRoute(
                              builder: (context) =>
                                  ShowCourse(courseId: course.id),
                            ),
                          ).then((_) => _fetchCourse());
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DocumentsCard(
                  documents: course.documents ?? [],
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      FadeTransitionPageRoute(
                          builder: (context) =>
                              CourseDocumentList(course: course)),
                    ).then((_) => _fetchCourse());
                  },
                ),
                if (isProcessingDocuments)
                  const Padding(
                    padding: EdgeInsets.only(top: 90),
                    child: ProcessingWidget(),
                  )
                else
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            "Chapters",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ChapterListing(
                              chapters: course.chapters ?? [],
                              onRemove: (chapter) {},
                              onTap: (chapter) {
                                Navigator.push(
                                  context,
                                  FadeTransitionPageRoute(
                                      builder: (context) =>
                                          ShowChapter(chapter: chapter)),
                                ).then((_) => _fetchCourse());
                              }),
                        ),
                      ],
                    ),
                  )
              ],
            )),
          );
        }
      },
    );
  }
}

class DocumentsCard extends StatelessWidget {
  final List<CourseDocument> documents;
  final Course course;
  final Function() onTap;

  const DocumentsCard({
    super.key,
    required this.documents,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final processing = documents.where((doc) => !doc.processed);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: CupertinoColors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            )),
        child: Row(
          children: [
            Icon(
              Icons.folder,
              color: processing.isNotEmpty
                  ? Colors.blue[400]
                  : course.majorIconData.color,
              size: 50,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Documents",
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    processing.isNotEmpty
                        ? "Processing ${processing.length} documents..."
                        : "${documents.length} active documents",
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!processing.isNotEmpty)
              Icon(
                Icons.navigate_next,
                color: Colors.grey[400],
                size: 24,
              ),
            if (processing.isNotEmpty) PlatformCircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ProcessingWidget extends StatelessWidget {
  const ProcessingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingAnimation(),
          const Text(
            "Processing...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please wait while we are processing your files.",
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.inactiveGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return SizedBox(
      width: 160,
      height: 140,
      child: Lottie.asset("assets/animations/lottie_reading_document.json"),
    );
  }
}

class ChapterListing extends StatefulWidget {
  final List<CourseChapter> chapters;
  final Function(CourseChapter) onRemove;
  final Function(CourseChapter) onTap;

  const ChapterListing({
    super.key,
    required this.chapters,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<ChapterListing> createState() => _ChapterListingState();
}

class _ChapterListingState extends State<ChapterListing> {
  Future<bool> _confirmDismiss(DismissDirection direction) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this chapter?'),
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed with no action
  }

  void _onRemove(CourseChapter chapter) {
    Provider.of<CourseService>(context, listen: false)
        .deleteCourseChapter(chapter.courseId, chapter.id)
        .then((_) {
      widget.onRemove(chapter);
      showSnackbar(
        context,
        const Text(
          "Chapter removed !",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF3b82f6),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Platform.isAndroid
          ? Theme.of(context).scaffoldBackgroundColor
          : CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        itemCount: widget.chapters.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[300],
          height: 1,
        ),
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          return Dismissible(
            key: Key('chapter-${chapter.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: _confirmDismiss,
            onDismissed: (direction) {
              _onRemove(chapter);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              onTap: () {
                widget.onTap(chapter);
              },
              trailing: Icon(
                Icons.navigate_next,
                color: Colors.grey[300],
              ),
              title: Text(
                chapter.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                chapter.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.5,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
