import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/repositories/claim_repository.dart';

class ClaimDeviceViewModel extends ChangeNotifier {
  final ClaimRepository _claimRepos;

  ClaimDeviceViewModel({required ClaimRepository bleRepository})
    : _claimRepos = bleRepository {
    _provisioningSub = _claimRepos.provisioningState.listen((state) {
      _state = state;
      notifyListeners();
    });
  }

  BluetoothDevice? _device;
  StateProvisioning _state = StateProvisioning.idle;
  StateProvisioning get state => _state;

  late final StreamSubscription<StateProvisioning> _provisioningSub;

  Future<void> claimDevice(BluetoothDevice device) async {
    _device = device;
    _state = StateProvisioning.idle;
    notifyListeners();
    await _claimRepos.claimDevice(device);
  }

  Future<void> disconnect() async {
    if (_device == null) return;
    try {
      await _claimRepos.disconnect(_device!);
    } catch (_) {}
  }

  @override
  void dispose() {
    _provisioningSub.cancel();
    _claimRepos.disconnect(_device!);
    super.dispose();
  }
}
