import 'package:wifi_scan/wifi_scan.dart';

class WifiScanService {
  Stream<List<WiFiAccessPoint>> get results =>
      WiFiScan.instance.onScannedResultsAvailable;

  Future<bool> startScan() async {
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);

    if (can != CanStartScan.yes) {
      print('No se puede escanear WiFi: $can');
      return false;
    }

    return await WiFiScan.instance.startScan();
  }
}
