import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:universal_ble/universal_ble.dart';

class BLEservice {
  Stream<BleDevice> get scanResults => UniversalBle.scanStream;
  Stream<AvailabilityState> get adapterState => UniversalBle.availabilityStream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;

    final connectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    return scanGranted && connectGranted;
  }

  Future<void> startScan() async {
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      return;
    }
    await UniversalBle.startScan();

    _isScanning = await UniversalBle.isScanning();
  }

  Future<void> stopScan() async {
    await UniversalBle.stopScan();
    _isScanning = await UniversalBle.isScanning();
  }
}
