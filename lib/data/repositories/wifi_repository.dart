import 'package:nexus_smart_center/data/service/persistence_service.dart';
import 'package:nexus_smart_center/data/service/wifi_scan_service.dart';
import 'package:nexus_smart_center/models/wifi_model.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiRepository {
  final WifiScanService _wifi;
  final PersistenceService _persistence;

  WifiRepository({
    required WifiScanService wifi,
    required PersistenceService persistence,
  }) : _wifi = wifi,
       _persistence = persistence;

  Stream<List<WiFiAccessPoint>> get results => _wifi.results;

  Future<void> startScan() async {
    await _wifi.startScan();
  }

  Future<WifiModel?> getWifiSaved() async {
    String? ssid = await _persistence.getWifiSsid();
    String? pass = await _persistence.getWifiPass();
    if (ssid == null || pass == null) return null;
    return WifiModel(ssid: ssid, pass: pass);
  }

  Future<void> saveNetwork(String ssid, String pass) async {
    await _persistence.saveWifi(ssid, pass);
  }
}
