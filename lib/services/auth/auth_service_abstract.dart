import '../../models.dart';

abstract class AuthServiceAbstract {
  TeriyaUser? user;

  Future<TeriyaUser> signInWithApple();

  Future<TeriyaUser> signInWithGoogle();

  Future<TeriyaUser?> getUser();
}
