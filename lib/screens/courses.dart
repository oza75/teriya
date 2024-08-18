import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../components/select_picker.dart';
import '../models.dart';
import '../services/course_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseForm extends StatefulWidget {
  final String? initialCourseName;
  final String? initialMajor;
  final String? initialLanguage;
  final List<File>? initialDocuments;
  final Future<Course> Function(String, String, String, List<File>) onSubmit;
  final Function() onCancel;
  final bool editing;

  const CourseForm({
    super.key,
    this.initialCourseName,
    this.initialLanguage,
    this.initialMajor,
    this.initialDocuments,
    required this.onSubmit,
    required this.onCancel,
  }) : editing = initialCourseName != null;

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  late TextEditingController _courseNameController;
  late final Future<List<String>> majorsFuture;
  final List<String> supportedLanguages = ['french', 'english'];
  String? _selectedMajor;
  String? _language;
  List<File> documents = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    majorsFuture =
        Provider.of<CourseService>(context, listen: false).fetchMajors();
    _courseNameController =
        TextEditingController(text: widget.initialCourseName);
    _selectedMajor = widget.initialMajor;
    _language = widget.initialLanguage ?? supportedLanguages[0];
    documents = widget.initialDocuments ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          widget.editing
              ? AppLocalizations.of(context)!
                  .update_course_title(widget.initialCourseName!)
              : AppLocalizations.of(context)!.create_course_title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView(
            children: [
              _buildCourseNameInput(),
              if (!widget.editing) _buildCourseLanguageSelector(),
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
    // notify the ui that when value has changed
    _courseNameController.addListener(() => setState(() {}));
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.course_form_course_name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _courseNameController,
            placeholder:
                AppLocalizations.of(context)!.course_form_course_name_hint,
            padding: const EdgeInsets.all(12),
            clearButtonMode: OverlayVisibilityMode.editing,
            decoration: BoxDecoration(
              color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseLanguageSelector() {
    print("Language: $_language");
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.course_form_language,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          PlatformDependentPicker(
            items: supportedLanguages,
            itemLabel: (item) {
              return AppLocalizations.of(context)!.course_language(item);
            },
            hint: Text(
              AppLocalizations.of(context)!.course_form_language_hint,
              style: TextStyle(
                color: isDarkTheme ? Colors.white60 : Colors.black54,
              ),
            ),
            androidValue: _language,
            onSelectedItemChanged: (value) {
              var item = value is int ? supportedLanguages[value] : value;
              setState(() => _language = item);
            },
            iosSelectedItem: Text(
              _language != null
                  ? AppLocalizations.of(context)!.course_language(_language!)
                  : AppLocalizations.of(context)!.course_form_language_hint,
              style: TextStyle(
                color: isDarkTheme ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          )
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
          Text(
            AppLocalizations.of(context)!.course_form_major,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
              future: majorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: PlatformCircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  var majors = snapshot.data!;
                  return PlatformDependentPicker(
                    items: majors,
                    hint: Text(
                      AppLocalizations.of(context)!.course_form_major_hint,
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    androidValue: _selectedMajor,
                    onSelectedItemChanged: (value) {
                      var item = value is int ? majors[value] : value;
                      setState(() => _selectedMajor = item);
                    },
                    iosSelectedItem: Text(
                      _selectedMajor ??
                          AppLocalizations.of(context)!.course_form_major_hint,
                      style: TextStyle(
                        color:
                            isDarkTheme ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  );
                }
              })
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
          Text(AppLocalizations.of(context)!.course_form_documents,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.white : Colors.black,
              )),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.course_form_documents_description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? Colors.white70 : Colors.grey[500],
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
                AppLocalizations.of(context)!.course_form_documents_add_desc,
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
    final isValid = _courseNameController.text.isNotEmpty &&
        _selectedMajor != null &&
        _language != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoButton.filled(
        disabledColor: isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
        onPressed: isValid ? _submitForm : null,
        child: _submitting
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                widget.editing
                    ? AppLocalizations.of(context)!
                        .course_form_submit_update_btn
                    : AppLocalizations.of(context)!
                        .course_form_submit_create_btn,
                style: TextStyle(
                  color: isValid ? Colors.white : Colors.grey[500],
                ),
              ),
      ),
    );
  }

  void _submitForm() {
    setState(() => _submitting = true);
    widget
        .onSubmit(
      _courseNameController.text,
      _selectedMajor!,
      _language!,
      documents,
    )
        .then((course) {
      setState(() => _submitting = true);
    }).catchError((err) {
      setState(() => _submitting = false);
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    super.dispose();
  }
}

class CreateCourse extends StatelessWidget {
  final Function(dynamic)? onAdd;

  const CreateCourse({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return CourseForm(
      onSubmit: (name, major, language, documents) => _createCourse(
        context,
        name,
        language,
        major,
        documents,
      ),
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  Future<Course> _createCourse(
    BuildContext context,
    String name,
    String language,
    String major,
    List<File> documents,
  ) {
    return Provider.of<CourseService>(context, listen: false)
        .createCourse(name, language, major, documents)
        .then((course) {
      if (onAdd != null) {
        onAdd!(course);
      }
      return course;
    });
  }
}

class UpdateCourse extends StatelessWidget {
  final Course course;
  final Function(dynamic)? onUpdate;

  const UpdateCourse({super.key, required this.course, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return CourseForm(
        initialCourseName: course.name,
        initialMajor: course.major,
        initialDocuments: [],
        onSubmit: (name, major, language, documents) {
          return _updateCourse(
            context,
            name,
            major,
            documents,
          );
        },
        onCancel: () {
          Navigator.pop(context);
        });
  }

  Future<Course> _updateCourse(
    BuildContext context,
    String name,
    String major,
    List<File> documents,
  ) {
    return Provider.of<CourseService>(context, listen: false)
        .updateCourse(course, name, major, documents)
        .then((course) {
      if (onUpdate != null) {
        onUpdate!(course);
      }
      return course;
    });
  }
}
