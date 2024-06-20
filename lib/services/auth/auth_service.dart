import 'package:Teriya/models.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    final _googleSignIn = GoogleSignIn();

    Future<TeriyaUser> account = _googleSignIn.signIn().then((account) {
      print(account);
      return TeriyaUser(id: 10);
    });

    return account;
  }
}
