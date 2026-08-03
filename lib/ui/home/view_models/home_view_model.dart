import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/models/user_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  UserModel? get currentUser => _authRepository.currentUser;
}
