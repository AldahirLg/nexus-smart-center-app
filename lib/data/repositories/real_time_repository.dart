import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';

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

    _socket.on('device:updated', onInitialData);
    _socket.on('device', onMeasurement);

    try {
      _socket.emit('device', {'uid': deviceId, 'type': deviceType});
    } catch (e) {
      throw Exception('No se pudo establecer conexión con el dispositivo');
    }
  }

  Future<void> updateParameters({
    required DeviceModel device,
    required Map<String, dynamic> payload,
  }) async {
    await _ensureConnection();

    try {
      final data = {
        'type': DeviceIconMapper.getTypeString(device.type),
        'deviceId': device.id,
        'payload': payload,
      };

      _socket.emit('device:update', data);
    } catch (e) {
      throw Exception('No se pudo actualizar el dispositivo');
    }
  }

  Future<void> sendCommand({
    required DeviceModel device,
    required Map<String, dynamic> payload,
  }) async {
    await _ensureConnection();

    try {
      final data = {
        'type': DeviceIconMapper.getTypeString(device.type),
        'deviceId': device.id,
        'payload': payload,
      };

      _socket.emit('device:command', data);
    } catch (e) {
      throw Exception('No se pudo actualizar el dispositivo');
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
    _socket.off('device');
    _socket.off('device:updated');
  }
}
