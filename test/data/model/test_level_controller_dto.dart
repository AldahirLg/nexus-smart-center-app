import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_smart_center/data/model/level_controller_dto.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';

void main() {
  group('LevelControllerInitDto', () {
    test('fromJson convierte correctamente el JSON a DTO', () {
      final json = {
        'status': {
          'tinLevel': 80,
          'cisLevel': 30,
          'tinBattery': 95,
          'sensorCis': true,
          'sensorTin': true,
        },
        'pump': {'isOn': true, 'mode': 'automatic'},
        'parameters': {
          'hTin': 200,
          'hCis': 150,
          'levelLow': 20,
          'levelHigh': 80,
          'minCis': 30,
        },
      };

      final dto = LevelControllerInitDto.fromJson(json);

      expect(dto.status.tinLevel, 80);
      expect(dto.status.cisLevel, 30);
      expect(dto.status.tinBattery, 95);
      expect(dto.status.sensorCis, true);
      expect(dto.status.sensorTin, true);

      expect(dto.pump.isOn, true);
      expect(dto.pump.mode, 'automatic');

      expect(dto.parameters.heightTin, 200);
      expect(dto.parameters.heightCis, 150);
      expect(dto.parameters.minCis, 30);
    });

    test('toDomain convierte correctamente el DTO a Model', () {
      final json = {
        'status': {
          'tinLevel': 80,
          'cisLevel': 30,
          'tinBattery': 95,
          'sensorCis': true,
          'sensorTin': false,
        },
        'pump': {'isOn': true, 'mode': 'manual'},
        'parameters': {
          'hTin': 200,
          'hCis': 150,
          'levelLow': 20,
          'levelHigh': 80,
          'minCis': 30,
        },
      };

      final dto = LevelControllerInitDto.fromJson(json);
      final model = dto.toDomain();

      expect(model, isA<LevelControllerModel>());

      expect(model.status.tinLevel, 80);
      expect(model.status.cisLevel, 30);
      expect(model.status.tinBattery, 95);
      expect(model.status.sensorCis, true);
      expect(model.status.sensorTin, false);

      expect(model.pump.isOn, true);
      expect(model.pump.mode, 'manual');

      expect(model.parameters.heightTin, 200);
      expect(model.parameters.heightCis, 150);
      expect(model.parameters.minCis, 30);
    });
  });

  group('StatusLevelControllerDto', () {
    test('fromJson y toDomain funcionan correctamente', () {
      final json = {
        'tinLevel': 75,
        'cisLevel': 40,
        'tinBattery': 90,
        'sensorCis': true,
        'sensorTin': false,
      };

      final dto = StatusLevelControllerDto.fromJson(json);
      final model = dto.toDomain();

      expect(dto.tinLevel, 75);
      expect(dto.cisLevel, 40);
      expect(dto.tinBattery, 90);
      expect(dto.sensorCis, true);
      expect(dto.sensorTin, false);

      expect(model.tinLevel, 75);
      expect(model.cisLevel, 40);
      expect(model.tinBattery, 90);
      expect(model.sensorCis, true);
      expect(model.sensorTin, false);
    });
  });

  group('PumpLevelControllerDto', () {
    test('fromJson y toDomain funcionan correctamente', () {
      final json = {'isOn': true, 'mode': 'automatic'};

      final dto = PumpLevelControllerDto.fromJson(json);
      final model = dto.toDomain();

      expect(dto.isOn, true);
      expect(dto.mode, 'automatic');

      expect(model.isOn, true);
      expect(model.mode, 'automatic');
    });
  });

  group('ParametersLevelControllerDto', () {
    test('fromJson y toDomain convierten correctamente los parámetros', () {
      final json = {
        'hTin': 200,
        'hCis': 150,
        'levelLow': 20,
        'levelHigh': 80,
        'minCis': 30,
      };

      final dto = ParametersLevelControllerDto.fromJson(json);
      final model = dto.toDomain();

      expect(dto.heightTin, 200);
      expect(dto.heightCis, 150);

      expect(dto.levelLow, 20);
      expect(dto.levelHight, 80);

      expect(dto.minCis, 30);

      expect(model.heightTin, 200);
      expect(model.heightCis, 150);

      expect(model.levelLow, 20);
      expect(model.levelHight, 80);

      expect(model.minCis, 30);
    });
  });
}
