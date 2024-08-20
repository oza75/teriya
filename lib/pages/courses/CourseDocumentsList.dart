import 'dart:io';

import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseDocumentList extends StatefulWidget {
  final Course course;

  const CourseDocumentList({super.key, required this.course});

  @override
  State<CourseDocumentList> createState() => _CourseDocumentListState();
}

class _CourseDocumentListState extends State<CourseDocumentList> {
  late Future<List<CourseDocument>> _documentsFutures;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  void _fetchDocuments() {
    setState(() {
      _documentsFutures = Provider.of<CourseService>(context, listen: false)
          .fetchCourseDocuments(widget.course.id);
    });
  }

  void _showAddDocumentModal(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result != null) {
      var files = result.paths.map((path) => File(path!)).toList();
      showSnackbar(
        context,
        Text(AppLocalizations.of(context)!
            .course_documents_list_adding_feedback(files.length)),
      );

      Provider.of<CourseService>(context, listen: false)
          .addCourseDocument(widget.course.id, files)
          .then((res) {
        showSnackbar(
          context,
          Text(
            AppLocalizations.of(context)!
                .course_documents_list_added_feedback(files.length),
          ),
        );
        _fetchDocuments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          "Document: ${widget.course.name}",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailingActions: Platform.isIOS
            ? [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () => _showAddDocumentModal(context),
                )
              ]
            : [],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _documentsFutures,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: PlatformCircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              var documents = snapshot.data!;
              return documents.length == 0
                  ? _buildEmptyState()
                  : DocumentListing(
                      documents: documents,
                      onRemove: (doc) {
                        _fetchDocuments();
                      },
                    );
            }
          },
        ),
      ),
      material: (context, pl) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDocumentModal(context),
        child: const Icon(Icons.add),
      )),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Image.asset(
              "assets/images/illustrations/add_documents.png",
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.course_documents_list_no_data_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.course_documents_list_no_data_desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: Colors.grey[500],
              ),
            ),
            if (Platform.isIOS) const SizedBox(height: 20),
            if (Platform.isIOS)
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.up_arrow),
                    const SizedBox(width: 16),
                    Text(
                      AppLocalizations.of(context)!
                          .course_documents_list_no_data_upload_btn,
                      style: const TextStyle(fontSize: 15),
                    )
                  ],
                ),
                onPressed: () => _showAddDocumentModal(context),
              )
          ],
        ),
      ),
    );
  }
}

class DocumentListing extends StatefulWidget {
  final List<CourseDocument> documents;
  final Function(CourseDocument) onRemove;

  const DocumentListing({
    super.key,
    required this.documents,
    required this.onRemove,
  });

  @override
  State<DocumentListing> createState() => _DocumentListingState();
}

class _DocumentListingState extends State<DocumentListing> {
  Future<bool> _confirmDismiss(DismissDirection direction) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return PlatformAlertDialog(
              title: Text(
                AppLocalizations.of(context)!
                    .course_document_deletion_confirm_title,
              ),
              content: Text(
                AppLocalizations.of(context)!
                    .course_document_deletion_confirm_desc,
              ),
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.of(context)!
                        .course_document_deletion_cancel_btn,
                  ),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    AppLocalizations.of(context)!
                        .course_document_deletion_confirm_btn,
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed with no action
  }

  void _onRemove(CourseDocument document) {
    Provider.of<CourseService>(context, listen: false)
        .deleteCourseDocument(document.courseId, document.id)
        .then((_) {
      widget.onRemove(document);
      showSnackbar(
        context,
        Text(
          AppLocalizations.of(context)!.course_document_deleted_feedback,
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
        itemCount: widget.documents.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[300],
          height: 1,
        ),
        itemBuilder: (context, index) {
          final document = widget.documents[index];
          return Dismissible(
            key: Key('document-${document.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: _confirmDismiss,
            onDismissed: (direction) {
              _onRemove(document);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.file_copy_outlined,
                  size: 24,
                  color: Colors.grey[600],
                ),
              ),
              trailing: document.processed
                  ? Icon(
                      Icons.check_circle,
                      size: 24,
                      color: Colors.green[500],
                    )
                  : SizedBox(
                      width: 25,
                      height: 25,
                      child: PlatformCircularProgressIndicator(),
                    ),
              title: Text(
                document.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                document.processed
                    ? AppLocalizations.of(context)!.course_document_active
                    : AppLocalizations.of(context)!.course_document_processing,
              ),
            ),
          );
        },
      ),
    );
  }
}
