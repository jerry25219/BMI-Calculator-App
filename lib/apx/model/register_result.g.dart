// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterResult _$RegisterResultFromJson(Map<String, dynamic> json) =>
    _RegisterResult(
      domains: Domains.fromJson(json['domains'] as Map<String, dynamic>),
      succeed: json['succeed'] as bool,
    );

Map<String, dynamic> _$RegisterResultToJson(_RegisterResult instance) =>
    <String, dynamic>{'domains': instance.domains, 'succeed': instance.succeed};
