import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/device_model.dart';

class DeviceIconMapper {
  static IconData getIcon(DeviceType type) {
    switch (type) {
      case DeviceType.medidor:
        return Icons.water_drop;

      case DeviceType.controlDeNivel:
        return Icons.water;

      case DeviceType.unknown:
        return Icons.devices_other_outlined;
    }
  }

  static String getTypeString(DeviceType type) {
    switch (type) {
      case DeviceType.medidor:
        return 'Medidor';

      case DeviceType.controlDeNivel:
        return 'Control de nivel';

      case DeviceType.unknown:
        return 'Desconocido';
    }
  }

  static String? getImage(DeviceType type) {
    switch (type) {
      case DeviceType.medidor:
        return 'assets/devices/medidor.webp';

      case DeviceType.controlDeNivel:
        return null;

      case DeviceType.unknown:
        return null;
    }
  }
}
