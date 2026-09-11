import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/model/medidor_dto.dart';
import 'package:nexus_smart_center/data/repositories/real_time_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';

class MedidorViewModel extends ChangeNotifier {
  final DeviceModel device;
  final RealTimeRepository _realTimeRepo;

  MedidorViewModel({
    required RealTimeRepository realTimeRepo,
    required this.device,
  }) : _realTimeRepo = realTimeRepo;

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

  Future<void> init(String deviceId, String deviceType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _realTimeRepo.onDevice(
        deviceId,
        deviceType.toLowerCase(),
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
      final dto = MedidorInitialDto.fromJson(json);
      _medidor = dto.toModel();

      heightController.text = _medidor!.parameters.height.toString();
      levelHighController.text = _medidor!.parameters.levelHigh.toString();
      levelLowController.text = _medidor!.parameters.levelLow.toString();

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos iniciales del medidor inválidos';
      notifyListeners();
    }
  }

  Future<void> handleMeasurement(dynamic data) async {
    try {
      final json = Map<String, dynamic>.from(data);
      final dto = MedidorMeasurementDto.fromJson(json);

      if (_medidor != null) {
        _medidor = _medidor!.copyWith(
          percent: dto.percent,
          battery: dto.battery,
          sensorState: dto.sensorState,
        );
      }
      print(_medidor);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos de medición inválidos';
      notifyListeners();
    }
  }

  void setAlert(bool value) {
    if (_medidor == null) return;
    _medidor = _medidor!.copyWith(
      parameters: _medidor!.parameters.copyWith(alert: value),
    );
    notifyListeners();
  }

  void setConfiguration({
    required int height,
    required int levelHigh,
    required int levelLow,
    required bool alert,
  }) {
    _medidor =
        (_medidor ??
                MedidorModel(
                  percent: 0,
                  battery: 0,
                  sensorState: false,
                  parameters: const ParametersMedidor(
                    alert: false,
                    height: 0,
                    levelHigh: 0,
                    levelLow: 0,
                  ),
                ))
            .copyWith(
              parameters: ParametersMedidor(
                alert: alert,
                height: height,
                levelHigh: levelHigh,
                levelLow: levelLow,
              ),
            );

    heightController.text = height.toString();
    levelHighController.text = levelHigh.toString();
    levelLowController.text = levelLow.toString();

    notifyListeners();
  }

  Future<void> updateConfiguration({
    required String deviceId,
    required String type,
    required int height,
    required int levelHigh,
    required int levelLow,
    required bool alert,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _realTimeRepo.updateParameters(
        data: {
          'type': type,
          'deviceId': deviceId,
          'payload': {
            'alert': alert,
            'height': height,
            'levelHigh': levelHigh,
            'levelLow': levelLow,
          },
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
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
