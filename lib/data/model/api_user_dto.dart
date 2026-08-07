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
      uid: json['uid'],
      email: json['email'],
      displayName: json['display_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
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
