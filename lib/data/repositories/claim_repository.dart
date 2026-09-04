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

  static const String _claimResultEvent = 'claim_result';
  static const Duration _confirmationTimeout = Duration(seconds: 30);

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
      final backendMessage = e.response?.data['message'] ?? e.message;
      debugPrint('[CLAIM] Backend rechazó el claim: $backendMessage');
      throw Exception(backendMessage);
    }
  }

  Future<Map<String, dynamic>> awaitClaimConfirmation(String deviceUid) async {
    final tokenId = await _auth.getTokenId();
    if (tokenId == null || tokenId.isEmpty) {
      throw Exception('No se pudo obtener el token de autenticación.');
    }

    if (!_socketClient.isConnected) {
      await _socketClient.connect(tokenId);
    }

    final completer = Completer<Map<String, dynamic>>();

    void handler(dynamic data) {
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

    try {
      debugPrint('[CLAIM] Uniendo a room de claim para $deviceUid');
      _socketClient.emit('claim', {'uid': deviceUid});

      return await completer.future.timeout(_confirmationTimeout);
    } on TimeoutException {
      throw Exception('El servidor no confirmó el claim a tiempo.');
    } finally {
      _socketClient.off(_claimResultEvent);
    }
  }

  void disposeSocket() {
    _socketClient.disconnect();
  }
}
