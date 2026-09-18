class MedidorModel {
  final StatusMedidor status;
  final ParametersMedidor parameters;

  const MedidorModel({required this.parameters, required this.status});

  MedidorModel copyWith({
    StatusMedidor? status,
    ParametersMedidor? parameters,
  }) {
    return MedidorModel(
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
    );
  }
}

class StatusMedidor {
  final int percent;
  final int battery;
  final bool sensorState;

  StatusMedidor({
    required this.percent,
    required this.battery,
    required this.sensorState,
  });

  StatusMedidor copyWith({int? percent, int? battery, bool? sensorState}) {
    return StatusMedidor(
      percent: percent ?? this.percent,
      battery: battery ?? this.battery,
      sensorState: sensorState ?? this.sensorState,
    );
  }
}

class ParametersMedidor {
  final bool alert;
  final int height;
  final int levelLow;
  final int levelHigh;
  final String mode;
  final String pointerId;

  const ParametersMedidor({
    required this.alert,
    required this.height,
    required this.levelLow,
    required this.levelHigh,
    required this.mode,
    required this.pointerId,
  });

  ParametersMedidor copyWith({
    bool? alert,
    int? height,
    int? levelLow,
    int? levelHigh,
    String? mode,
    String? pointerId,
  }) {
    return ParametersMedidor(
      alert: alert ?? this.alert,
      height: height ?? this.height,
      levelLow: levelLow ?? this.levelLow,
      levelHigh: levelHigh ?? this.levelHigh,
      mode: mode ?? mode ?? this.mode,
      pointerId: pointerId ?? this.pointerId,
    );
  }
}
