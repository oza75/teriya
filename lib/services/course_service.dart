import 'dart:io';

import '../models.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class CourseService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<String> majors = [];

  /// Creates a new course with the provided details and documents.
  Future<Course> createCourse(
      String name, String language, String major, List<File> documents) {
    // Create a FormData object
    FormData formData = FormData.fromMap({
      'name': name,
      'language': language,
      'major': major,
      // Convert the list of File objects into a list of MultipartFile objects
      'documents': documents
          .map((file) => MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ))
          .toList(),
    });

    // Use the ApiService to send a POST request
    return _apiService.http.post('/courses/create', data: formData).then((res) {
      final course = Course.fromJson(res.data);
      notifyListeners();
      return course;
    });
  }

  Future<Course> updateCourse(
    Course course,
    String name,
    String major,
    List<File> documents,
  ) {
    // Create a FormData object
    FormData formData = FormData.fromMap({
      'name': name,
      'major': major,
      // Convert the list of File objects into a list of MultipartFile objects
      'documents': documents
          .map((file) => MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ))
          .toList(),
    });

    // Use the ApiService to send a POST request
    return _apiService.http
        .put('/courses/${course.id}', data: formData)
        .then((res) {
      return Course.fromJson(res.data);
    });
  }

  Future<List<String>> fetchMajors() {
    return _apiService.http.get('/courses/majors').then((res) {
      majors = List<String>.from(res.data);
      notifyListeners();
      return majors;
    });
  }

  Future<List<Course>> fetchCourses() {
    return _apiService.http.get('/courses').then((res) {
      List<dynamic> data = res.data;
      return data.map((json) => Course.fromJson(json)).toList();
    });
  }

  Future<Course> fetchCourse(int courseId) {
    return _apiService.http.get("/courses/$courseId").then((res) {
      return Course.fromJson(res.data);
    });
  }

  Future<List<CourseDocument>> fetchCourseDocuments(int courseId) {
    return _apiService.http.get("/courses/$courseId/documents").then((res) {
      List<dynamic> documents = res.data;
      return documents.map((elem) => CourseDocument.fromJson(elem)).toList();
    });
  }

  Future<void> deleteCourseDocument(int courseId, int documentId) {
    return _apiService.http
        .delete("/courses/$courseId/documents/$documentId")
        .then((res) {});
  }

  Future<List<CourseDocument>> addCourseDocument(
    int courseId,
    List<File> files,
  ) {
    // Create a FormData object
    FormData formData = FormData.fromMap({
      'documents': files
          .map((file) => MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ))
          .toList(),
    });
    return _apiService.http
        .post("/courses/$courseId/documents", data: formData)
        .then((res) {
      List<dynamic> documentsJson = res.data;
      return documentsJson
          .map((elem) => CourseDocument.fromJson(elem))
          .toList();
    });
  }

  Future<void> deleteCourseChapter(int courseId, int id) {
    return _apiService.http.delete("/courses/$courseId/chapters/$id");
  }

  Future<List<CourseChapterSection>> chapterSections(CourseChapter chapter) {
    return _apiService.http
        .get("/courses/${chapter.courseId}/chapters/${chapter.id}/contents")
        .then((res) {
      List<dynamic> data = res.data;
      return data.map((elem) => CourseChapterSection.fromJson(elem)).toList();
    });
  }

  Future<List<CourseDocument>> fetchChapterDocuments(CourseChapter chapter) {
    return _apiService.http
        .get("/courses/${chapter.courseId}/chapters/${chapter.id}/documents")
        .then((res) {
      List<dynamic> documents = res.data;
      return documents.map((elem) => CourseDocument.fromJson(elem)).toList();
    });
  }

  Future<void> reGenerateChapters(int courseId) {
    return _apiService.http.post("/courses/$courseId/chapters/regenerate");
  }

  Future<void> reGenerateChapterContents(CourseChapter chapter) {
    return _apiService.http.post(
      "/courses/${chapter.courseId}/chapters/${chapter.id}/contents/regenerate",
    );
  }

  Future<void> updateChapterProgression(
    CourseChapter chapter,
    CourseChapterSection section,
  ) {
    return _apiService.http.put(
        "/courses/${chapter.courseId}/chapters/${chapter.id}/progression",
        data: {"title": section.title});
  }
}
