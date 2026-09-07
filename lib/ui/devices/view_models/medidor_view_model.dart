import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/real_time_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';

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

  int _percent = 0;
  int get percent => _percent;

  bool _stateSensor = false;
  bool get stateSensor => _stateSensor;

  int _height = 0;
  int get height => _height;

  int _levelHigh = 0;
  int get levelHigh => _levelHigh;

  int _levelLow = 0;
  int get levelLow => _levelLow;

  bool _alert = false;
  bool get alert => _alert;

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

      final values = Map<String, dynamic>.from(json['values']);
      final realtime = Map<String, dynamic>.from(values['realtime']);
      final parameters = Map<String, dynamic>.from(values['parameters']);

      _percent = (realtime['percent'] as num).toInt();
      _stateSensor = realtime['state'] as bool;

      _height = (parameters['height'] as num).toInt();
      _levelHigh = (parameters['levelHigh'] as num).toInt();
      _levelLow = (parameters['levelLow'] as num).toInt();
      _alert = parameters['alert'] as bool;

      heightController.text = _height.toString();
      levelHighController.text = _levelHigh.toString();
      levelLowController.text = _levelLow.toString();

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

      _percent = (json['percent'] as num).toInt();
      _stateSensor = json['state'] as bool;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Datos de medición inválidos';
      notifyListeners();
    }
  }

  void setAlert(bool value) {
    _alert = value;
    notifyListeners();
  }

  void setConfiguration({
    required int height,
    required int levelHigh,
    required int levelLow,
    required bool alert,
  }) {
    _height = height;
    _levelHigh = levelHigh;
    _levelLow = levelLow;
    _alert = alert;

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
        type: type,
        data: {
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
