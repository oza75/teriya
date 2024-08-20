import 'dart:io';

import 'package:Teriya/services/course_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import 'DocumentListing.dart';

class ChapterDocumentList extends StatefulWidget {
  final CourseChapter chapter;

  const ChapterDocumentList({super.key, required this.chapter});

  @override
  State<ChapterDocumentList> createState() => _ChapterDocumentListState();
}

class _ChapterDocumentListState extends State<ChapterDocumentList> {
  late Future<List<CourseDocument>> _documentsFutures;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  void _fetchDocuments() {
    if (mounted) {
      setState(() {
        _documentsFutures = Provider.of<CourseService>(context, listen: false)
            .fetchChapterDocuments(widget.chapter);
      });
    }
  }

  Future<void> _onUpload(List<File> files) {
    return Provider.of<CourseService>(context, listen: false)
        .addCourseDocument(widget.chapter.id, files);
  }

  @override
  Widget build(BuildContext context) {
    return DocumentListing(
      future: _documentsFutures,
      onFetchDocuments: _fetchDocuments,
      onUpload: _onUpload,
      title: widget.chapter.name,
    );
  }
}
