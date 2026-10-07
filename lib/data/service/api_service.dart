import 'package:dio/dio.dart';

class ApiService {
  const ApiService(this._dio);

  final Dio _dio;
  Future<Response> syncUser({required String idToken}) async {
    final response = await _dio.post(
      '/auth/sync',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return response;
  }

  Future<Response> claimToken(String idToken, String deviceId) async {
    final response = await _dio.post(
      '/device/claim',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {'deviceId': deviceId},
    );
    return response;
  }

  Future<Response> getDevices(String idToken) async {
    final response = await _dio.get(
      '/devices/',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return response;
  }

  // mejorar este get
  Future<Response> getLevelController(String idToken) async {
    final response = await _dio.get(
      '/devices',
      queryParameters: {'type': 'control_de_nivel'},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return response;
  }

  Future<Response> registerFcmToken(String idToken, String fcmToken) async {
    return _dio.post(
      '/user/fcm-token',
      data: {'token': fcmToken},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
  }

  Future<Response> setParametersMedidor(
    String idToken,
    String deviceId,
    Map<String, dynamic> json,
  ) async {
    final response = await _dio.post(
      '/device/medidor/$deviceId/',
      data: json,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return response;
  }

  Future<Response> changeModeMedidor(
    String idToken,
    String deviceId,
    String type,
    data,
  ) async {
    final response = await _dio.post(
      '/device/change-mode-medidor',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {'deviceId': deviceId, 'type': type, 'data': data},
    );
    return response;
  }

  Future<Response> updateNameDevice(
    String idToken,
    String deviceId,
    String name,
  ) async {
    return await _dio.patch(
      '/device/$deviceId/name',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
  }
}
