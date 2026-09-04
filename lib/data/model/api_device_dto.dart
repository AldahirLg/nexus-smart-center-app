import 'package:nexus_smart_center/models/device_model.dart';

class ApiDeviceDto {
  final String id;
  final String name;
  final String type;

  ApiDeviceDto({required this.id, required this.name, required this.type});

  factory ApiDeviceDto.fromJson(Map<String, dynamic> json) {
    return ApiDeviceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  DeviceType _parseDeviceType(String type) {
    switch (type) {
      case 'Medidor ':
        return DeviceType.medidor;
      case 'LevelController':
        return DeviceType.controlDeNivel;
      default:
        return DeviceType.unknown;
    }
  }

  DeviceModel toDomain() {
    return DeviceModel(id: id, name: name, type: _parseDeviceType(type));
  }
}
