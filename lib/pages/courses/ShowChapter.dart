import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../models.dart';

class ShowChapter extends StatelessWidget {
  final CourseChapter chapter;

  const ShowChapter({
    super.key,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          chapter.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailingActions: Platform.isIOS
            ? [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.square_pencil),
                  onPressed: () {},
                )
              ]
            : [],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          chapter.description,
          textAlign: TextAlign.center,
        ),
      )),
    );
  }
}
