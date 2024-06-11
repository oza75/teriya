import 'package:Teriya/models.dart';

import 'auth_service_abstract.dart';

class AuthService implements AuthServiceAbstract {
  @override
  TeriyaUser? user;

  @override
  Future<TeriyaUser?> getUser() async {
    return Future.delayed(const Duration(seconds: 2), () {
      return null;
    });
  }

  @override
  Future<TeriyaUser> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<TeriyaUser> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }
}
