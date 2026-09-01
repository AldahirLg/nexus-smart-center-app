import 'dart:convert';
import 'dart:typed_data';

class BleMessageParser {
  final List<int> _buffer = [];

  List<String> add(Uint8List bytes) {
    _buffer.addAll(bytes);

    final messages = <String>[];

    while (true) {
      final newlineIndex = _buffer.indexOf(0x0A);

      if (newlineIndex == -1) {
        break;
      }

      final messageBytes = _buffer.sublist(0, newlineIndex);

      _buffer.removeRange(0, newlineIndex + 1);

      if (messageBytes.isEmpty) {
        continue;
      }

      final message = utf8.decode(messageBytes);

      if (message.trim().isNotEmpty) {
        messages.add(message);
      }
    }

    return messages;
  }

  void clear() {
    _buffer.clear();
  }
}
