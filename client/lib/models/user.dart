import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class CreateUserRequest {
  final String username;
  final String email;
  final String password;

  CreateUserRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String? username;
  final String? email;

  UpdateUserRequest({
    this.username,
    this.email,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}