abstract class DeviceModel {
  final String uid;
  final String name;
  final String type;
  final bool online;

  const DeviceModel({
    required this.uid,
    required this.name,
    required this.type,
    required this.online,
  });
}
