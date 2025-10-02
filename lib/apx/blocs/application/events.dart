abstract class ApplicationEvent {
  const ApplicationEvent();
}

class ApplicationBeginRegisterEvent extends ApplicationEvent {
  final String? invitationCode;
  final String? platform; // 可选平台参数
  final String? host;

  ApplicationBeginRegisterEvent(
      {this.invitationCode, this.host, this.platform});

  /// 实现hashcode和 ==
  @override
  int get hashCode =>
      invitationCode.hashCode ^ platform.hashCode ^ host.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationBeginRegisterEvent &&
          invitationCode == other.invitationCode &&
          platform == other.platform &&
          host == other.host;
}

class ApplicationBeginAuthenticateEvent extends ApplicationEvent {
  final String userId;
  final String password;

  ApplicationBeginAuthenticateEvent(
      {required this.userId, required this.password});

  /// 实现hashcode和 ==
  @override
  int get hashCode => userId.hashCode ^ password.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationBeginAuthenticateEvent &&
          userId == other.userId &&
          password == other.password;
}
