import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../components/select_picker.dart';
import '../models.dart';
import '../services/course_service.dart';

class AddCourseWidget extends StatefulWidget {
  final Function(Course)? onAdd;

  const AddCourseWidget({this.onAdd, super.key});

  @override
  State<AddCourseWidget> createState() => _AddCourseWidgetState();
}

class _AddCourseWidgetState extends State<AddCourseWidget> {
  final TextEditingController _courseNameController = TextEditingController();
  String? _selectedMajor;
  bool _submitting = false;
  List<File> documents = [];
  final List<String> majors = ['Biology', 'Computer Science', 'Economics'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add a New Course'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView(
            children: [
              _buildCourseNameInput(),
              _buildMajorSelector(),
              _buildDocumentPicker(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseNameInput() {
    final brightness = CupertinoTheme.brightnessOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Course Name",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _courseNameController,
            placeholder: 'E.g., BIO 82 – Genetics',
            padding: const EdgeInsets.all(16),
            clearButtonMode: OverlayVisibilityMode.editing,
            decoration: BoxDecoration(
              color: brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMajorSelector() {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Major",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          PlatformDependentPicker(
            items: majors,
            onSelectedItemChanged: (index) {
              setState(() => _selectedMajor = majors[index]);
            },
            child: Text(
              _selectedMajor ?? "Choose a Major",
              style: TextStyle(
                color: isDarkTheme ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPicker() {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents (optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text(
            'Upload any relevant materials such as PDFs, videos, or audio files. You can add more anytime.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? Colors.grey[200] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: [
              ..._buildDocumentPreviews(),
              const SizedBox(height: 20),
              _buildAddDocumentButton(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDocumentPreviews() {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return documents.map((file) {
      String fileName = file.path.split('/').last;
      IconData fileIcon = _getFileIcon(fileName);

      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  fileIcon,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.destructiveRed,
                  ),
                  onPressed: () => setState(() => documents.remove(file)),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  IconData _getFileIcon(String fileName) {
    String fileType = fileName.split('.').last.toLowerCase();
    switch (fileType) {
      case 'pdf':
        return CupertinoIcons.doc_on_doc; // Icon for PDF files
      case 'jpg':
      case 'jpeg':
      case 'png':
        return CupertinoIcons.photo; // Icon for image files
      case 'mp4':
      case 'avi':
      case 'mov':
        return CupertinoIcons.video_camera; // Icon for video files
      default:
        return CupertinoIcons.doc; // Default icon for other file types
    }
  }

  Widget _buildAddDocumentButton() {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return GestureDetector(
      onTap: _pickDocument,
      child: DottedBorder(
        color: CupertinoColors.systemGrey,
        radius: const Radius.circular(8),
        borderType: BorderType.RRect,
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.add,
                size: 28,
                color: isDarkTheme ? Colors.grey[200] : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                "Click here to upload documents.",
                style: TextStyle(
                  color: isDarkTheme ? Colors.grey[100] : Colors.grey[600],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        documents.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  Widget _buildSubmitButton() {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final isValid =
        _courseNameController.text.isNotEmpty && _selectedMajor != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton.filled(
        disabledColor: isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
        onPressed: isValid ? _submitForm : null,
        child: _submitting
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                'Add Course',
                style: TextStyle(
                  color: isValid ? Colors.white : Colors.grey[500],
                ),
              ),
      ),
    );
  }

  void _submitForm() {
    setState(() => _submitting = true);
    Provider.of<CourseService>(context, listen: false)
        .createCourse(
      _courseNameController.text,
      _selectedMajor!,
      documents,
    )
        .then((course) {
      // Optionally clear fields after successful submission
      _courseNameController.clear();
      setState(() {
        _selectedMajor = null;
        documents = [];
        _submitting = false;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Course has been added successfully!'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onAdd != null) {
                  widget.onAdd!(course);
                }
              },
            ),
          ],
        ),
      );
    }).catchError((err) {
      setState(() {
        _submitting = false;
      });
      throw err;
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    super.dispose();
  }
}
