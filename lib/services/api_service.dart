import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';

class ApiService {
  static const String baseUrl = Constants.apiUrl;
  static const String bearerTokenKey = "bearer_token";
  final Dio http;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? _cachedToken;

  // Private constructor
  ApiService._privateConstructor() : http = Dio(BaseOptions(baseUrl: baseUrl)) {
    initializeInterceptors();
    http.transformer = BackgroundTransformer();
  }

  // Single instance, lazily initialized
  static final ApiService _instance = ApiService._privateConstructor();

  // Factory constructor to return the same instance
  factory ApiService() {
    return _instance;
  }

  /// Initialize Dio interceptors for request and response handling.
  void initializeInterceptors() {
    http.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Load the token from cache or storage if not already loaded
        _cachedToken ??= await storage.read(key: bearerTokenKey);
        if (_cachedToken != null) {
          options.headers['Authorization'] = "Bearer $_cachedToken";
        }

        // Set the Accept-Language header based on the current locale
        final locale = WidgetsBinding.instance.platformDispatcher.locale;
        options.headers['Accept-Language'] = locale.toString();

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Automatically update the token if the response is from the authentication paths
        if (response.requestOptions.path.startsWith("/oauth/")) {
          var newToken = response.data['access_token'];
          if (newToken != null) {
            _cachedToken = newToken;
            storage.write(key: bearerTokenKey, value: newToken);
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Delete token from storage and cache on authentication error
        if (error.response?.statusCode == 401) {
          removeToken();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> removeToken() async {
    _cachedToken = null;
    storage.delete(key: bearerTokenKey);
  }
}
