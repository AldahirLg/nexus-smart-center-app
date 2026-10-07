import 'package:nexus_smart_center/models/api_user_model.dart';

class ApiUserDto {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApiUserDto({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUserDto.fromJson(Map<String, dynamic> json) {
    return ApiUserDto(
      uid: json['id'] as String,
      email: json['email'] as String,
      displayName: json['name'] as String?,
      createdAt: _parseFirestoreDate(json['createdAt']),
      updatedAt: _parseFirestoreDate(json['updatedAt']),
    );
  }

  static DateTime _parseFirestoreDate(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }

    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'] as int;
      final nanoseconds = value['_nanoseconds'] as int? ?? 0;

      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    }

    throw FormatException('Formato de fecha no soportado: $value');
  }

  ApiUserModel toDomain() {
    return ApiUserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
