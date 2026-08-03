import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(
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

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _authRepository.login(email, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
