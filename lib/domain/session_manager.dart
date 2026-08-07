// lib/domain/use_cases/session_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';
import 'package:nexus_smart_center/models/user_model.dart';

enum SessionStatus {
  initializing,
  unauthenticated,
  unverifiedEmail,
  authenticated,
}

class SessionManager extends ChangeNotifier {
  SessionManager({
    required AuthRepository authRepository,
    required ApiRepository apiRepository,
  }) : _authRepository = authRepository,
       _apiRepository = apiRepository {
    _init();
  }

  final AuthRepository _authRepository;
  final ApiRepository _apiRepository;

  StreamSubscription<UserModel?>? _authSubscription;

  SessionStatus _status = SessionStatus.initializing;
  SessionStatus get status => _status;

  UserModel? _authUser;
  UserModel? get authUser => _authUser;

  ApiUserModel? _apiUser;
  ApiUserModel? get apiUser => _apiUser;

  bool get isInitialized => _status != SessionStatus.initializing;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get emailVerified => _authUser?.isEmailVerified ?? false;

  void _init() {
    _authSubscription = _authRepository.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  Future<void> _onAuthStateChanged(UserModel? user) async {
    debugPrint(
      '🔍 SessionManager: Firebase Auth cambió. Usuario: ${user?.email}',
    );

    if (user == null) {
      _authUser = null;
      _apiUser = null;
      _status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _authUser = user;

    if (!user.isEmailVerified) {
      _status = SessionStatus.unverifiedEmail;
      notifyListeners();
      return;
    }

    try {
      final token = await _authRepository.getIdToken();
      if (token != null) {
        debugPrint('🚀 SessionManager: Sincronizando con Backend...');

        _apiUser = await _apiRepository.synchronizeUser(token);
        _status = SessionStatus.authenticated;

        debugPrint(
          '✅ SessionManager: Sincronización exitosa. Estado: AUTHENTICATED',
        );
      } else {
        _status = SessionStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      // Si falla el parseo de ApiUserDto, lo verás detallado aquí
      debugPrint('❌ SessionManager Error en Sync/Parseo: $e');
      debugPrint(stackTrace.toString());
      _status = SessionStatus.unauthenticated;
    }

    notifyListeners();
    debugPrint(
      '📢 SessionManager: notifyListeners() llamado. Estado actual: $_status',
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
