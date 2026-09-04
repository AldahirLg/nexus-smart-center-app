import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';
import 'package:nexus_smart_center/models/device_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AuthRepository authRepository,
    required ApiRepository apiRepository,
  }) : _authRepository = authRepository,
       _apiRepository = apiRepository;

  final AuthRepository _authRepository;
  final ApiRepository _apiRepository;

  ApiUserModel? _currentUser;
  ApiUserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _messageError;
  String? get messageError => _messageError;

  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authRepository.getIdToken();

      if (token == null) {
        _messageError = 'No se pudo obtener el token';
        return;
      }

      _devices = await _apiRepository.getDevices(token);

      print('Dispositivos en ViewModel: $_devices');
    } catch (e) {
      _messageError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
