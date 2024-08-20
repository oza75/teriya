import 'dart:io';

import 'package:Teriya/pages/courses/DocumentListing.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
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
    if (mounted) {
      setState(() {
        _documentsFutures = Provider.of<CourseService>(context, listen: false)
            .fetchCourseDocuments(widget.course.id);
      });
    }
  }

  Future<void> _onUpload(List<File> files) {
    return Provider.of<CourseService>(context, listen: false)
        .addCourseDocument(widget.course.id, files);
  }

  @override
  Widget build(BuildContext context) {
    return DocumentListing(
      future: _documentsFutures,
      onFetchDocuments: _fetchDocuments,
      onUpload: _onUpload,
      title: widget.course.name,
    );
  }
}
