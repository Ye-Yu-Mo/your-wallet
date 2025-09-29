import 'package:json_annotation/json_annotation.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String symbol;
  final String name;
  final double quantity;
  @JsonKey(name: 'avg_price')
  final double avgPrice;
  @JsonKey(name: 'asset_type')
  final String assetType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Asset({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    required this.assetType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
  Map<String, dynamic> toJson() => _$AssetToJson(this);
}

@JsonSerializable()
class CreateAssetRequest {
  final String symbol;
  final String name;
  final double quantity;
  @JsonKey(name: 'avg_price')
  final double avgPrice;
  @JsonKey(name: 'asset_type')
  final String assetType;

  CreateAssetRequest({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    required this.assetType,
  });

  factory CreateAssetRequest.fromJson(Map<String, dynamic> json) => _$CreateAssetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAssetRequestToJson(this);
}

@JsonSerializable()
class UpdateAssetRequest {
  final String? symbol;
  final String? name;
  final double? quantity;
  @JsonKey(name: 'avg_price')
  final double? avgPrice;
  @JsonKey(name: 'asset_type')
  final String? assetType;

  UpdateAssetRequest({
    this.symbol,
    this.name,
    this.quantity,
    this.avgPrice,
    this.assetType,
  });

  factory UpdateAssetRequest.fromJson(Map<String, dynamic> json) => _$UpdateAssetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAssetRequestToJson(this);
}