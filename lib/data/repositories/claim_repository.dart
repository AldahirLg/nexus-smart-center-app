import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/model/ble_parse_message.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/ble_service.dart';

enum StateProvisioning {
  idle,
  connectingBle,
  requestingDeviceId,
  working,
  connectingWifi,
  testingWifi,
  successWifi,
  awaitServer,
  serverSucces,
  failed,
  error,
  timeout,
}

class ClaimRepository {
  final BLEservice _ble;
  final FirebaseAuthService _auth;
  final ApiService _api;

  ClaimRepository({
    required BLEservice ble,
    required FirebaseAuthService auth,
    required ApiService api,
  }) : _ble = ble,
       _auth = auth,
       _api = api;

  static final Guid _serviceUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid _rxCharUuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid _txCharUuid = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  static const Duration _deviceIdTimeout = Duration(seconds: 10);
  static const Duration _provisioningTimeout = Duration(seconds: 60);

  final StreamController<StateProvisioning> _provisioningStateController =
      StreamController<StateProvisioning>.broadcast();

  Stream<StateProvisioning> get provisioningState =>
      _provisioningStateController.stream;

  void _setProvisioningState(StateProvisioning state) {
    if (!_provisioningStateController.isClosed) {
      _provisioningStateController.add(state);
    }
  }

  Stream<bool> get isScanning => _ble.isScanning;
  Stream<List<ScanResult>> get scanResults => _ble.scanResults;

  Stream<BluetoothAdapterState> get adapterState => _ble.adapterState;

  Future<void> startScan() async {
    await _ble.startScan(withServices: [_serviceUuid]);
  }

  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) {
    return device.connectionState;
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<String> tokenClaim(String deviceUid) async {
    final tokenId = await _auth.getTokenId();

    if (tokenId == null || tokenId.isEmpty) {
      throw Exception('No se pudo obtener el token de autenticación.');
    }

    try {
      final response = await _api.claimToken(tokenId, deviceUid);

      final claimToken = response.data['claimToken'];
      if (claimToken == null) {
        throw Exception('La API no devolvió claimToken.');
      }
      return claimToken.toString();
    } on DioException catch (e) {
      final backendMessage = e.response?.data['message'] ?? e.message;
      debugPrint('[CLAIM] Backend rechazó el claim: $backendMessage');
      throw Exception(backendMessage);
    }
  }

  Future<String> _requestDeviceId({
    required BluetoothCharacteristic rxChar,
    required Stream<Map<String, dynamic>> messages,
  }) async {
    final completer = Completer<String>();

    final sub = messages.listen((data) {
      if (data['status'] == 'device_id' && !completer.isCompleted) {
        final deviceUid = data['device_uid'];
        if (deviceUid is String && deviceUid.isNotEmpty) {
          completer.complete(deviceUid);
        } else {
          completer.completeError(
            Exception(
              'El dispositivo respondió device_id sin device_uid válido.',
            ),
          );
        }
      }
    });

    try {
      final payload = jsonEncode({'type': 'get_device_id'});
      final payloadBytes = Uint8List.fromList(utf8.encode('$payload\n'));

      debugPrint('[BLE] Solicitando device_uid: $payload');

      await rxChar.write(
        payloadBytes,
        withoutResponse:
            rxChar.properties.writeWithoutResponse && !rxChar.properties.write,
      );

      return await completer.future.timeout(_deviceIdTimeout);
    } on TimeoutException {
      throw Exception(
        'El dispositivo no respondió con su device_uid dentro del tiempo esperado.',
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<Map<String, dynamic>> claimDevice(BluetoothDevice device) async {
    const String ssid = 'INFINITUM83A0_2.4';
    const String password = '5Roble1620';

    final completer = Completer<Map<String, dynamic>>();
    final parser = BleMessageParser();

    final messageController =
        StreamController<Map<String, dynamic>>.broadcast();

    StreamSubscription<List<int>>? valueSub;
    StreamSubscription<BluetoothConnectionState>? disconnectSub;
    StreamSubscription<Map<String, dynamic>>? provisioningSub;
    BluetoothCharacteristic? rxChar;
    BluetoothCharacteristic? txChar;

    try {
      _setProvisioningState(StateProvisioning.connectingBle);

      await device.connect(
        mtu: 185,
        autoConnect: false,
        license: License.nonprofit,
      );

      disconnectSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected &&
            !completer.isCompleted) {
          debugPrint('[BLE] Dispositivo desconectado durante el provisioning.');
          completer.completeError(
            Exception('El dispositivo se desconectó durante el provisioning.'),
          );
          _setProvisioningState(StateProvisioning.error);
        }
      });

      final services = await device.discoverServices();

      final service = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception('Servicio Nordic UART no encontrado.'),
      );

      rxChar = service.characteristics.firstWhere(
        (c) => c.uuid == _rxCharUuid,
        orElse: () => throw Exception('Característica RX no encontrada.'),
      );

      txChar = service.characteristics.firstWhere(
        (c) => c.uuid == _txCharUuid,
        orElse: () => throw Exception('Característica TX no encontrada.'),
      );

      await txChar.setNotifyValue(true);

      valueSub = txChar.lastValueStream.listen(
        (bytes) {
          try {
            debugPrint('[BLE] Fragmento recibido: ${bytes.length} bytes');

            final messages = parser.add(Uint8List.fromList(bytes));

            for (final message in messages) {
              debugPrint('[BLE] Mensaje completo: $message');

              final decoded = jsonDecode(message);
              if (decoded is! Map<String, dynamic>) {
                throw const FormatException(
                  'La respuesta BLE no es un objeto JSON.',
                );
              }

              messageController.add(decoded);
            }
          } catch (e, stackTrace) {
            debugPrint('[BLE] Error procesando mensaje: $e');

            if (!completer.isCompleted) {
              completer.completeError(e, stackTrace);
            }

            _setProvisioningState(StateProvisioning.error);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[BLE] Error en stream: $error');

          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }

          _setProvisioningState(StateProvisioning.error);
        },
      );

      provisioningSub = messageController.stream
          .where((data) => data['status'] != 'device_id')
          .listen((data) => _processMessage(data: data, completer: completer));

      _setProvisioningState(StateProvisioning.requestingDeviceId);
      final deviceUid = await _requestDeviceId(
        rxChar: rxChar,
        messages: messageController.stream,
      );
      debugPrint('[BLE] device_uid recibido: $deviceUid');

      final claimToken = await tokenClaim(deviceUid);

      final payload = jsonEncode({
        'type': 'provision',
        'ssid': ssid,
        'password': password,
        'token_claim': claimToken,
      });

      final payloadBytes = Uint8List.fromList(utf8.encode('$payload\n'));

      debugPrint('[BLE] Enviando provisioning: $payload');

      await rxChar.write(
        payloadBytes,
        withoutResponse:
            rxChar.properties.writeWithoutResponse && !rxChar.properties.write,
      );

      try {
        return await completer.future.timeout(_provisioningTimeout);
      } on TimeoutException {
        _setProvisioningState(StateProvisioning.timeout);
        return {
          'status': 'timeout',
          'message': 'El dispositivo no respondió dentro del tiempo esperado.',
        };
      }
    } catch (e) {
      debugPrint('[CLAIM] Error en provisioning: $e');

      _setProvisioningState(StateProvisioning.error);

      rethrow;
    } finally {
      parser.clear();

      await valueSub?.cancel();
      await disconnectSub?.cancel();
      await provisioningSub?.cancel();
      await messageController.close();
      disconnect(device);
      if (txChar != null) {
        try {
          await txChar.setNotifyValue(false);
        } catch (_) {}
      }
    }
  }

  void _processMessage({
    required Map<String, dynamic> data,
    required Completer<Map<String, dynamic>> completer,
  }) {
    try {
      final status = data['status'];

      debugPrint('[BLE] JSON: $data');
      debugPrint('[BLE] Status: $status');

      switch (status) {
        case 'working':
          _setProvisioningState(StateProvisioning.working);
          break;
        case 'connecting':
          _setProvisioningState(StateProvisioning.connectingWifi);
          break;
        case 'testing':
          _setProvisioningState(StateProvisioning.testingWifi);
          break;
        case 'success':
          _setProvisioningState(StateProvisioning.success);
          if (!completer.isCompleted) completer.complete(data);
          break;
        case 'failed':
          _setProvisioningState(StateProvisioning.failed);
          if (!completer.isCompleted) completer.complete(data);
          break;
        case 'error':
          _setProvisioningState(StateProvisioning.error);
          if (!completer.isCompleted) completer.complete(data);
          break;
        default:
          debugPrint('[BLE] Status desconocido: $status');
      }
    } catch (e, stackTrace) {
      debugPrint('[BLE] Error procesando mensaje: $e');
      debugPrint('[BLE] Data: $data');

      _setProvisioningState(StateProvisioning.error);

      if (!completer.isCompleted) {
        completer.completeError(e, stackTrace);
      }
    }
  }

  Future<void> dispose() async {
    await _provisioningStateController.close();
  }
}
