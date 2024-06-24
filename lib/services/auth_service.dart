import 'dart:io';

import 'package:Teriya/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models.dart';

enum AuthProvider { apple, google }

class AuthService extends ChangeNotifier {
  TeriyaUser? _user;
  final _apiService = ApiService();

  TeriyaUser? get user => _user;

  Future<TeriyaUser> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    List<String?> names = [credential.givenName, credential.familyName]
        .where((item) => item != null)
        .toList();

    String? fullName = names.isNotEmpty ? names.join(", ") : null;

    return oauth(AuthProvider.apple, credential.authorizationCode,
        credential.userIdentifier as String, fullName);
  }

  Future<TeriyaUser> signInWithGoogle() {
    final _googleSignIn = GoogleSignIn(
        scopes: ['openid', 'email', 'profile'],
        clientId: Platform.isAndroid
            ? "980818957858-6jqjp6ook6n21fmj0ioa87udb5srpp6m.apps.googleusercontent.com"
            : null);

    return _googleSignIn.signIn().then((account) async {
      var authentication = await account!.authentication;
      return oauth(
          AuthProvider.google, authentication.idToken, account.id, null);
    });
  }

  Future<TeriyaUser> oauth(AuthProvider provider, String? token,
      String providerId, String? userName) {
    return _apiService.http.post('/oauth/${provider.name}', data: {
      'token': token,
      'provider_id': providerId,
      'full_name': userName
    }).then((res) {
      _user = TeriyaUser.fromJson(res.data);
      notifyListeners();
      return _user!;
    });
  }

  Future<TeriyaUser?> getUser() {
    return _apiService.http.get("/auth/me").then((res) {
      _user = TeriyaUser.fromJson(res.data);
      notifyListeners();
      return _user!;
    });
  }

  Future<void> logout() async {
    await _apiService.removeToken();
    _user = null;
    notifyListeners();
  }
}
