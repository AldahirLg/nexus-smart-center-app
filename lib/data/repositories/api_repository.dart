import 'dart:async';

import 'package:dio/dio.dart';
import 'package:nexus_smart_center/data/model/api_device_dto.dart';
import 'package:nexus_smart_center/data/model/api_user_dto.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';
import 'package:nexus_smart_center/models/device_model.dart';

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
    final devicesRow = await _apiService.getDevices(idToken);
    if (devicesRow.statusCode != 200) {
      throw Exception('Error al obtener dispositivos');
    }

    List<dynamic> devices = devicesRow.data;
    return devices
        .map((json) => ApiDeviceDto.fromJson(json).toDomain())
        .toList();
  }

  Future<List<DeviceModel>> getMedidores(String idToken) async {
    final devicesRow = await _apiService.getMedidores(idToken);
    if (devicesRow.statusCode != 200) {
      throw Exception('Error al obtener dispositivos');
    }
    List<dynamic> devices = devicesRow.data;
    return devices
        .map((json) => ApiDeviceDto.fromJson(json).toDomain())
        .toList();
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
}
