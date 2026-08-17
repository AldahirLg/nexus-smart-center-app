import 'dart:async';

import 'package:nexus_smart_center/data/model/api_user_dto.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';
import 'package:nexus_smart_center/models/api_user_model.dart';

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
    _socketClient.connect(idToken);
    Map<String, dynamic> dataUser = response.data;
    return ApiUserDto.fromJson(dataUser).toDomain();
  }

  Future<dynamic> claimToken(String tokenId, String deviceId) async {
    final response = await _apiService.claimToken(tokenId, deviceId);
    return response;
  }

  Future<void> emitEvent(String event, dynamic data) async {
    _socketClient.emit(event, data);
  }

  Future<void> onEvent(String event, Function(dynamic) handler) async {
    _socketClient.on(event, handler);
  }
}
