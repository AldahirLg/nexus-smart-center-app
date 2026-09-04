import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/model/ble_parse_message.dart';
import 'package:nexus_smart_center/data/service/ble_service.dart';

enum BleProvisioningState {
  idle,
  connecting,
  discoveringServices,
  connected,
  requestingDeviceId,
  deviceIdReceived,
  sendingCredentials,
  working,
  connectingWifi,
  testingWifi,
  success,
  failed,
  error,
  timeout,
  disconnected,
}

class BleRepository {
  final BLEservice _ble;

  BleRepository({required BLEservice ble}) : _ble = ble;

  static final Guid serviceUuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid rxCharUuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid txCharUuid = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _deviceIdTimeout = Duration(seconds: 10);
  static const Duration _provisioningTimeout = Duration(seconds: 60);

  final StreamController<BleProvisioningState> _stateController =
      StreamController<BleProvisioningState>.broadcast();

  Stream<BleProvisioningState> get state => _stateController.stream;

  void _setState(BleProvisioningState newState) {
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Stream<bool> get isScanning => _ble.isScanning;
  Stream<List<ScanResult>> get scanResults => _ble.scanResults;
  Stream<BluetoothAdapterState> get adapterState => _ble.adapterState;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _disconnectSub;
  StreamController<Map<String, dynamic>>? _messageController;
  BleMessageParser? _parser;

  Stream<Map<String, dynamic>> get messages =>
      _messageController?.stream ?? const Stream.empty();

  Future<void> startScan() => _ble.startScan(withServices: [serviceUuid]);

  Future<void> stopScan() => _ble.stopScan();

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) =>
      _ble.connectionState(device);

  Future<void> connectAndPrepare(BluetoothDevice device) async {
    _parser = BleMessageParser();
    _messageController = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _setState(BleProvisioningState.connecting);

      await _ble.connect(device, _connectTimeout);
      _device = device;

      _disconnectSub = _ble.connectionState(device).listen((connState) {
        if (connState == BluetoothConnectionState.disconnected) {
          debugPrint('[BLE] Dispositivo desconectado.');
          _setState(BleProvisioningState.disconnected);
        }
      });

      await _ble.requestMtu(device, desired: 185);

      _setState(BleProvisioningState.discoveringServices);
      final services = await _ble.discoverServices(device);

      BluetoothService? service;
      for (final s in services) {
        if (s.uuid == serviceUuid) {
          service = s;
          break;
        }
      }
      if (service == null) {
        throw Exception('Servicio Nordic UART no encontrado.');
      }

      BluetoothCharacteristic? rxChar;
      BluetoothCharacteristic? txChar;
      for (final c in service.characteristics) {
        if (c.uuid == rxCharUuid) rxChar = c;
        if (c.uuid == txCharUuid) txChar = c;
      }
      if (rxChar == null) throw Exception('Característica RX no encontrada.');
      if (txChar == null) throw Exception('Característica TX no encontrada.');

      _rxChar = rxChar;

      final notifyStream = await _ble.subscribe(
        device,
        serviceUuid,
        txCharUuid,
      );
      _notifySub = notifyStream.listen(
        _onNotificationData,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[BLE] Error en stream de notificaciones: $error');
          _messageController?.addError(error, stackTrace);
          _setState(BleProvisioningState.error);
        },
      );

      _setState(BleProvisioningState.connected);
    } catch (e) {
      _setState(BleProvisioningState.error);
      rethrow;
    }
  }

  void _onNotificationData(List<int> bytes) {
    try {
      debugPrint('[BLE] Fragmento recibido: ${bytes.length} bytes');

      final parsedMessages =
          _parser?.add(Uint8List.fromList(bytes)) ?? const [];

      for (final message in parsedMessages) {
        debugPrint('[BLE] Mensaje completo: $message');

        final decoded = jsonDecode(message);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('La respuesta BLE no es un objeto JSON.');
        }

        _messageController?.add(decoded);
        _updateStateFromStatus(decoded['status']);
      }
    } catch (e, stackTrace) {
      debugPrint('[BLE] Error procesando mensaje: $e');
      _messageController?.addError(e, stackTrace);
      _setState(BleProvisioningState.error);
    }
  }

  void _updateStateFromStatus(dynamic status) {
    switch (status) {
      case 'working':
        _setState(BleProvisioningState.working);
        break;
      case 'connecting':
        _setState(BleProvisioningState.connectingWifi);
        break;
      case 'testing':
        _setState(BleProvisioningState.testingWifi);
        break;
      case 'success':
        _setState(BleProvisioningState.success);
        break;
      case 'failed':
        _setState(BleProvisioningState.failed);
        break;
      case 'error':
        _setState(BleProvisioningState.error);
        break;
      default:
        break;
    }
  }

  Future<void> _writeToRx(Map<String, dynamic> payload) async {
    final rxChar = _rxChar;
    if (rxChar == null) {
      throw Exception(
        'El dispositivo BLE no está preparado. Llama a connectAndPrepare primero.',
      );
    }

    final encoded = jsonEncode(payload);
    final payloadBytes = Uint8List.fromList(utf8.encode('$encoded\n'));

    debugPrint('[BLE] Enviando: $encoded');

    await rxChar.write(
      payloadBytes,
      withoutResponse:
          rxChar.properties.writeWithoutResponse && !rxChar.properties.write,
    );
  }

  Future<String> requestDeviceId() async {
    final messageController = _messageController;
    if (messageController == null) {
      throw Exception(
        'El dispositivo BLE no está preparado. Llama a connectAndPrepare primero.',
      );
    }

    _setState(BleProvisioningState.requestingDeviceId);

    final completer = Completer<String>();

    final sub = messageController.stream.listen((data) {
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
      await _writeToRx({'type': 'get_device_id'});

      final deviceUid = await completer.future.timeout(_deviceIdTimeout);
      _setState(BleProvisioningState.deviceIdReceived);
      return deviceUid;
    } on TimeoutException {
      _setState(BleProvisioningState.timeout);
      throw Exception(
        'El dispositivo no respondió con su device_uid dentro del tiempo esperado.',
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<Map<String, dynamic>> sendProvisioningPayload({
    required String ssid,
    required String password,
    required String tokenClaim,
  }) async {
    final messageController = _messageController;
    if (messageController == null) {
      throw Exception(
        'El dispositivo BLE no está preparado. Llama a connectAndPrepare primero.',
      );
    }

    _setState(BleProvisioningState.sendingCredentials);

    final completer = Completer<Map<String, dynamic>>();

    final sub = messageController.stream
        .where((data) => data['status'] != 'device_id')
        .listen((data) {
          final status = data['status'];
          if ((status == 'success' ||
                  status == 'failed' ||
                  status == 'error') &&
              !completer.isCompleted) {
            completer.complete(data);
          }
        });

    try {
      await _writeToRx({
        'type': 'provision',
        'ssid': ssid,
        'password': password,
        'token_claim': tokenClaim,
      });

      return await completer.future.timeout(_provisioningTimeout);
    } on TimeoutException {
      _setState(BleProvisioningState.timeout);
      return {
        'status': 'timeout',
        'message': 'El dispositivo no respondió dentro del tiempo esperado.',
      };
    } finally {
      await sub.cancel();
    }
  }

  Future<void> disconnect() async {
    final device = _device;

    await _notifySub?.cancel();
    await _disconnectSub?.cancel();
    await _messageController?.close();
    _parser?.clear();

    _notifySub = null;
    _disconnectSub = null;
    _messageController = null;
    _parser = null;
    _rxChar = null;
    _device = null;

    if (device != null) {
      try {
        await _ble.disconnect(device);
      } catch (e) {
        debugPrint('[BLE] Error al desconectar: $e');
      }
    }

    _setState(BleProvisioningState.disconnected);
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
  }
}
