import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEservice {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

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

  Future<void> startScan({List<Guid> withServices = const []}) async {
    if (FlutterBluePlus.isScanningNow) {
      return;
    }

    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      return;
    }

    final adapter = await FlutterBluePlus.adapterState.first;

    if (adapter != BluetoothAdapterState.on) {
      return;
    }
    await FlutterBluePlus.startScan(
      androidScanMode: AndroidScanMode.lowLatency,
      withServices: withServices,
    );
  }

  Future<void> stopScan() async {
    if (!FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.stopScan();
  }
}
