import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';

class ManageDevicesModeView extends ChangeNotifier {
  final AuthRepository _authRepo;
  final ApiRepository _apiRepo;

  ManageDevicesModeView({
    required AuthRepository authRepo,
    required ApiRepository apiRepo,
  }) : _authRepo = authRepo,
       _apiRepo = apiRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;

  Future<void> getDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final tokenId = await _authRepo.getIdToken();
      if (tokenId == null) throw Exception('Sesión no válida');
      _devices = await _apiRepo.getDevices(tokenId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDeviceName(DeviceModel device, String newName) async {
    final name = newName.trim();
    if (name.isEmpty || name == device.name) return false;

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final tokenId = await _authRepo.getIdToken();
      if (tokenId == null) throw Exception('Sesión no válida');

      final updated = await _apiRepo.updateNameDevice(tokenId, device.id, name);

      final index = _devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        _devices = List.of(_devices)..[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
