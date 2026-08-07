import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  SocketClient({required this.serverUrl});
  final String serverUrl;

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(String token) async {
    if (_socket != null) return;

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth(({'token': token}))
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('socket conectado');
    });

    _socket!.onDisconnect((_) {
      print('Socket desconectado');
    });

    _socket!.onConnectError((error) {
      print(error);
    });

    _socket!.onerror((error) {
      print(error);
    });
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
  }
}
