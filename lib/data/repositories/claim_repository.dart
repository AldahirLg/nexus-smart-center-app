import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';

class ClaimRepository {
  final FirebaseAuthService _auth;
  final ApiService _api;
  final SocketClient _socketClient;

  ClaimRepository({
    required FirebaseAuthService auth,
    required ApiService api,
    required SocketClient socketClient,
  }) : _auth = auth,
       _api = api,
       _socketClient = socketClient;

  static const String _claimResultEvent = 'device:claim';
  static const Duration _confirmationTimeout = Duration(seconds: 30);

  Completer<Map<String, dynamic>>? _claimCompleter;

  Future<String> requestClaimToken(String deviceUid) async {
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
      final backendMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? e.message
          : e.message;

      debugPrint('[CLAIM] Backend rechazó el claim: $backendMessage');

      throw Exception(backendMessage);
    }
  }

  /// Conecta el socket si es necesario y registra el listener
  /// antes de enviar las credenciales por BLE.
  Future<void> prepareClaimConfirmation() async {
    // Evita conservar una escucha anterior.
    cancelClaimConfirmation();

    final tokenId = await _auth.getTokenId();

    if (tokenId == null || tokenId.isEmpty) {
      throw Exception('No se pudo obtener el token de autenticación.');
    }

    if (!_socketClient.isConnected) {
      await _socketClient.connect(tokenId);
    }

    if (!_socketClient.isConnected) {
      throw Exception('No se pudo establecer la conexión con el servidor.');
    }

    final completer = Completer<Map<String, dynamic>>();
    _claimCompleter = completer;

    void handler(dynamic data) {
      debugPrint('[CLAIM][SOCKET] Evento recibido: $_claimResultEvent');
      debugPrint('[CLAIM][SOCKET] Payload: $data');

      if (completer.isCompleted) return;

      if (data is Map) {
        completer.complete(Map<String, dynamic>.from(data));
      } else {
        completer.completeError(
          Exception('Respuesta de confirmación de claim inválida.'),
        );
      }
    }

    _socketClient.on(_claimResultEvent, handler);

    debugPrint('[CLAIM][SOCKET] Listener registrado.');
    debugPrint(
      '[CLAIM][SOCKET] Socket conectado: ${_socketClient.isConnected}',
    );
  }

  /// Espera el evento device:claim previamente registrado.
  Future<Map<String, dynamic>> awaitClaimConfirmation() async {
    final completer = _claimCompleter;

    if (completer == null) {
      throw StateError(
        'Debes ejecutar prepareClaimConfirmation() antes de esperar.',
      );
    }

    try {
      return await completer.future.timeout(_confirmationTimeout);
    } on TimeoutException {
      throw Exception('El servidor no confirmó el claim a tiempo.');
    } finally {
      cancelClaimConfirmation();
    }
  }

  /// Cancela la escucha pendiente.
  void cancelClaimConfirmation() {
    _socketClient.off(_claimResultEvent);
    _claimCompleter = null;
  }

  void disposeSocket() {
    cancelClaimConfirmation();
    _socketClient.disconnect();
  }
}
