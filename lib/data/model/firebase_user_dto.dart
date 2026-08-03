import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus_smart_center/models/user_model.dart';

class AuthUserDto {
  final User firebaseUser;
  const AuthUserDto({required this.firebaseUser});

  UserModel toDomain() {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }
}
