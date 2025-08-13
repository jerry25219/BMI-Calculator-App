// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_version_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckVersionParameter _$CheckVersionParameterFromJson(
  Map<String, dynamic> json,
) => CheckVersionParameter(
  appId: json['appId'] as String,
  deviceType: json['deviceType'] as String,
  deviceOs: json['deviceOs'] as String,
  appVersion: json['appVersion'] as String,
  appBuildNumber: json['appBuildNumber'] as String,
);

Map<String, dynamic> _$CheckVersionParameterToJson(
  CheckVersionParameter instance,
) => <String, dynamic>{
  'appId': instance.appId,
  'deviceType': instance.deviceType,
  'deviceOs': instance.deviceOs,
  'appVersion': instance.appVersion,
  'appBuildNumber': instance.appBuildNumber,
};
