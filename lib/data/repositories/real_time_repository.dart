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

  Future<void> onDevice(
    String deviceId,
    dynamic Function(dynamic) onInitialData,
    dynamic Function(dynamic) onMeasurement,
  ) async {
    await _ensureConnection();

    _socket.on('medidor:init', onInitialData);
    _socket.on('medidor', onMeasurement);

    try {
      _socket.emit('device', {'uid': deviceId});
    } catch (e) {
      throw Exception('No se pudo establecer conexión con el dispositivo');
    }
  }

  Future<void> updateMedidor({
    required String deviceId,
    required double height,
    required double levelHigh,
    required double levelLow,
    required bool alert,
    required dynamic Function(dynamic) handler,
  }) async {
    await _ensureConnection();

    _socket.on('medidor:updated', handler);

    try {
      _socket.emit('medidor:update', {
        'deviceId': deviceId,
        'height': height,
        'levelHigh': levelHigh,
        'levelLow': levelLow,
        'alert': alert,
      });
    } catch (e) {
      throw Exception('No se pudo actualizar la configuración del medidor');
    }
  }

  Future<void> _ensureConnection() async {
    if (!_socket.isConnected) {
      final tokenId = await _auth.getTokenId();

      if (tokenId == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      await _socket.connect(tokenId);
    }
  }

  Future<void> dispose() async {
    _socket.off('medidor:init');
    _socket.off('medidor');
    _socket.off('medidor:updated');
  }
}
