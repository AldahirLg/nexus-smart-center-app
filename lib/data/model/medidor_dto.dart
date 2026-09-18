import 'package:flutter/foundation.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';

/// Payload inicial: { values: { realtime: {...}, parameters: {...} } }
class MedidorInitialDto {
  final StatusMedidorDto status;
  final ParametersMedidorDto parameters;

  MedidorInitialDto({required this.status, required this.parameters});

  factory MedidorInitialDto.fromJson(Map<String, dynamic> json) {
    return MedidorInitialDto(
      status: StatusMedidorDto.fromJson(
        Map<String, dynamic>.from(json['status']),
      ),
      parameters: ParametersMedidorDto.fromJson(
        Map<String, dynamic>.from(json['parameters']),
      ),
    );
  }

  MedidorModel toDomain() {
    return MedidorModel(
      parameters: parameters.toDomain(),
      status: status.toDomain(),
    );
  }
}

class StatusMedidorDto {
  final int percent;
  final int battery;
  final bool sensorState;
  StatusMedidorDto({
    required this.percent,
    required this.battery,
    required this.sensorState,
  });

  factory StatusMedidorDto.fromJson(Map<String, dynamic> json) {
    return StatusMedidorDto(
      percent: json['percent'],
      battery: json['battery'],
      sensorState: json['sensorState'],
    );
  }

  StatusMedidor toDomain() {
    return StatusMedidor(
      percent: percent,
      battery: battery,
      sensorState: sensorState,
    );
  }
}

class ParametersMedidorDto {
  final bool alert;
  final int height;
  final int levelLow;
  final int levelHigh;
  final String mode;
  final String pointerId;

  ParametersMedidorDto({
    required this.alert,
    required this.height,
    required this.levelLow,
    required this.levelHigh,
    required this.mode,
    required this.pointerId,
  });

  factory ParametersMedidorDto.fromJson(Map<String, dynamic> json) {
    return ParametersMedidorDto(
      alert: json['alert'],
      height: json['height'],
      levelLow: json['levelLow'],
      levelHigh: json['levelHigh'],
      mode: json['mode'],
      pointerId: json['pointerId'],
    );
  }

  factory ParametersMedidorDto.fromDomain(ParametersMedidor model) {
    return ParametersMedidorDto(
      alert: model.alert,
      height: model.height,
      levelLow: model.levelLow,
      levelHigh: model.levelHigh,
      mode: model.mode,
      pointerId: model.pointerId,
    );
  }

  ParametersMedidor toDomain() {
    return ParametersMedidor(
      alert: alert,
      height: height,
      levelLow: levelLow,
      levelHigh: levelHigh,
      mode: mode,
      pointerId: pointerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameters': {
        'alert': alert,
        'height': height,
        'levelHigh': levelHigh,
        'levelLow': levelLow,
        'mode': mode,
        'pointerId': pointerId,
      },
    };
  }
}

sealed class MedidorDtoUpdate {
  const MedidorDtoUpdate();

  factory MedidorDtoUpdate.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      return StatusMedidorUpdate(
        StatusMedidorDto.fromJson(
          Map<String, dynamic>.from(json['status']),
        ).toDomain(),
      );
    }

    if (json.containsKey('parameters')) {
      return ParametersMedidorUpdate(
        ParametersMedidorDto.fromJson(
          Map<String, dynamic>.from(json['parameters']),
        ).toDomain(),
      );
    }
    throw FormatException(
      'Payload de LevelController no reconocido: ${json.keys}',
    );
  }
}

class StatusMedidorUpdate extends MedidorDtoUpdate {
  final StatusMedidor status;
  StatusMedidorUpdate(this.status);
}

class ParametersMedidorUpdate extends MedidorDtoUpdate {
  final ParametersMedidor parameters;

  ParametersMedidorUpdate(this.parameters);
}
