import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';

class RealTimeRepository {
  final SocketClient _socket;
  final FirebaseAuthService _auth;

  RealTimeRepository({
    required SocketClient socket,
    required FirebaseAuthService auth,
  }) : _auth = auth,
       _socket = socket;

  Future<Map<String, dynamic>> subscribeDevice(String deviceId) async {
    await _ensureConnection();

    try {
      final response = await _socket.emitWithAck('device:subscribe', {
        'deviceId': deviceId,
      });

      final json = Map<String, dynamic>.from(response);

      if (json['ok'] != true) {
        throw Exception(json['error'] ?? 'No se pudo suscribir al dispositivo');
      }

      return json;
    } catch (e) {
      throw Exception('No se pudo suscribir al dispositivo: $e');
    }
  }

  Future<void> _ensureConnection() async {
    if (_socket.isConnected) {
      return;
    }

    final tokenId = await _auth.getTokenId();

    if (tokenId == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }

    await _socket.connect(tokenId);
  }

  void listenDeviceData(void Function(dynamic data) onData) {
    _socket.on('device:data', onData);
  }

  void stopListeningDeviceData() {
    _socket.off('device:data');
  }

  Future<void> sendCommand({
    required String deviceId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _socket.emitWithAck('device:command', {
      'deviceId': deviceId,
      'action': action,
      'payload': payload,
    });

    final json = Map<String, dynamic>.from(response);

    if (json['ok'] != true) {
      throw Exception(json['error'] ?? 'No se pudo enviar el comando');
    }
  }
}
