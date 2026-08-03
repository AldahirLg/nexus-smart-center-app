import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  SignupViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _termsAndConditions = false;
  bool get termsAndConditions => _termsAndConditions;
  bool _showTermsError = false;
  bool get showTermsError => _showTermsError;
  //Form
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    if (!value.contains('@')) {
      return 'El correo no es válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void checkTermsAndConditions(bool value) {
    _termsAndConditions = value;
    if (value) {
      _showTermsError = false;
    }
    notifyListeners();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!termsAndConditions) {
      _showTermsError = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
