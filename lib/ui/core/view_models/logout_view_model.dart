import 'package:flutter/foundation.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

class LogoutViewModel extends ChangeNotifier {
  LogoutViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
