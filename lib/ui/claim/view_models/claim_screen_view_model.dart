import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/repositories/ble_repository.dart';
import 'package:nexus_smart_center/data/repositories/claim_repository.dart';
import 'package:nexus_smart_center/data/repositories/wifi_repository.dart';
import 'package:nexus_smart_center/models/wifi_model.dart';

enum ProvisioningStep {
  idle,
  connectingBle,
  requestingDeviceId,
  claimingToken,
  sendingCredentials,
  working,
  connectingWifi,
  testingWifi,
  awaitingServerConfirmation,
  claimed,
  claimExpired,
  failed,
  error,
  timeout,
  disconnected,
}

class ClaimDeviceViewModel extends ChangeNotifier {
  final BleRepository _bleRepository;
  final ClaimRepository _claimRepository;
  final WifiRepository _wifiRepo;

  ClaimDeviceViewModel({
    required BleRepository bleRepository,
    required ClaimRepository claimRepository,
    required WifiRepository wifiRepo,
  }) : _bleRepository = bleRepository,
       _claimRepository = claimRepository,
       _wifiRepo = wifiRepo {
    _bleStateSub = _bleRepository.state.listen(_onBleStateChanged);
  }

  WifiModel? _wifiModel;

  late final StreamSubscription<BleProvisioningState> _bleStateSub;

  BluetoothDevice? _device;

  ProvisioningStep _step = ProvisioningStep.idle;
  ProvisioningStep get step => _step;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  void _setStep(ProvisioningStep step) {
    if (_isDisposed) return;

    _step = step;
    notifyListeners();
  }

  void _onBleStateChanged(BleProvisioningState bleState) {
    // Después de iniciar la confirmación del servidor,
    // los cambios de conexión BLE no controlan la pantalla.
    if (_step == ProvisioningStep.awaitingServerConfirmation ||
        _step == ProvisioningStep.claimed ||
        _step == ProvisioningStep.claimExpired ||
        _step == ProvisioningStep.failed ||
        _step == ProvisioningStep.error ||
        _step == ProvisioningStep.timeout) {
      return;
    }

    switch (bleState) {
      case BleProvisioningState.working:
        _setStep(ProvisioningStep.working);
        break;

      case BleProvisioningState.connectingWifi:
        _setStep(ProvisioningStep.connectingWifi);
        break;

      case BleProvisioningState.testingWifi:
        _setStep(ProvisioningStep.testingWifi);
        break;

      case BleProvisioningState.timeout:
        _setStep(ProvisioningStep.timeout);
        break;

      case BleProvisioningState.disconnected:
        _setStep(ProvisioningStep.disconnected);
        break;

      case BleProvisioningState.error:
        _setStep(ProvisioningStep.error);
        break;

      default:
        break;
    }
  }

  Future<void> claimDevice(BluetoothDevice device) async {
    _device = device;
    _errorMessage = null;
    _setStep(ProvisioningStep.idle);

    String? deviceUid;
    bool confirmationPrepared = false;

    try {
      _wifiModel = await _wifiRepo.getWifiSaved();

      if (_wifiModel == null || _wifiModel!.pass == null) {
        throw Exception('No se encontraron las credenciales Wi-Fi guardadas.');
      }

      _setStep(ProvisioningStep.connectingBle);
      await _bleRepository.connectAndPrepare(device);

      _setStep(ProvisioningStep.requestingDeviceId);
      deviceUid = await _bleRepository.requestDeviceId();

      debugPrint('[VM] device_uid recibido: $deviceUid');

      if (deviceUid.isEmpty) {
        throw Exception('El dispositivo no devolvió un identificador válido.');
      }

      _setStep(ProvisioningStep.claimingToken);

      final claimToken = await _claimRepository.requestClaimToken(deviceUid);

      debugPrint('[VM] claimToken recibido');

      // IMPORTANTE:
      // Registrar el listener antes de enviar las credenciales BLE,
      // para no perder una confirmación rápida del backend.
      await _claimRepository.prepareClaimConfirmation();
      confirmationPrepared = true;

      _setStep(ProvisioningStep.sendingCredentials);

      final result = await _bleRepository.sendProvisioningPayload(
        ssid: _wifiModel!.ssid,
        password: _wifiModel!.pass!,
        tokenClaim: claimToken,
      );

      final status = result['status'];

      debugPrint('[VM] Resultado de provisioning BLE: $result');

      if (status == 'timeout') {
        _setStep(ProvisioningStep.timeout);
        return;
      }

      if (status == 'failed') {
        _errorMessage = result['message']?.toString();
        _setStep(ProvisioningStep.failed);
        return;
      }

      if (status != 'success') {
        _errorMessage = result['message']?.toString();
        _setStep(ProvisioningStep.error);
        return;
      }

      // BLE terminó correctamente. Desde aquí, la conexión BLE
      // ya no determina el estado visual.
      _setStep(ProvisioningStep.awaitingServerConfirmation);

      final confirmation = await _claimRepository.awaitClaimConfirmation();

      confirmationPrepared = false;

      debugPrint('[VM] Confirmación del servidor: $confirmation');

      // Extraer el resultado real del claim desde data.
      final rawData = confirmation['data'];

      if (rawData is! Map) {
        throw Exception(
          'La respuesta del servidor no contiene un objeto data válido.',
        );
      }

      final claimData = Map<String, dynamic>.from(rawData);

      debugPrint('[VM] Datos del claim: $claimData');

      final confirmed = claimData['success'] == true;
      final confirmationStatus = claimData['status'];

      if (confirmed && confirmationStatus == 'CLAIMED') {
        _setStep(ProvisioningStep.claimed);
      } else if (confirmationStatus == 'EXPIRED') {
        _errorMessage = 'El claim expiró, intenta de nuevo.';
        _setStep(ProvisioningStep.claimExpired);
      } else {
        _errorMessage = 'El servidor rechazó el claim.';
        _setStep(ProvisioningStep.error);
      }
    } catch (e, stackTrace) {
      debugPrint('[VM] Error en provisioning: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage = e.toString();
      _setStep(ProvisioningStep.error);
    } finally {
      if (confirmationPrepared) {
        _claimRepository.cancelClaimConfirmation();
      }

      await disconnect();
    }
  }

  Future<void> disconnect() async {
    if (_device == null) return;

    try {
      await _bleRepository.disconnect();
    } catch (e) {
      debugPrint('[VM] Error al desconectar BLE: $e');
    } finally {
      _device = null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _bleStateSub.cancel();
    _claimRepository.cancelClaimConfirmation();

    _bleRepository.dispose();
    _claimRepository.disposeSocket();

    super.dispose();
  }
}
