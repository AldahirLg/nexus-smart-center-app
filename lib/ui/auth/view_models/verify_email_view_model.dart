import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  VerifyEmailViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  Future<void> checkEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.reloadUser();
      _isEmailVerified = _authRepository.emailVerified;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
