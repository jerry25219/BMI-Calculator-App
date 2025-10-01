import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';

sealed class ApplicationEvent {
  const ApplicationEvent();
}

@freezed
class ApplicationBeginRegisterEvent extends ApplicationEvent with _$ApplicationBeginRegisterEvent {
  final String? invitationCode;
  final String? platform; // 可选平台参数
  final String? host;

  ApplicationBeginRegisterEvent({this.invitationCode,this.host, this.platform});
}

@freezed
class ApplicationBeginAuthenticateEvent extends ApplicationEvent with _$ApplicationBeginAuthenticateEvent {
  final String userId;
  final String password;

  ApplicationBeginAuthenticateEvent({required this.userId, required this.password});
}
