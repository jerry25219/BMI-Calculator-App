// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpResponse _$HttpResponseFromJson(Map<String, dynamic> json) => HttpResponse(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String?,
  detail: json['detail'] as String?,
  rq: json['rq'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$HttpResponseToJson(HttpResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'detail': instance.detail,
      'rq': instance.rq,
      'data': instance.data,
    };
