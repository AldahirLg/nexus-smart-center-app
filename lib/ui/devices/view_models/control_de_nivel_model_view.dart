import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/model/level_controller_dto.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/repositories/real_time_repository.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';
import 'package:nexus_smart_center/ui/devices/widgets/bomba_card.dart';

class ControlDeNivelModelViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final ApiRepository _apiRepo;
  final DeviceModel _device;
  final RealTimeRepository _realTimeRepo;

  ControlDeNivelModelViewModel({
    required DeviceModel device,
    required RealTimeRepository realTimeRepo,
    required ApiRepository apiRepo,
    required AuthRepository authRepo,
  }) : _authRepo = authRepo,
       _apiRepo = apiRepo,
       _realTimeRepo = realTimeRepo,
       _device = device;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  LevelControllerModel? _levelController;
  LevelControllerModel? get levelController => _levelController;

  DeviceModel get device => _device;

  List<DeviceModel>? _medidores;
  List<DeviceModel>? get medidores => _medidores;

  bool _gettingMedidores = false;
  bool get gettingMedidores => _gettingMedidores;

  String? _errorGettingMedidores;
  String? get errorGettingMedidores => _errorGettingMedidores;

  Future<void> getMedidores() async {
    _gettingMedidores = true;
    _medidores = null;
    _errorGettingMedidores = null;
    notifyListeners();

    try {
      final tokenId = await _authRepo.getIdToken();
      _medidores = await _apiRepo.getLevelContorllers(tokenId!);
    } catch (e) {
      _errorGettingMedidores = 'Error: ${e.toString()}';
    } finally {
      _gettingMedidores = false;
      notifyListeners();
    }
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _realTimeRepo.subscribeDevice(device.id);

      final data = Map<String, dynamic>.from(response['data']);

      _levelController = LevelControllerInitDto.fromJson(data).toDomain();

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
      final update = LevelControllerUpdate.fromJson(
        Map<String, dynamic>.from(json['data']),
      );

      if (_levelController == null) return;

      _levelController = switch (update) {
        StatusUpdate(status: final status) => _levelController!.copyWith(
          status: status,
        ),

        PumpUpdate(pump: final pump) => _levelController!.copyWith(pump: pump),

        ParametersUpdate(parameters: final parameters) =>
          _levelController!.copyWith(parameters: parameters),
      };

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Actualización de nivel inválida';
      notifyListeners();
    }
  }

  Future<void> setParameters(ParametersLevelController parameters) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = ParametersLevelControllerDto.fromDomain(parameters).toJson();

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

  Future<void> setPump(PumpLevelController pump) async {
    try {
      await _realTimeRepo.sendCommand(
        deviceId: device.id,
        action: 'pump',
        payload: {'isOn': pump.isOn},
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> setMode(PumpLevelController pump) async {
    try {
      await _realTimeRepo.sendCommand(
        deviceId: device.id,
        action: 'pump',
        payload: {'mode': pump.mode},
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> onModeChanged(BombaMode mode) async {
    if (_levelController == null) return;

    final currentPump = _levelController!.pump;

    final newPump = PumpLevelController(
      isOn: currentPump.isOn,
      mode: mode == BombaMode.automatic ? 'AUTO' : 'MANUAL',
    );

    _levelController = _levelController!.copyWith(pump: newPump);

    notifyListeners();

    await setMode(newPump);
  }

  Future<void> onPowerChanged(bool isOn) async {
    if (_levelController == null) return;

    final currentPump = _levelController!.pump;

    final newPump = PumpLevelController(isOn: isOn, mode: currentPump.mode);

    _levelController = _levelController!.copyWith(pump: newPump);

    notifyListeners();

    await setPump(newPump);
  }

  @override
  void dispose() {
    _realTimeRepo.stopListeningDeviceData();
    super.dispose();
  }
}
