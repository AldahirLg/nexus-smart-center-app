enum DeviceType { medidor, controlDeNivel, unknown }

class DeviceModel {
  final String id;
  final String name;
  final DeviceType type;
  const DeviceModel({required this.id, required this.name, required this.type});
}
