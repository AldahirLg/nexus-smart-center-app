import 'dart:async';

import 'package:dio/dio.dart';
import 'package:nexus_smart_center/data/model/api_device_dto.dart';
import 'package:nexus_smart_center/data/model/api_user_dto.dart';
import 'package:nexus_smart_center/data/model/medidor_dto.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';

class ApiRepository {
  ApiRepository({
    required ApiService apiService,
    required SocketClient socketClient,
  }) : _apiService = apiService,
       _socketClient = socketClient;
  final ApiService _apiService;
  final SocketClient _socketClient;

  Future<ApiUserModel> synchronizeUser(String idToken) async {
    final response = await _apiService.syncUser(idToken: idToken);
    if (response.statusCode != 200) {
      throw Exception('Error al syncronizar usuario');
    }
    await _socketClient.connect(idToken);
    Map<String, dynamic> dataUser = response.data;
    return ApiUserDto.fromJson(dataUser).toDomain();
  }

  Future<List<DeviceModel>> getDevices(String idToken) async {
    final response = await _apiService.getDevices(idToken);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener dispositivos');
    }

    final data = response.data as Map<String, dynamic>;
    final devicesJson = data['devices'] as List<dynamic>? ?? [];

    return devicesJson
        .map(
          (json) =>
              ApiDeviceDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();
  }

  Future<List<DeviceModel>> getLevelContorllers(String idToken) async {
    final response = await _apiService.getLevelController(idToken);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener dispositivos');
    }

    final data = response.data as Map<String, dynamic>;
    final devicesJson = data['devices'] as List<dynamic>? ?? [];

    return devicesJson
        .map(
          (json) =>
              ApiDeviceDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();
  }

  Future<ParametersMedidor> setParametersMedidor(
    String idToken,
    String deviceId,
    Map<String, dynamic> json,
  ) async {
    final response = await _apiService.setParametersMedidor(
      idToken,
      deviceId,
      json,
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cambiar parametros');
    }
    return ParametersMedidorDto.fromJson(
      response.data['parameters'],
    ).toDomain();
  }

  Future<void> changeModeMedidor(
    String idToken,
    String deviceId,
    String type,
    String data,
  ) async {
    final changeMode = await _apiService.changeModeMedidor(
      idToken,
      deviceId,
      type,
      data,
    );
    if (changeMode.statusCode != 200) {
      throw Exception('Error al cambiar de modo de dispositivos');
    }
  }

  Future<DeviceModel> updateNameDevice(
    String idToken,
    String deviceId,
    String name,
  ) async {
    final update = await _apiService.updateNameDevice(idToken, deviceId, name);
    if (update.statusCode != 200) {
      throw Exception('Error al actualizar nombre');
    }
    return ApiDeviceDto.fromJson(
      update.data['device'] as Map<String, dynamic>,
    ).toDomain();
  }
}
