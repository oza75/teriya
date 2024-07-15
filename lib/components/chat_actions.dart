import 'package:flutter/cupertino.dart';

import '../screens/courses.dart';

class ChatActions {
  static const String addCourse = 'ADD_COURSE';
}

Map<String, Widget> chatActionWidgets = {
  ChatActions.addCourse: const AddCourseWidget(),
};
