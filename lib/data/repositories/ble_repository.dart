import 'package:nexus_smart_center/data/service/ble_service.dart';
import 'package:universal_ble/universal_ble.dart';

class BleRepository {
  final BLEservice _bleService;

  BleRepository({required BLEservice bleService}) : _bleService = bleService;

  Stream<BleDevice> get scanResults => _bleService.scanResults;
  Stream<AvailabilityState> get adapterState => _bleService.adapterState;
  Future<void> startScan() async {
    await _bleService.startScan();
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
  }
}
