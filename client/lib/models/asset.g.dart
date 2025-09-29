// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) => Asset(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  avgPrice: (json['avg_price'] as num).toDouble(),
  assetType: json['asset_type'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'symbol': instance.symbol,
  'name': instance.name,
  'quantity': instance.quantity,
  'avg_price': instance.avgPrice,
  'asset_type': instance.assetType,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

CreateAssetRequest _$CreateAssetRequestFromJson(Map<String, dynamic> json) =>
    CreateAssetRequest(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      assetType: json['asset_type'] as String,
    );

Map<String, dynamic> _$CreateAssetRequestToJson(CreateAssetRequest instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'quantity': instance.quantity,
      'avg_price': instance.avgPrice,
      'asset_type': instance.assetType,
    };

UpdateAssetRequest _$UpdateAssetRequestFromJson(Map<String, dynamic> json) =>
    UpdateAssetRequest(
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      avgPrice: (json['avg_price'] as num?)?.toDouble(),
      assetType: json['asset_type'] as String?,
    );

Map<String, dynamic> _$UpdateAssetRequestToJson(UpdateAssetRequest instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'quantity': instance.quantity,
      'avg_price': instance.avgPrice,
      'asset_type': instance.assetType,
    };
