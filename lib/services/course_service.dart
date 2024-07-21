import 'dart:io';

import '../models.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class CourseService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<String> majors = [];

  /// Creates a new course with the provided details and documents.
  Future<Course> createCourse(String name, String major, List<File> documents) {
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
      final course = Course.fromJson(res.data);
      notifyListeners();
      return course;
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
}
