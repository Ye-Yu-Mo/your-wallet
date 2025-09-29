// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  name: json['name'] as String,
  accountType: json['account_type'] as String,
  balance: (json['balance'] as num).toDouble(),
  currency: json['currency'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'account_type': instance.accountType,
  'balance': instance.balance,
  'currency': instance.currency,
  'created_at': instance.createdAt.toIso8601String(),
};

CreateAccountRequest _$CreateAccountRequestFromJson(
  Map<String, dynamic> json,
) => CreateAccountRequest(
  name: json['name'] as String,
  accountType: json['account_type'] as String,
  balance: (json['balance'] as num).toDouble(),
  currency: json['currency'] as String,
);

Map<String, dynamic> _$CreateAccountRequestToJson(
  CreateAccountRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'account_type': instance.accountType,
  'balance': instance.balance,
  'currency': instance.currency,
};

UpdateAccountRequest _$UpdateAccountRequestFromJson(
  Map<String, dynamic> json,
) => UpdateAccountRequest(
  name: json['name'] as String?,
  accountType: json['account_type'] as String?,
  balance: (json['balance'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
);

Map<String, dynamic> _$UpdateAccountRequestToJson(
  UpdateAccountRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'account_type': instance.accountType,
  'balance': instance.balance,
  'currency': instance.currency,
};
