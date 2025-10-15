abstract class ApplicationEvent {
  const ApplicationEvent();
}

class ApplicationBeginRegisterEvent extends ApplicationEvent {
  // final String? invitationCode;
  // final String? platform; // 可选平台参数
  // final String? host;
  final Map<String, dynamic>? queryParams;

  ApplicationBeginRegisterEvent({this.queryParams});

  /// 实现hashcode和 ==
  @override
  int get hashCode => queryParams.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationBeginRegisterEvent &&
          queryParams == other.queryParams;
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
