import 'package:nexus_smart_center/models/device_model.dart';

class SwitchModel extends DeviceModel {
  final bool isOn;
  const SwitchModel({
    required super.id,
    required super.uid,
    required super.name,
    required super.type,
    required this.isOn,
  });
}
