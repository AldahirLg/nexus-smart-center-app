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
    String deviceType,
    dynamic Function(dynamic) onInitialData,
    dynamic Function(dynamic) onMeasurement,
  ) async {
    await _ensureConnection();

    _socket.on('$deviceType:updated', onInitialData);
    _socket.on(deviceType, onMeasurement);

    try {
      _socket.emit('device', {'uid': deviceId, 'type': deviceType});
    } catch (e) {
      throw Exception('No se pudo establecer conexión con el dispositivo');
    }
  }

  Future<void> updateParameters({required String type, dynamic data}) async {
    await _ensureConnection();
    try {
      _socket.emit('$type:update', data);
    } catch (e) {
      throw Exception('No se pudo actualizar la configuración del $type');
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
