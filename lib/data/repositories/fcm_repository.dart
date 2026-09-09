import 'package:nexus_smart_center/data/service/fcm_service.dart';

import 'package:nexus_smart_center/data/service/api_service.dart';

class FcmRepository {
  FcmRepository({
    required FcmService fcmService,
    required ApiService apiService,
  }) : _fcmService = fcmService,
       _apiService = apiService;

  final FcmService _fcmService;
  final ApiService _apiService;

  Stream<String> get tokenRefresh => _fcmService.tokenRefresh;

  Future<String?> getToken() {
    return _fcmService.getFcmToken();
  }

  Future<void> registerToken({
    required String idToken,
    required String fcmToken,
  }) async {
    final response = await _apiService.registerFcmToken(idToken, fcmToken);

    if (response.statusCode != 200) {
      throw Exception('Error al registrar FCM token');
    }
  }
}
