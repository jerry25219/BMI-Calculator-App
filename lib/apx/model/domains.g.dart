// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domains.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Domains _$DomainsFromJson(Map<String, dynamic> json) => _Domains(
  platform:
      (json['platform'] as List<dynamic>).map((e) => e as String).toList(),
  android: json['android'] as String,
  ios: json['ios'] as String,
);

Map<String, dynamic> _$DomainsToJson(_Domains instance) => <String, dynamic>{
  'platform': instance.platform,
  'android': instance.android,
  'ios': instance.ios,
};
