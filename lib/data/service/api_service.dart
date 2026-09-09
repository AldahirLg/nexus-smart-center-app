import 'package:dio/dio.dart';

class ApiService {
  const ApiService(this._dio);

  final Dio _dio;
  Future<Response> syncUser({required String idToken}) async {
    final response = await _dio.post(
      '/user/sync',
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
      '/device/',
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
}
