import 'package:flutter/material.dart';
import 'package:nexus_smart_center/domain/session_manager.dart';

class SyncFailedViewModel extends ChangeNotifier {
  final SessionManager sesion;

  SyncFailedViewModel({required this.sesion});

  String? _errorMessage = 'Ocurrio un problema. Intenta de nuevo';
  String? get errorMessaga => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> reIntent() async {
    _isLoading = true;
    notifyListeners();
    try {
      await sesion.syncServer();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
