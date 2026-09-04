import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  SocketClient({required this.serverUrl});
  final String serverUrl;

  IO.Socket? _socket;
  Completer<void>? _connectCompleter;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(
    String token, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (isConnected) return;
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      return _connectCompleter!.future.timeout(timeout);
    }

    _connectCompleter = Completer<void>();

    if (_socket == null) {
      _socket = _buildSocket(token);
    } else {
      _socket!.io.options?['auth'] = {'token': token};
    }

    _socket!.connect();

    try {
      await _connectCompleter!.future.timeout(timeout);
    } on TimeoutException {
      throw Exception('Timeout al conectar el socket.');
    }
  }

  IO.Socket _buildSocket(String token) {
    final socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) {
      print('socket conectado');
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.complete();
      }
    });

    socket.onConnectError((error) {
      print('connect_error: $error');
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.completeError(
          Exception('Error al conectar el socket: $error'),
        );
      }
    });

    socket.onError((error) {
      print('socket error: $error');
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        _connectCompleter!.completeError(Exception('Error de socket: $error'));
      }
    });

    socket.onDisconnect((_) {
      print('Socket desconectado');
    });

    return socket;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _connectCompleter = null;
  }
}
