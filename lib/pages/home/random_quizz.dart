import 'package:Teriya/components/feedback.dart';
import 'package:Teriya/models.dart';
import 'package:Teriya/pages/courses/CourseList.dart';
import 'package:Teriya/pages/courses/activities.dart';
import 'package:Teriya/services/course_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class RandomQuizz extends StatefulWidget {
  const RandomQuizz({super.key});

  @override
  State<RandomQuizz> createState() => _RandomQuizzState();
}

class _RandomQuizzState extends State<RandomQuizz> {
  late Future<List<SectionActivityQuizzQuestion>> _quizzFutures;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  void _fetchQuizzes() {
    setState(() {
      _quizzFutures = Provider.of<CourseService>(context, listen: false)
          .fetchQuizzes()
          .catchError((err) {
        print(err);
        showSnackbar(context, const Text("Error while fetching quizzes"));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _quizzFutures,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SafeArea(
              child: Center(child: PlatformCircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SafeArea(child: _buildErrors());
        } else {
          final quizzes = snapshot.data!;
          return quizzes.length == 0
              ? _buildEmptyView()
              : Quizz(
                  questions: quizzes,
                  onFinish: () {
                    Navigator.of(context).pop();
                  });
        }
      },
    );
  }

  Widget _buildEmptyView() {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Quizz"),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "No Quizz Yet !",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                "Add some courses and documents so Ally can generate some questions for you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
              const SizedBox(height: 25),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: const Text("My courses"),
                onPressed: () => Navigator.push(context,
                    customPlatformPageRoute(builder: (context) {
                  return const CourseList();
                })).then((_) => _fetchQuizzes()),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrors() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Oups !",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "An Error occurred while fetching quizzes. Try again!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            child: const Text("Retry"),
            onPressed: () => _fetchQuizzes,
          )
        ],
      ),
    );
  }
}
