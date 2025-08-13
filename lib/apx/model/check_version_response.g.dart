// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_version_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckVersionResponse _$CheckVersionResponseFromJson(
  Map<String, dynamic> json,
) => CheckVersionResponse(
  upgradeAble: json['upgradeAble'] as bool,
  upgradeUri: json['upgradeUri'] as String?,
  code: json['code'] as String?,
  authorization: json['authorization'] as String?,
  clientId: json['clientId'] as String?,
  contentLanguage: json['contentLanguage'] as String?,
);

Map<String, dynamic> _$CheckVersionResponseToJson(
  CheckVersionResponse instance,
) => <String, dynamic>{
  'upgradeAble': instance.upgradeAble,
  'upgradeUri': instance.upgradeUri,
  'code': instance.code,
  'authorization': instance.authorization,
  'clientId': instance.clientId,
  'contentLanguage': instance.contentLanguage,
};
