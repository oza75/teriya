import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/models.dart';
import 'package:Teriya/pages/courses/CourseList.dart';
import 'package:Teriya/pages/courses/ShowChapter.dart';
import 'package:Teriya/pages/home/random_quizz.dart';
import 'package:Teriya/services/auth_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/course_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<CourseChapter>> _fetchChaptersFutures;

  @override
  void initState() {
    super.initState();
    _fetchChapters();
  }

  void _fetchChapters() {
    setState(() {
      _fetchChaptersFutures = Provider.of<CourseService>(context, listen: false)
          .fetchUserChapters()
          .catchError((err) {
        showSnackbar(
          context,
          const Text("An error occured while fetching chapters"),
        );
        print(err);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return PlatformScaffold(
      backgroundColor: Colors.grey[100]!,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${user.firstName}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              _buildCalendarSection(),
              const SizedBox(height: 30),
              const Text(
                "Your progress",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildChaptersSection(),
              const SizedBox(height: 30),
              const Text(
                "Tests",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuizzesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesSection() {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0XFFe9d5ff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Tests your knowledge with some quizz."),
          const SizedBox(height: 20),
          CupertinoButton(
            color: Colors.black,
            child: const Text("Start"),
            onPressed: () {
              Navigator.of(context)
                  .push(customPlatformPageRoute(builder: (context) {
                return const RandomQuizz();
              })).then((_) => _fetchChapters());
            },
          )
        ],
      ),
    );
  }

  Widget _buildChaptersSection() {
    return FutureBuilder(
      future: _fetchChaptersFutures,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: PlatformCircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrors();
        } else {
          final chapters = snapshot.data!;
          return chapters.isNotEmpty
              ? _buildProgressionChapters(chapters)
              : _buildProgressionEmptyView();
        }
      },
    );
  }

  Widget _buildProgressionEmptyView() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange[200],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Add some documents to your courses before.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
              color: Colors.purpleAccent,
              child: const Text("My courses"),
              onPressed: () {
                Navigator.of(context)
                    .push(customPlatformPageRoute(
                        builder: (context) => const CourseList()))
                    .then((_) => _fetchChapters());
              })
        ],
      ),
    );
  }

  Widget _buildProgressionChapters(List<CourseChapter> chapters) {
    return Container(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final progressPercent = (chapter.progress ?? 0) * 100;
          return GestureDetector(
            onTap: () => Navigator.of(context)
                .push(customPlatformPageRoute(
                    builder: (context) => ShowChapter(chapter: chapter)))
                .then((_) => _fetchChapters()),
            child: Container(
              width: 300,
              height: 170,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: chapter.course?.majorIconData.bgColor ??
                    Colors.blueGrey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      chapter.course?.majorIconData.icon ?? Icons.book,
                      color:
                          chapter.course?.majorIconData.color ?? Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    chapter.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: chapter.progress,
                    color: Colors.black,
                    backgroundColor: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Progress",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${progressPercent.toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 14),
                      )
                    ],
                  ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        calendarFormat: CalendarFormat.week,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0XFFa5b4fc),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          todayTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          defaultTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildErrors() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text(
            "Oups !",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "An Error occurred while fetching your progress. Try again!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            child: const Text("Retry"),
            onPressed: () => _fetchChapters,
          )
        ],
      ),
    );
  }
}
