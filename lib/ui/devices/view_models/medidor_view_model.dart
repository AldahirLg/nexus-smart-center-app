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

  double _height = 0;
  double get height => _height;

  double _levelHigh = 0;
  double get levelHigh => _levelHigh;

  double _levelLow = 0;
  double get levelLow => _levelLow;

  bool _alert = false;
  bool get alert => _alert;

  Future<void> initialize(String deviceId) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _realTimeRepo.onDevice(
        deviceId,
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

      final measurement = Map<String, dynamic>.from(json['measurement']);

      final configuration = Map<String, dynamic>.from(json['configuration']);

      _percent = (measurement['percent'] as num).toInt();

      _stateSensor = measurement['state'] as bool;

      _height = (configuration['height'] as num).toDouble();

      _levelHigh = (configuration['levelHigh'] as num).toDouble();

      _levelLow = (configuration['levelLow'] as num).toDouble();

      _alert = configuration['alert'] as bool;

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

  void setConfiguration({
    required double height,
    required double levelHigh,
    required double levelLow,
    required bool alert,
  }) {
    _height = height;
    _levelHigh = levelHigh;
    _levelLow = levelLow;
    _alert = alert;

    notifyListeners();
  }

  Future<void> updateConfiguration({
    required String deviceId,
    required double height,
    required double levelHigh,
    required double levelLow,
    required bool alert,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _realTimeRepo.updateMedidor(
        deviceId: deviceId,
        height: height,
        levelHigh: levelHigh,
        levelLow: levelLow,
        alert: alert,
        handler: handleConfigurationUpdated,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> handleConfigurationUpdated(dynamic data) async {
    try {
      final json = Map<String, dynamic>.from(data);

      _height = (json['height'] as num).toDouble();

      _levelHigh = (json['levelHigh'] as num).toDouble();

      _levelLow = (json['levelLow'] as num).toDouble();

      _alert = json['alert'] as bool;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Configuración recibida inválida';

      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _realTimeRepo.dispose();
    super.dispose();
  }
}
