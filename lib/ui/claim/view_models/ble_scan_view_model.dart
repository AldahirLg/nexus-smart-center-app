import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/repositories/claim_repository.dart';

class BleScanViewModel extends ChangeNotifier {
  final ClaimRepository _bleRepository;

  late final StreamSubscription<List<ScanResult>> _scanSubscription;
  late final StreamSubscription<BluetoothAdapterState> _adapterSubscription;
  late final StreamSubscription<bool> _isScanningSubscription;

  List<ScanResult> _results = [];
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;

  BluetoothAdapterState get adapterState => _adapterState;
  bool get isScanning => _isScanning;
  List<ScanResult> get results => List.unmodifiable(_results);

  BleScanViewModel({required ClaimRepository bleRepository})
    : _bleRepository = bleRepository {
    _scanSubscription = _bleRepository.scanResults.listen((results) {
      _results = results;
      notifyListeners();
    });

    _adapterSubscription = _bleRepository.adapterState.listen((state) {
      _adapterState = state;
      if (state != BluetoothAdapterState.on) {
        _results = [];
      }
      notifyListeners();
    });

    _isScanningSubscription = _bleRepository.isScanning.listen((scanning) {
      _isScanning = scanning;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    _results = [];
    notifyListeners();
    await _bleRepository.startScan();
  }

  Future<void> stopScan() => _bleRepository.stopScan();

  Future<void> toggleScan() {
    return _isScanning ? stopScan() : startScan();
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    _adapterSubscription.cancel();
    _isScanningSubscription.cancel();
    _bleRepository.stopScan();
    super.dispose();
  }
}
