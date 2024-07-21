import 'package:Teriya/screens/courses.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../models.dart';

class ShowCourse extends StatefulWidget {
  final int courseId;

  const ShowCourse({super.key, required this.courseId});

  @override
  State<ShowCourse> createState() => _ShowCourseState();
}

class _ShowCourseState extends State<ShowCourse> {
  late final Future<Course> fetchCourseFuture;

  @override
  void initState() {
    super.initState();
    fetchCourseFuture = Provider.of<CourseService>(context, listen: false)
        .fetchCourse(widget.courseId);
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
          return PlatformScaffold(
            appBar: PlatformAppBar(
              title: Text(course.name),
              trailingActions: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.square_pencil),
                  onPressed: () => Navigator.push(
                    context,
                    FadeTransitionPageRoute(
                      builder: (context) => UpdateCourse(course: course),
                    ),
                  ),
                ),
              ],
            ),
            body: const Center(
              child: Text("Course body"),
            ),
          );
        }
      },
    );
  }
}
