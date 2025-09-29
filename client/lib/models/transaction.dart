import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final int id;
  @JsonKey(name: 'account_id')
  final int accountId;
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  final double amount;
  final String description;
  final String? category;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.accountId,
    required this.transactionType,
    required this.amount,
    required this.description,
    this.category,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class CreateTransactionRequest {
  @JsonKey(name: 'account_id')
  final int accountId;
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  final double amount;
  final String description;
  final String? category;

  CreateTransactionRequest({
    required this.accountId,
    required this.transactionType,
    required this.amount,
    required this.description,
    this.category,
  });

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) => _$CreateTransactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTransactionRequestToJson(this);
}

@JsonSerializable()
class UpdateTransactionRequest {
  @JsonKey(name: 'transaction_type')
  final String? transactionType;
  final double? amount;
  final String? description;
  final String? category;

  UpdateTransactionRequest({
    this.transactionType,
    this.amount,
    this.description,
    this.category,
  });

  factory UpdateTransactionRequest.fromJson(Map<String, dynamic> json) => _$UpdateTransactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateTransactionRequestToJson(this);
}