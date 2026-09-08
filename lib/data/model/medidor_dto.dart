import 'package:nexus_smart_center/models/medidor_model.dart';

/// Payload inicial: { values: { realtime: {...}, parameters: {...} } }
class MedidorInitialDto {
  final int percent;
  final bool sensorState;
  final int height;
  final int levelHigh;
  final int levelLow;
  final bool alert;

  MedidorInitialDto({
    required this.percent,
    required this.sensorState,
    required this.height,
    required this.levelHigh,
    required this.levelLow,
    required this.alert,
  });

  factory MedidorInitialDto.fromJson(Map<String, dynamic> json) {
    final values = Map<String, dynamic>.from(json['values']);
    final realtime = Map<String, dynamic>.from(values['realtime']);
    final parameters = Map<String, dynamic>.from(values['parameters']);

    return MedidorInitialDto(
      percent: (realtime['percent'] as num).toInt(),
      sensorState: realtime['sensor_state'] as bool,
      height: (parameters['height'] as num).toInt(),
      levelHigh: (parameters['levelHigh'] as num).toInt(),
      levelLow: (parameters['levelLow'] as num).toInt(),
      alert: parameters['alert'] as bool,
    );
  }

  MedidorModel toModel({int battery = 0}) {
    return MedidorModel(
      percent: percent,
      battery: battery,
      sensorState: sensorState,
      parameters: ParametersMedidor(
        alert: alert,
        height: height,
        levelLow: levelLow,
        levelHigh: levelHigh,
      ),
    );
  }
}

/// Payload de medición en tiempo real: { percent, sensor_state/sensor, battery }
class MedidorMeasurementDto {
  final int percent;
  final int battery;
  final bool sensorState;

  MedidorMeasurementDto({
    required this.percent,
    required this.battery,
    required this.sensorState,
  });

  factory MedidorMeasurementDto.fromJson(Map<String, dynamic> json) {
    return MedidorMeasurementDto(
      percent: (json['percent'] as num).toInt(),
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      sensorState: (json['sensor_state'] ?? json['sensor']) as bool? ?? false,
    );
  }
}
