import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AuthRepository authRepository,
    required ApiRepository apiRepository,
  }) : _authRepository = authRepository,
       _apiRepostory = apiRepository;

  final ApiRepository _apiRepostory;
  final AuthRepository _authRepository;

  ApiUserModel? _currentUser;
  ApiUserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _messageError;
  String? get messageError => _messageError;
}
