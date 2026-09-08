class MedidorModel {
  final int percent;
  final int battery;
  final bool sensorState;
  final ParametersMedidor parameters;

  const MedidorModel({
    required this.percent,
    required this.battery,
    required this.sensorState,
    required this.parameters,
  });

  MedidorModel copyWith({
    int? percent,
    int? battery,
    bool? sensorState,
    ParametersMedidor? parameters,
  }) {
    return MedidorModel(
      percent: percent ?? this.percent,
      battery: battery ?? this.battery,
      sensorState: sensorState ?? this.sensorState,
      parameters: parameters ?? this.parameters,
    );
  }
}

class ParametersMedidor {
  final bool alert;
  final int height;
  final int levelLow;
  final int levelHigh;

  const ParametersMedidor({
    required this.alert,
    required this.height,
    required this.levelLow,
    required this.levelHigh,
  });

  ParametersMedidor copyWith({
    bool? alert,
    int? height,
    int? levelLow,
    int? levelHigh,
  }) {
    return ParametersMedidor(
      alert: alert ?? this.alert,
      height: height ?? this.height,
      levelLow: levelLow ?? this.levelLow,
      levelHigh: levelHigh ?? this.levelHigh,
    );
  }
}
