import 'package:nexus_smart_center/data/model/user_auth_dto.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/models/user_model.dart';

class AuthRepository {
  AuthRepository({required FirebaseAuthService authService})
    : _authService = authService;

  final FirebaseAuthService _authService;
  Stream<UserModel?> authStateChanges() {
    return _authService.authStateChanges().map((firebaseUser) {
      return firebaseUser == null
          ? null
          : AuthUserDto.fromFirebaseUser(firebaseUser).toDomain();
    });
  }

  Future<void> login(String email, String password) =>
      _authService.signIn(email, password);

  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
    await _authService.sendEmailVerification();
  }

  Future<void> sendEmailVerification() => _authService.sendEmailVerification();

  Future<UserModel?> reloadUser() async {
    final firebaseUser = await _authService.reloadUser();
    return firebaseUser == null
        ? null
        : AuthUserDto.fromFirebaseUser(firebaseUser).toDomain();
  }

  Future<String?> getIdToken() => _authService.getTokenId();

  Future<void> logout() => _authService.logout();
}
