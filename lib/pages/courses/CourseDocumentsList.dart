import 'dart:io';

import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../models.dart';

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
      showSnackbar(context, Text("Adding ${files.length} documents..."));

      Provider.of<CourseService>(context, listen: false)
          .addCourseDocument(widget.course.id, files)
          .then((res) {
        showSnackbar(context, Text("${files.length} documents added !"));
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
      body: FutureBuilder(
        future: _documentsFutures,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: PlatformCircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var documents = snapshot.data!;
            return DocumentListing(
              documents: documents,
              onRemove: (doc) {
                _fetchDocuments();
              },
            );
          }
        },
      ),
      material: (context, pl) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDocumentModal(context),
        child: const Icon(Icons.add),
      )),
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
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this document?'),
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

  void _onRemove(CourseDocument document) {
    Provider.of<CourseService>(context, listen: false)
        .deleteCourseDocument(document.courseId, document.id)
        .then((_) {
      widget.onRemove(document);
      showSnackbar(
        context,
        const Text(
          "Document removed !",
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
                  : PlatformCircularProgressIndicator(),
              title: Text(
                document.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(document.processed ? "Active" : "Processing..."),
            ),
          );
        },
      ),
    );
  }
}
