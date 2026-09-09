// lib/domain/use_cases/session_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/repositories/fcm_repository.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';
import 'package:nexus_smart_center/models/user_model.dart';

enum SessionStatus {
  initializing,
  unauthenticated,
  unverifiedEmail,
  syncFailed,
  authenticated,
}

class SessionManager extends ChangeNotifier {
  SessionManager({
    required AuthRepository authRepository,
    required ApiRepository apiRepository,
    required FcmRepository fcmRepository,
  }) : _authRepository = authRepository,
       _apiRepository = apiRepository,
       _fcmRepository = fcmRepository {
    _init();
  }

  final FcmRepository _fcmRepository;
  final AuthRepository _authRepository;
  final ApiRepository _apiRepository;

  StreamSubscription<String>? _fcmTokenSubscription;

  StreamSubscription<UserModel?>? _authSubscription;

  SessionStatus _status = SessionStatus.initializing;
  SessionStatus get status => _status;

  UserModel? _authUser;
  UserModel? get authUser => _authUser;

  ApiUserModel? _apiUser;
  ApiUserModel? get apiUser => _apiUser;

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

    await syncServer();
  }

  Future<void> syncServer() async {
    try {
      final token = await _authRepository.getIdToken();
      if (token != null) {
        debugPrint('SessionManager: Sincronizando con Backend...');

        _apiUser = await _apiRepository.synchronizeUser(token);

        await _registerFcmToken(token);
        _listenToFcmToken(token);

        _status = SessionStatus.authenticated;
        debugPrint(
          'SessionManager: Sincronización exitosa. Estado: AUTHENTICATED',
        );
      } else {
        _status = SessionStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      debugPrint('SessionManager Error en Sync/Parseo: $e');
      debugPrint(stackTrace.toString());
      _apiUser = null;
      _status = SessionStatus.syncFailed;
    }
    notifyListeners();
  }

  Future<void> _registerFcmToken(String token) async {
    final fcmToken = await _fcmRepository.getToken();

    if (fcmToken == null) {
      debugPrint('SessionManager: No se obtuvo FCM Token');
      return;
    }

    debugPrint('SessionManager: Registrando FCM Token...');

    await _fcmRepository.registerToken(idToken: token, fcmToken: fcmToken);
  }

  void _listenToFcmToken(String idToken) {
    _fcmTokenSubscription?.cancel();

    _fcmTokenSubscription = _fcmRepository.tokenRefresh.listen((
      newToken,
    ) async {
      try {
        debugPrint('SessionManager: FCM Token actualizado');
        await _fcmRepository.registerToken(
          idToken: idToken,
          fcmToken: newToken,
        );
      } catch (e) {
        debugPrint('SessionManager: Error registrando nuevo FCM Token: $e');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _fcmTokenSubscription?.cancel();
    super.dispose();
  }
}
