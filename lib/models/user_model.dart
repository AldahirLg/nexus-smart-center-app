class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isEmailVerified;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.isEmailVerified,
  });
}
