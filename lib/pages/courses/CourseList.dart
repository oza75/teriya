import 'dart:io';

import 'package:Teriya/models.dart';
import 'package:Teriya/pages/courses/ShowCourse.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../screens/courses.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  void fetchCourses() {
    setState(() {
      coursesFuture =
          Provider.of<CourseService>(context, listen: false).fetchCourses();
    });
  }

  void _showAddCourseModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: CreateCourse(
          onAdd: (course) {
            Navigator.pop(context);
            fetchCourses();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      key: UniqueKey(),
      appBar: PlatformAppBar(
        title: const Text("My courses"),
        trailingActions: Platform.isIOS
            ? [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () => _showAddCourseModal(context),
                ),
              ]
            : null,
      ),
      body: _buildCourseListing(),
      material: (context, pl) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseModal(context),
        child: const Icon(Icons.add),
      )),
    );
  }

  FutureBuilder<List<Course>> _buildCourseListing() {
    return FutureBuilder(
      future: coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: PlatformCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final courses = snapshot.data!;
          return Material(
            color: Platform.isAndroid
                ? Theme.of(context).scaffoldBackgroundColor
                : CupertinoTheme.of(context).scaffoldBackgroundColor,
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[300],
                height: 4,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: course.majorIconData.bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      course.majorIconData.icon,
                      size: 24,
                      color: course.majorIconData.color,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 24,
                    color: Colors.grey[500],
                  ),
                  title: Text(
                    course.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    course.major,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    FadeTransitionPageRoute(
                      builder: (context) => ShowCourse(courseId: course.id),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
