import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

class PerfilViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;

  PerfilViewModel({required AuthRepository authRepo}) : _authRepo = authRepo;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLogout = false;
  bool get isLogout => _isLogout;

  Future<void> logoutSesion() async {
    _errorMessage = null;
    _isLogout = true;
    notifyListeners();
    try {
      await _authRepo.logout();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLogout = false;
      notifyListeners();
    }
  }
}
