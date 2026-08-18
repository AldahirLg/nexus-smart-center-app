import 'package:nexus_smart_center/models/device_model.dart';

class ApiDeviceDto {
  final int id;
  final String uid;
  final String name;
  final String type;

  ApiDeviceDto({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
  });

  factory ApiDeviceDto.fromJson(Map<String, dynamic> json) {
    return ApiDeviceDto(
      id: json['id'],
      uid: json['device_uid'],
      name: json['device_uid'],
      type: json['device_type'],
    );
  }

  DeviceModel toDomain() {
    return DeviceModel(id: id, uid: uid, name: name, type: type);
  }
}
