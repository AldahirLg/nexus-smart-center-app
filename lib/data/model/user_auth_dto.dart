import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus_smart_center/models/user_model.dart';

class AuthUserDto {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  const AuthUserDto({
    required this.uid,
    this.email,
    this.displayName,
    required this.emailVerified,
  });

  factory AuthUserDto.fromFirebaseUser(User firebaseUser) {
    return AuthUserDto(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      emailVerified: firebaseUser.emailVerified,
      displayName: firebaseUser.displayName,
    );
  }

  UserModel toDomain() {
    return UserModel(
      uid: uid,
      email: email ?? '',
      displayName: displayName,
      isEmailVerified: emailVerified,
    );
  }
}
