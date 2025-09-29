import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String name;
  @JsonKey(name: 'account_type')
  final String accountType;
  final double balance;
  final String currency;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] as String,
      accountType: json['account_type'] as String,
      balance: _doubleFromJson(json['balance']),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class CreateAccountRequest {
  final String name;
  @JsonKey(name: 'account_type')
  final String accountType;
  final double balance;
  final String currency;

  CreateAccountRequest({
    required this.name,
    required this.accountType,
    required this.balance,
    required this.currency,
  });

  factory CreateAccountRequest.fromJson(Map<String, dynamic> json) => _$CreateAccountRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAccountRequestToJson(this);
}

@JsonSerializable()
class UpdateAccountRequest {
  final String? name;
  @JsonKey(name: 'account_type')
  final String? accountType;
  final double? balance;
  final String? currency;

  UpdateAccountRequest({
    this.name,
    this.accountType,
    this.balance,
    this.currency,
  });

  factory UpdateAccountRequest.fromJson(Map<String, dynamic> json) => _$UpdateAccountRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAccountRequestToJson(this);
}

double _doubleFromJson(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
