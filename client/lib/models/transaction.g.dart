// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: (json['id'] as num).toInt(),
  accountId: (json['account_id'] as num).toInt(),
  transactionType: json['transaction_type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  category: json['category'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'transaction_type': instance.transactionType,
      'amount': instance.amount,
      'description': instance.description,
      'category': instance.category,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreateTransactionRequest _$CreateTransactionRequestFromJson(
  Map<String, dynamic> json,
) => CreateTransactionRequest(
  accountId: (json['account_id'] as num).toInt(),
  transactionType: json['transaction_type'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  category: json['category'] as String?,
);

Map<String, dynamic> _$CreateTransactionRequestToJson(
  CreateTransactionRequest instance,
) => <String, dynamic>{
  'account_id': instance.accountId,
  'transaction_type': instance.transactionType,
  'amount': instance.amount,
  'description': instance.description,
  'category': instance.category,
};

UpdateTransactionRequest _$UpdateTransactionRequestFromJson(
  Map<String, dynamic> json,
) => UpdateTransactionRequest(
  transactionType: json['transaction_type'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  description: json['description'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$UpdateTransactionRequestToJson(
  UpdateTransactionRequest instance,
) => <String, dynamic>{
  'transaction_type': instance.transactionType,
  'amount': instance.amount,
  'description': instance.description,
  'category': instance.category,
};
