import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/model/ble_parse_message.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/ble_service.dart';

enum StateProvisioning {
  idle,
  connectingBle,
  working,
  connectingWifi,
  testingWifi,
  success,
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

  Future<String> tokenClaim(BluetoothDevice device) async {
    final tokenId = await _auth.getTokenId();

    if (tokenId == null || tokenId.isEmpty) {
      throw Exception('No se pudo obtener el token de autenticación.');
    }

    final response = await _api.claimToken(tokenId, device.remoteId.str);

    final claimToken = response.data['claimToken'];

    if (claimToken == null) {
      throw Exception('La API no devolvió claimToken.');
    }

    return claimToken.toString();
  }

  Future<Map<String, dynamic>> claimDevice(BluetoothDevice device) async {
    const String ssid = 'Rios_Net';
    const String password = '5Roble162';

    final completer = Completer<Map<String, dynamic>>();
    final parser = BleMessageParser();

    StreamSubscription<List<int>>? valueSub;
    StreamSubscription<BluetoothConnectionState>? disconnectSub;
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
              _processMessage(message: message, completer: completer);
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

      final claimToken = await tokenClaim(device);

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
        return await completer.future.timeout(const Duration(seconds: 60));
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
      disconnect(device);
      if (txChar != null) {
        try {
          await txChar.setNotifyValue(false);
        } catch (_) {}
      }
    }
  }

  void _processMessage({
    required String message,
    required Completer<Map<String, dynamic>> completer,
  }) {
    try {
      final decoded = jsonDecode(message);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('La respuesta BLE no es un objeto JSON.');
      }

      final data = decoded;
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
      debugPrint('[BLE] Error parseando JSON: $e');
      debugPrint('[BLE] Mensaje: $message');

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
