import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../screens/courses.dart';

class ChatActions {
  static const String addCourse = 'ADD_COURSE';
  static const String redirectHome = 'REDIRECT_HOME';
}

typedef ChatActionWidgetConstructor = Widget Function({
  Function(dynamic)? onFinish,
  Function? onClose,
});

Map<String, ChatActionWidgetConstructor> chatActionWidgets = {
  ChatActions.addCourse: ({
    Function(dynamic)? onFinish,
    Function? onClose,
  }) =>
      CreateCourse(onAdd: onFinish)
};

Map<String, String> chatActionRedirects = {
  ChatActions.redirectHome: 'home',
};
