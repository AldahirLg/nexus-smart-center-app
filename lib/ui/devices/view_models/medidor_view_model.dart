import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/model/medidor_dto.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/repositories/real_time_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';

class MedidorViewModel extends ChangeNotifier {
  final DeviceModel device;
  final RealTimeRepository _realTimeRepo;
  final AuthRepository _authRepo;
  final ApiRepository _apiRepo;

  MedidorViewModel({
    required RealTimeRepository realTimeRepo,
    required this.device,
    required AuthRepository authRepo,
    required ApiRepository apiRepo,
  }) : _authRepo = authRepo,
       _apiRepo = apiRepo,
       _realTimeRepo = realTimeRepo;

  final TextEditingController heightController = TextEditingController();
  final TextEditingController levelHighController = TextEditingController();
  final TextEditingController levelLowController = TextEditingController();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  MedidorModel? _medidor;
  MedidorModel? get medidor => _medidor;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print("Iniciando Medidoooooor");
    try {
      await _realTimeRepo.onDevice(
        device.id,
        DeviceIconMapper.getTypeString(device.type).toLowerCase(),
        handleInitialData,
        handleMeasurement,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleInitialData(dynamic data) async {
    try {
      final json = Map<String, dynamic>.from(data);
      _medidor = MedidorInitialDto.fromJson(json).toDomain();
      print(json);
      //_errorMessage = null;
      //_isLoading = false;
      heightController.text = _medidor!.parameters.height.toString();
      levelHighController.text = _medidor!.parameters.levelHigh.toString();
      levelLowController.text = _medidor!.parameters.levelLow.toString();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos iniciales del medidor inválidos';
      notifyListeners();
    }
  }

  Future<void> handleMeasurement(dynamic data) async {
    try {
      final json = Map<String, dynamic>.from(data);
      final update = MedidorDtoUpdate.fromJson(json);
      print(json);
      if (_medidor == null) return;
      _medidor = switch (update) {
        StatusMedidorUpdate(status: final s) => _medidor!.copyWith(status: s),
        ParametersMedidorUpdate(parameters: final pr) => _medidor!.copyWith(
          parameters: pr,
        ),
      };

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos de medición inválidos';
      notifyListeners();
    }
  }

  void setAlert(bool value) {
    if (_medidor == null) return;
    setParameters(_medidor!.parameters.copyWith(alert: value));
    notifyListeners();
  }

  Future<void> setParameters(ParametersMedidor parameters) async {
    try {
      final data = ParametersMedidorDto.fromDomain(parameters).toJson();
      await _realTimeRepo.updateParameters(device: device, payload: data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // obtener controladores nivel
  List<DeviceModel>? _controllers;
  List<DeviceModel>? get controllers => _controllers;
  bool _gettingControllers = false;
  bool get gettingControllers => _gettingControllers;
  String? _errorGettingControllers;
  String? get errorGettingControllers => _errorGettingControllers;

  Future<void> getMedidores() async {
    _gettingControllers = true;
    _controllers = null;
    _errorGettingControllers = null;
    notifyListeners();
    try {
      String? tokenId = await _authRepo.getIdToken();
      _controllers = await _apiRepo.getLevelContorllers(tokenId!);
    } catch (e) {
      _errorGettingControllers = "Error: ${e.toString()}";
    } finally {
      _gettingControllers = false;
      notifyListeners();
    }
  }

  bool _isChancgeMode = false;
  bool get isChangeAuto => _isChancgeMode;

  Future<void> changeAutoMode(ParametersMedidor parameters) async {
    _isChancgeMode = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = ParametersMedidorDto.fromDomain(parameters).toJson();
      final idToken = await _authRepo.getIdToken();
      final param = await _apiRepo.setParametersMedidor(
        idToken!,
        device.id,
        data,
      );
      _medidor = _medidor!.copyWith(parameters: param);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isChancgeMode = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    levelHighController.dispose();
    levelLowController.dispose();
    _realTimeRepo.dispose();
    super.dispose();
  }
}
