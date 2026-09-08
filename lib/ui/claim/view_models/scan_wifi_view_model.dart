import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/wifi_repository.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ScanWifiViewModel extends ChangeNotifier {
  final WifiRepository _repo;

  ScanWifiViewModel({required WifiRepository repo}) : _repo = repo;

  List<WiFiAccessPoint> _result = [];
  List<WiFiAccessPoint> get result => _result;

  late final StreamSubscription<List<WiFiAccessPoint>> _sub;

  Future<void> startScanWiFi() async {
    await _repo.startScan();
  }

  Future<void> listenResult() async {
    _sub = _repo.results.listen((wifi) {
      _result = wifi;
      notifyListeners();
      for (WiFiAccessPoint w in wifi) {
        print('WiFI:${w.ssid}');
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
