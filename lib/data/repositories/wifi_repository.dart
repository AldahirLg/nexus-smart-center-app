import 'package:nexus_smart_center/data/service/wifi_scan_service.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiRepository {
  final WifiScanService _wifi;

  WifiRepository({required WifiScanService wifi}) : _wifi = wifi;

  Stream<List<WiFiAccessPoint>> get results => _wifi.results;

  Future<void> startScan() async {
    await _wifi.startScan();
  }
}
