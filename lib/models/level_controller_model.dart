class LevelControllerModel {
  final StatusLevelController status;
  final PumpLevelController pump;
  final ParametersLevelController parameters;

  const LevelControllerModel({
    required this.status,
    required this.pump,
    required this.parameters,
  });

  LevelControllerModel copyWith({
    StatusLevelController? status,
    PumpLevelController? pump,
    ParametersLevelController? parameters,
  }) {
    return LevelControllerModel(
      status: status ?? this.status,
      pump: pump ?? this.pump,
      parameters: parameters ?? this.parameters,
    );
  }
}

class StatusLevelController {
  final int tinLevel;
  final int cisLevel;
  final int tinBattery;
  final bool sensorCis;
  final bool sensorTin;

  StatusLevelController({
    required this.tinLevel,
    required this.cisLevel,
    required this.tinBattery,
    required this.sensorCis,
    required this.sensorTin,
  });
}

class PumpLevelController {
  final bool isOn;
  final String mode;

  PumpLevelController({required this.isOn, required this.mode});

  PumpLevelController copyWith({bool? isOn, String? mode}) {
    return PumpLevelController(
      isOn: isOn ?? this.isOn,
      mode: mode ?? this.mode,
    );
  }
}

class ParametersLevelController {
  final int heightTin;
  final int heightCis;
  final int levelLow;
  final int levelHight;
  final int minCis;

  ParametersLevelController({
    required this.heightTin,
    required this.heightCis,
    required this.levelLow,
    required this.levelHight,
    required this.minCis,
  });

  ParametersLevelController copyWith({
    int? heightTin,
    int? heightCis,
    int? levelLow,
    int? levelHight,
    int? minCis,
  }) {
    return ParametersLevelController(
      heightTin: heightTin ?? this.heightTin,
      heightCis: heightCis ?? this.heightCis,
      levelLow: levelLow ?? this.levelLow,
      levelHight: levelHight ?? this.levelHight,
      minCis: minCis ?? this.minCis,
    );
  }
}
