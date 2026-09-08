import 'package:wifi_scan/wifi_scan.dart';

class WifiScanService {
  Stream<List<WiFiAccessPoint>> get results =>
      WiFiScan.instance.onScannedResultsAvailable;

  Future<void> startScan() async {
    await WiFiScan.instance.startScan();
  }
}
