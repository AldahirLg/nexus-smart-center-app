import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/model/medidor_dto.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/repositories/real_time_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';

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

  bool _isChangingMode = false;
  bool get isChangeAuto => _isChangingMode;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _realTimeRepo.subscribeDevice(device.id);

      final data = Map<String, dynamic>.from(response['data']);
      print(data);
      _medidor = MedidorInitialDto.fromJson(data).toDomain();

      _updateControllers();

      _realTimeRepo.listenDeviceData(_handleData);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleData(dynamic data) {
    try {
      final json = Map<String, dynamic>.from(data);

      final update = MedidorDtoUpdate.fromJson(
        Map<String, dynamic>.from(json['data']),
      );

      if (_medidor == null) return;

      _medidor = switch (update) {
        StatusMedidorUpdate(status: final status) => _medidor!.copyWith(
          status: status,
        ),

        ParametersMedidorUpdate(parameters: final parameters) =>
          _medidor!.copyWith(parameters: parameters),
      };

      if (update is ParametersMedidorUpdate) {
        _updateControllers();
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos de medición inválidos';
      notifyListeners();
    }
  }

  void _updateControllers() {
    if (_medidor == null) return;

    heightController.text = _medidor!.parameters.height.toString();

    levelHighController.text = _medidor!.parameters.levelHigh.toString();

    levelLowController.text = _medidor!.parameters.levelLow.toString();
  }

  Future<void> setParameters(ParametersMedidor parameters) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = ParametersMedidorDto.fromDomain(parameters).toPayload();

      await _realTimeRepo.sendCommand(
        deviceId: device.id,
        action: 'parameters',
        payload: data,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> changeAutoMode(ParametersMedidor parameters) async {
    await setParameters(parameters);
  }

  void setAlert(bool value) {
    if (_medidor == null) return;

    final parameters = _medidor!.parameters.copyWith(alert: value);

    _medidor = _medidor!.copyWith(parameters: parameters);

    notifyListeners();

    setParameters(parameters);
  }

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
      final tokenId = await _authRepo.getIdToken();

      _controllers = await _apiRepo.getLevelContorllers(tokenId!);
    } catch (e) {
      _errorGettingControllers = 'Error: ${e.toString()}';
    } finally {
      _gettingControllers = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _realTimeRepo.stopListeningDeviceData();

    heightController.dispose();
    levelHighController.dispose();
    levelLowController.dispose();

    super.dispose();
  }
}
