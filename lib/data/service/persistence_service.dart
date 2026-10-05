import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<void> saveWifi(String ssid, String pass) async {
    await prefs.setString('wifi_ssid', ssid);
    await prefs.setString('wifi_pass', pass);
  }

  Future<String?> getWifiSsid() async {
    return await prefs.getString('wifi_ssid');
  }

  Future<String?> getWifiPass() async {
    return await prefs.getString('wifi_pass');
  }

  Future<void> removeWifiSaved() async {
    await prefs.remove('wifi_ssid');
    await prefs.remove('wifi_pass');
  }
}
