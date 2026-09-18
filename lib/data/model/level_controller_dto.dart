import 'package:nexus_smart_center/models/level_controller_model.dart';

class LevelControllerInitDto {
  final StatusLevelControllerDto status;
  final PumpLevelControllerDto pump;
  final ParametersLevelControllerDto parameters;

  LevelControllerInitDto({
    required this.status,
    required this.pump,
    required this.parameters,
  });

  factory LevelControllerInitDto.fromJson(Map<String, dynamic> json) {
    return LevelControllerInitDto(
      status: StatusLevelControllerDto.fromJson(
        Map<String, dynamic>.from(json['status']),
      ),
      pump: PumpLevelControllerDto.fromJson(
        Map<String, dynamic>.from(json['pump']),
      ),
      parameters: ParametersLevelControllerDto.fromJson(
        Map<String, dynamic>.from(json['parameters']),
      ),
    );
  }

  factory LevelControllerInitDto.fromDomain(LevelControllerModel model) {
    return LevelControllerInitDto(
      status: StatusLevelControllerDto.fromDomain(model.status),
      pump: PumpLevelControllerDto.fromDomain(model.pump),
      parameters: ParametersLevelControllerDto.fromDomain(model.parameters),
    );
  }

  LevelControllerModel toDomain() {
    return LevelControllerModel(
      status: status.toDomain(),
      pump: pump.toDomain(),
      parameters: parameters.toDomain(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toJson(),
      'pump': pump.toJson(),
      'parameters': parameters.toJson(),
    };
  }
}

class StatusLevelControllerDto {
  final int tinLevel;
  final int cisLevel;
  final int tinBattery;
  final bool sensorCis;
  final bool sensorTin;

  StatusLevelControllerDto({
    required this.tinLevel,
    required this.cisLevel,
    required this.tinBattery,
    required this.sensorCis,
    required this.sensorTin,
  });

  factory StatusLevelControllerDto.fromJson(Map<String, dynamic> json) {
    return StatusLevelControllerDto(
      tinLevel: json['tinLevel'],
      cisLevel: json['cisLevel'],
      sensorCis: json['sensorCis'],
      sensorTin: json['sensorTin'],
      tinBattery: json['tinBattery'],
    );
  }

  factory StatusLevelControllerDto.fromDomain(StatusLevelController model) {
    return StatusLevelControllerDto(
      tinLevel: model.tinLevel,
      cisLevel: model.cisLevel,
      tinBattery: model.tinBattery,
      sensorCis: model.sensorCis,
      sensorTin: model.sensorTin,
    );
  }

  StatusLevelController toDomain() {
    return StatusLevelController(
      tinLevel: tinLevel,
      cisLevel: cisLevel,
      tinBattery: tinBattery,
      sensorCis: sensorCis,
      sensorTin: sensorTin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': {
        'tinLevel': tinLevel,
        'cisLevel': cisLevel,
        'tinBattery': tinBattery,
        'sensorCis': sensorCis,
        'sensorTin': sensorTin,
      },
    };
  }
}

class PumpLevelControllerDto {
  final bool isOn;
  final String mode;

  PumpLevelControllerDto({required this.isOn, required this.mode});

  factory PumpLevelControllerDto.fromJson(Map<String, dynamic> json) {
    return PumpLevelControllerDto(isOn: json['isOn'], mode: json['mode']);
  }

  factory PumpLevelControllerDto.fromDomain(PumpLevelController model) {
    return PumpLevelControllerDto(isOn: model.isOn, mode: model.mode);
  }

  PumpLevelController toDomain() {
    return PumpLevelController(isOn: isOn, mode: mode);
  }

  Map<String, dynamic> toJson() {
    return {
      'pump': {'isOn': isOn, 'mode': mode},
    };
  }
}

class ParametersLevelControllerDto {
  final int heightTin;
  final int heightCis;
  final int levelLow;
  final int levelHight;
  final int minCis;

  ParametersLevelControllerDto({
    required this.heightTin,
    required this.heightCis,
    required this.levelLow,
    required this.levelHight,
    required this.minCis,
  });

  factory ParametersLevelControllerDto.fromJson(Map<String, dynamic> json) {
    return ParametersLevelControllerDto(
      heightTin: json['hTin'],
      heightCis: json['hCis'],
      levelLow: json['levelLow'],
      levelHight: json['levelHigh'],
      minCis: json['minCis'],
    );
  }

  factory ParametersLevelControllerDto.fromDomain(
    ParametersLevelController model,
  ) {
    return ParametersLevelControllerDto(
      heightTin: model.heightTin,
      heightCis: model.heightCis,
      levelLow: model.levelLow,
      levelHight: model.levelHight,
      minCis: model.minCis,
    );
  }

  ParametersLevelController toDomain() {
    return ParametersLevelController(
      heightTin: heightTin,
      heightCis: heightCis,
      levelLow: levelLow,
      levelHight: levelHight,
      minCis: minCis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameters': {
        'hTin': heightTin,
        'hCis': heightCis,
        'levelLow': levelLow,
        'levelHigh': levelHight,
        'minCis': minCis,
      },
    };
  }
}

sealed class LevelControllerUpdate {
  const LevelControllerUpdate();

  factory LevelControllerUpdate.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      return StatusUpdate(
        StatusLevelControllerDto.fromJson(
          Map<String, dynamic>.from(json['status']),
        ).toDomain(),
      );
    }
    if (json.containsKey('pump')) {
      return PumpUpdate(
        PumpLevelControllerDto.fromJson(
          Map<String, dynamic>.from(json['pump']),
        ).toDomain(),
      );
    }
    if (json.containsKey('parameters')) {
      return ParametersUpdate(
        ParametersLevelControllerDto.fromJson(
          Map<String, dynamic>.from(json['parameters']),
        ).toDomain(),
      );
    }
    throw FormatException(
      'Payload de LevelController no reconocido: ${json.keys}',
    );
  }
}

class StatusUpdate extends LevelControllerUpdate {
  final StatusLevelController status;
  const StatusUpdate(this.status);
}

class PumpUpdate extends LevelControllerUpdate {
  final PumpLevelController pump;
  const PumpUpdate(this.pump);
}

class ParametersUpdate extends LevelControllerUpdate {
  final ParametersLevelController parameters;
  const ParametersUpdate(this.parameters);
}
