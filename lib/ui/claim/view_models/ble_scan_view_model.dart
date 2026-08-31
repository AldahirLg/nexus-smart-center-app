import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/ble_repository.dart';
import 'package:universal_ble/universal_ble.dart';

class BleScanViewModel extends ChangeNotifier {
  final BleRepository _bleRepository;

  late final StreamSubscription<BleDevice> _scanSubscription;
  late final StreamSubscription<AvailabilityState> _adapterSubscription;
  final List<BleDevice> _devices = [];
  AvailabilityState _adapterState = AvailabilityState.unknown;
  AvailabilityState get adapterState => _adapterState;
  List<BleDevice> get devices => List.unmodifiable(_devices);

  BleScanViewModel({required BleRepository bleRepository})
    : _bleRepository = bleRepository {
    _scanSubscription = _bleRepository.scanResults.listen((BleDevice device) {
      final index = _devices.indexWhere((d) => d.deviceId == device.deviceId);
      if (index == -1) {
        _devices.add(device);
      } else {
        _devices[index] = device;
      }

      notifyListeners();
    });

    _adapterSubscription = _bleRepository.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    await _bleRepository.startScan();
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    _adapterSubscription.cancel();
    super.dispose();
  }
}
