import 'package:flutter_blue_plus/flutter_blue_plus.dart';

sealed class BleTransportException implements Exception {
  final String message;
  const BleTransportException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class BleConnectionException extends BleTransportException {
  const BleConnectionException(super.message);
}

class BleTimeoutException extends BleTransportException {
  const BleTimeoutException(super.message);
}

class BleServiceNotFoundException extends BleTransportException {
  final Guid serviceUuid;
  BleServiceNotFoundException(this.serviceUuid)
    : super('Servicio no encontrado: $serviceUuid');
}

class BleCharacteristicNotFoundException extends BleTransportException {
  final Guid characteristicUuid;
  BleCharacteristicNotFoundException(this.characteristicUuid)
    : super('Característica no encontrada: $characteristicUuid');
}

class BleWriteException extends BleTransportException {
  const BleWriteException(super.message);
}
