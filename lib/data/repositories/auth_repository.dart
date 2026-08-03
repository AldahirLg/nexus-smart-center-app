import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/model/firebase_user_dto.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/models/user_model.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository({required FirebaseAuthService authService})
    : _authService = authService {
    _authSubscription = _authService.authStateChanges().listen((firebaseUser) {
      _currentUser = firebaseUser == null
          ? null
          : AuthUserDto(firebaseUser: firebaseUser).toDomain();
      _isInitialized = true;
      notifyListeners();
    });
  }

  final FirebaseAuthService _authService;
  StreamSubscription? _authSubscription;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get emailVerified => _currentUser?.isEmailVerified ?? false;

  bool _isInitialized = false;
  bool get isInitialiazed => _isInitialized;

  Future<void> login(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
    await _authService.sendEmailVerification();
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    final firebaseUser = await _authService.reloadUser();
    if (firebaseUser != null) {
      _currentUser = AuthUserDto(firebaseUser: firebaseUser).toDomain();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
