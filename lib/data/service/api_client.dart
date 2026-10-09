import 'package:dio/dio.dart';
import 'package:nexus_smart_center/config/app_config.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}
