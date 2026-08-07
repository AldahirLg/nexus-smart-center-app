import 'package:dio/dio.dart';

class ApiService {
  const ApiService(this._dio);

  final Dio _dio;
  Future<Response> syncUser({required String idToken}) async {
    final response = await _dio.post(
      '/user/auth/sync',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    return response;
  }
}
