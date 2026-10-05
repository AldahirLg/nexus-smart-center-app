import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/wifi_repository.dart';
import 'package:nexus_smart_center/models/wifi_model.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ScanWifiViewModel extends ChangeNotifier {
  final WifiRepository _repo;

  ScanWifiViewModel({required WifiRepository repo}) : _repo = repo;

  late final StreamSubscription<List<WiFiAccessPoint>> _sub;

  Future<void> startScanWiFi() async {
    try {
      await _repo.startScan();
      _networkSaved = await _repo.getWifiSaved();
    } catch (e) {
      print(e.toString());
    }
  }

  List<WifiModel> _networks = [];
  List<WifiModel> get networks => _networks;

  WifiModel? _networkSaved;
  WifiModel? get networkSaved => _networkSaved;
  void listenResult() {
    _sub = _repo.results.listen((wifi) {
      _networks = wifi.map((accessPoint) {
        return WifiModel(
          ssid: accessPoint.ssid,
          signal: accessPoint.level.toString(),
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> saveNetwork(String ssid, String pass) async {
    try {
      await _repo.saveNetwork(ssid, pass);
      _networkSaved = await _repo.getWifiSaved();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
