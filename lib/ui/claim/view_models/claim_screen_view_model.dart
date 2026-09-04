import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/repositories/ble_repository.dart';
import 'package:nexus_smart_center/data/repositories/claim_repository.dart';

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

  ClaimDeviceViewModel({
    required BleRepository bleRepository,
    required ClaimRepository claimRepository,
  }) : _bleRepository = bleRepository,
       _claimRepository = claimRepository {
    _bleStateSub = _bleRepository.state.listen(_onBleStateChanged);
  }

  static const String _ssid = 'INFINITUM83A0_2.4';
  static const String _password = '5Roble1620';

  late final StreamSubscription<BleProvisioningState> _bleStateSub;

  BluetoothDevice? _device;

  ProvisioningStep _step = ProvisioningStep.idle;
  ProvisioningStep get step => _step;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setStep(ProvisioningStep step) {
    _step = step;
    notifyListeners();
  }

  void _onBleStateChanged(BleProvisioningState bleState) {
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
        if (_step != ProvisioningStep.claimed &&
            _step != ProvisioningStep.claimExpired &&
            _step != ProvisioningStep.failed) {
          _setStep(ProvisioningStep.disconnected);
        }
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

    try {
      _setStep(ProvisioningStep.connectingBle);
      await _bleRepository.connectAndPrepare(device);

      _setStep(ProvisioningStep.requestingDeviceId);
      deviceUid = await _bleRepository.requestDeviceId();
      debugPrint('[VM] device_uid recibido: $deviceUid');

      _setStep(ProvisioningStep.claimingToken);
      final claimToken = await _claimRepository.requestClaimToken(deviceUid);
      debugPrint('[VM] claimToken recibido');

      _setStep(ProvisioningStep.sendingCredentials);
      final result = await _bleRepository.sendProvisioningPayload(
        ssid: _ssid,
        password: _password,
        tokenClaim: claimToken,
      );

      final status = result['status'];
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

      _setStep(ProvisioningStep.awaitingServerConfirmation);
      final confirmation = await _claimRepository.awaitClaimConfirmation(
        deviceUid,
      );

      final confirmed = confirmation['success'] == true;
      final confirmationStatus = confirmation['status'];

      if (confirmed && confirmationStatus == 'CLAIMED') {
        _setStep(ProvisioningStep.claimed);
      } else if (confirmationStatus == 'EXPIRED') {
        _errorMessage = 'El claim expiró, intenta de nuevo.';
        _setStep(ProvisioningStep.claimExpired);
      } else {
        _errorMessage = 'El servidor rechazó el claim.';
        _setStep(ProvisioningStep.error);
      }
    } catch (e) {
      debugPrint('[VM] Error en provisioning: $e');
      _errorMessage = e.toString();
      _setStep(ProvisioningStep.error);
    } finally {
      await disconnect();
    }
  }

  Future<void> disconnect() async {
    if (_device == null) return;
    try {
      await _bleRepository.disconnect();
    } catch (_) {
    } finally {
      _device = null;
    }
  }

  @override
  void dispose() {
    _bleStateSub.cancel();
    _bleRepository.dispose();
    _claimRepository.disposeSocket();
    super.dispose();
  }
}
