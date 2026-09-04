import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nexus_smart_center/data/service/ble_exception.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEservice {
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  final Map<BluetoothDevice, List<BluetoothService>> _servicesCache = {};
  final Map<(BluetoothDevice, Guid), StreamSubscription<List<int>>>
  _subscriptionMap = {};
  final Map<BluetoothDevice, Future> _writeQueues = {};

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final connectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    return scanGranted && connectGranted;
  }

  Future<void> startScan({List<Guid> withServices = const []}) async {
    if (FlutterBluePlus.isScanningNow) return;

    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) return;

    final adapter = await FlutterBluePlus.adapterState.first;
    if (adapter != BluetoothAdapterState.on) return;

    await FlutterBluePlus.startScan(
      androidScanMode: AndroidScanMode.lowLatency,
      withServices: withServices,
      timeout: const Duration(seconds: 10),
    );
  }

  Future<void> stopScan() async {
    if (!FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device, Duration timeout) async {
    try {
      await device.connect(license: License.nonprofit, timeout: timeout);
      final state = await device.connectionState
          .firstWhere((state) => state == BluetoothConnectionState.connected)
          .timeout(timeout);
      if (state != BluetoothConnectionState.connected) {
        throw const BleConnectionException(
          'El dispositivo no quedó conectado.',
        );
      }
    } on TimeoutException {
      throw BleTimeoutException('Timeout al conectar con ${device.advName}');
    } on BleTransportException {
      rethrow;
    } catch (e) {
      throw BleConnectionException(
        'No se pudo conectar con ${device.advName}: $e',
      );
    }
  }

  Future<void> disconnect(BluetoothDevice device) async {
    try {
      final keysToRemove = _subscriptionMap.keys
          .where((key) => key.$1 == device)
          .toList();
      for (final key in keysToRemove) {
        final sub = _subscriptionMap.remove(key);
        await sub?.cancel();
      }

      _writeQueues.remove(device);
      _servicesCache.remove(device);

      await device.disconnect();
    } catch (e) {
      throw BleConnectionException(
        'Error al desconectar ${device.advName}: $e',
      );
    }
  }

  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) {
    return device.connectionState;
  }

  Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    if (_servicesCache.containsKey(device)) {
      return _servicesCache[device]!;
    }

    try {
      final services = await device.discoverServices();
      _servicesCache[device] = services;
      return services;
    } catch (e) {
      throw BleConnectionException(
        'Error al descubrir servicios de ${device.advName}: $e',
      );
    }
  }

  Future<int> requestMtu(BluetoothDevice device, {int desired = 247}) async {
    try {
      return await device.requestMtu(desired);
    } catch (e) {
      return device.mtuNow;
    }
  }

  Future<BluetoothCharacteristic> _findCharacteristic(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final services = await discoverServices(device);

    BluetoothService? service;
    for (final s in services) {
      if (s.uuid == serviceUuid) {
        service = s;
        break;
      }
    }
    if (service == null) throw BleServiceNotFoundException(serviceUuid);

    BluetoothCharacteristic? characteristic;
    for (final c in service.characteristics) {
      if (c.uuid == characteristicUuid) {
        characteristic = c;
        break;
      }
    }
    if (characteristic == null)
      throw BleCharacteristicNotFoundException(characteristicUuid);

    return characteristic;
  }

  Future<List<int>> read(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final characteristic = await _findCharacteristic(
      device,
      serviceUuid,
      characteristicUuid,
    );
    try {
      return await characteristic.read();
    } catch (e) {
      throw BleWriteException('Error al leer $characteristicUuid: $e');
    }
  }

  Future<void> write(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
    List<int> value, {
    bool withoutResponse = false,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final previous = _writeQueues[device] ?? Future.value();
    final operation = previous.then((_) async {
      final characteristic = await _findCharacteristic(
        device,
        serviceUuid,
        characteristicUuid,
      );
      try {
        await characteristic
            .write(value, withoutResponse: withoutResponse)
            .timeout(timeout);
      } on TimeoutException {
        throw BleTimeoutException('Timeout al escribir en $characteristicUuid');
      } catch (e) {
        throw BleWriteException('Error al escribir en $characteristicUuid: $e');
      }
    });

    _writeQueues[device] = operation.catchError((_) {});
    return operation;
  }

  Future<Stream<List<int>>> subscribe(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final controller = StreamController<List<int>>.broadcast();
    final characteristic = await _findCharacteristic(
      device,
      serviceUuid,
      characteristicUuid,
    );

    try {
      await characteristic.setNotifyValue(true);

      final sub = characteristic.onValueReceived.listen(
        controller.add,
        onError: controller.addError,
      );

      final key = (device, characteristicUuid);
      _subscriptionMap[key] = sub;

      controller.onCancel = () async {
        await sub.cancel();
        _subscriptionMap.remove(key);
        try {
          await characteristic.setNotifyValue(false);
        } catch (_) {}
      };

      return controller.stream;
    } catch (e) {
      await controller.close();
      throw BleWriteException('Error al suscribirse a $characteristicUuid: $e');
    }
  }

  Future<void> unsubscribe(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final key = (device, characteristicUuid);
    final sub = _subscriptionMap.remove(key);
    if (sub != null) {
      await sub.cancel();
    }

    final characteristic = await _findCharacteristic(
      device,
      serviceUuid,
      characteristicUuid,
    );
    try {
      await characteristic.setNotifyValue(false);
    } catch (e) {
      throw BleWriteException(
        'Error al cancelar suscripción a $characteristicUuid: $e',
      );
    }
  }
}
