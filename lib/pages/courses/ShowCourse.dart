import 'dart:io';

import 'package:Teriya/pages/courses/CourseDocumentsList.dart';
import 'package:Teriya/pages/courses/ShowChapter.dart';
import 'package:Teriya/screens/courses.dart';
import 'package:Teriya/services/auth_service.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/services/socket_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../components/feedback.dart';
import '../../models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowCourse extends StatefulWidget {
  final int courseId;

  const ShowCourse({super.key, required this.courseId});

  @override
  State<ShowCourse> createState() => _ShowCourseState();
}

class _ShowCourseState extends State<ShowCourse> {
  late Future<Course> fetchCourseFuture;
  final List<String> fetchCourseEvents = [
    'processing-documents.end',
    'processing-documents.finished-one',
    'processing-documents.error-removed',
    'chapters.generated'
  ];

  Course? course;
  bool _isLoading = true;
  bool _hasErrors = false;
  bool _isProcessing = false;
  late final IO.Socket socket;
  late final TeriyaUser user;

  @override
  void initState() {
    super.initState();
    _fetchCourse();
    user = Provider.of<AuthService>(context, listen: false).user!;
    socket = Provider.of<SocketService>(context, listen: false).socket;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenRealtimeEvents();
    });
  }

  @override
  void dispose() {
    _unsubscribeRealtimeEvents();
    super.dispose();
  }

  void _fetchCourse() {
    print('should fetch course ...');
    setState(() => _hasErrors = false);
    Provider.of<CourseService>(context, listen: false)
        .fetchCourse(widget.courseId)
        .then((res) {
      if (mounted) {
        setState(() {
          course = res;
          _isProcessing = res.documents?.any((doc) => !doc.processed) ?? false;
          _isLoading = false;
          _hasErrors = false;
        });
      }
      return res;
    }).catchError((err) {
      print(err);
      if (mounted) {
        setState(() {
          _hasErrors = true;
          _isLoading = false;
        });
      }
      return err;
    });
  }

  void _listenRealtimeEvents() async {
    var eventPrefix = "users.${user.id}.courses.${widget.courseId}";

    for (var event in fetchCourseEvents) {
      socket.on("$eventPrefix.$event", (_) => _fetchCourse());
    }

    socket.on(
      "$eventPrefix.processing-documents.error",
      (_) => showSnackbar(
        context,
        const Text("Error while processing one document..."),
      ),
    );
  }

  void _unsubscribeRealtimeEvents() {
    var eventPrefix = "users.${user.id}.courses.${widget.courseId}";

    for (var event in fetchCourseEvents) {
      socket.off("$eventPrefix.$event");
    }

    socket.off("$eventPrefix.processing-documents.error");
  }

  void _reGenerateChapters() {
    Provider.of<CourseService>(context, listen: false)
        .reGenerateChapters(widget.courseId)
        .then((res) {
      if (mounted) {
        setState(() {
          course?.chapters = [];
          _isProcessing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          course?.name ?? AppLocalizations.of(context)!.course_title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailingActions: course != null
            ? [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.square_pencil),
                  onPressed: () => Navigator.push(
                    context,
                    customPlatformPageRoute(
                      builder: (context) => UpdateCourse(
                        course: course!,
                        onUpdate: (course) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            customPlatformPageRoute(
                              builder: (context) =>
                                  ShowCourse(courseId: course.id),
                            ),
                          ).then((_) => _fetchCourse());
                        },
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: PlatformCircularProgressIndicator())
            : (_hasErrors ? _buildErrors() : _buildCourseContent()),
      ),
    );
  }

  Widget _buildErrors() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Oups !",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.course_fetch_error_desc,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
              child: Text(
                AppLocalizations.of(context)!.course_fetch_try_again_btn,
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _fetchCourse();
              })
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Image.asset(
              "assets/images/illustrations/empty_documents.png",
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.course_no_chapters_title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.course_no_chapters_desc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 30),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.add),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.course_no_chapters_add_btn,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  customPlatformPageRoute(
                    builder: (context) => CourseDocumentList(course: course!),
                  ),
                ).then((_) => _fetchCourse());
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent() {
    final hasDocuments = (course?.documents ?? []).isNotEmpty;
    final hasChapters = (course?.chapters ?? []).isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DocumentsCard(
          documents: course!.documents ?? [],
          course: course!,
          onTap: () {
            Navigator.push(
              context,
              customPlatformPageRoute(
                  builder: (context) => CourseDocumentList(course: course!)),
            ).then((_) => _fetchCourse());
          },
        ),
        if (_isProcessing || (!_isProcessing && hasDocuments && !hasChapters))
          const Padding(
            padding: EdgeInsets.only(top: 90),
            child: ProcessingWidget(),
          )
        else if (!hasChapters)
          Flexible(child: _buildEmptyState())
        else
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.course_chapters_title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _reGenerateChapters,
                        child: const Icon(
                          CupertinoIcons.refresh,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ChapterListing(
                      chapters: course!.chapters ?? [],
                      onRemove: (chapter) {},
                      onTap: (chapter) {
                        Navigator.push(
                          context,
                          customPlatformPageRoute(
                              builder: (context) =>
                                  ShowChapter(chapter: chapter)),
                        ).then((_) => _fetchCourse());
                      }),
                ),
              ],
            ),
          )
      ],
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
                  Text(
                    AppLocalizations.of(context)!.course_documents_title,
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
                        ? AppLocalizations.of(context)!
                            .course_documents_processing_title(
                            processing.length,
                          )
                        : AppLocalizations.of(context)!
                            .course_documents_processing_active_desc(
                            documents.length,
                          ),
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
            if (processing.isNotEmpty)
              SizedBox(
                width: 25,
                height: 25,
                child: PlatformCircularProgressIndicator(),
              ),
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
          Text(
            AppLocalizations.of(context)!.course_processing_title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.course_processing_desc,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
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
              title: Text(
                AppLocalizations.of(context)!
                    .course_chapters_deletion_confirm_title,
              ),
              content: Text(
                AppLocalizations.of(context)!
                    .course_chapters_deletion_confirm_desc,
              ),
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.of(context)!
                        .course_chapters_deletion_cancel_btn,
                  ),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    AppLocalizations.of(context)!
                        .course_chapters_deletion_confirm_btn,
                  ),
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
        Text(
          AppLocalizations.of(context)!.course_chapters_deleted_feedback,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
