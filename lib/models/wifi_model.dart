class WifiModel {
  final String ssid;
  final String? pass;
  final String? signal;

  const WifiModel({required this.ssid, this.pass, this.signal});

  WifiModel copyWith({String? ssid, String? pass, String? signal}) {
    return WifiModel(
      ssid: ssid ?? this.ssid,
      pass: pass ?? this.pass,
      signal: signal ?? this.signal,
    );
  }
}
