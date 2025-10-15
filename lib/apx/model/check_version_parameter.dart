class CheckVersionParameter {
  final String appId;
  final String deviceType;
  final String deviceOs;
  final String appVersion;
  final String appBuildNumber;
  final Map<String, dynamic> queryParameters;

  const CheckVersionParameter({
    required this.appId,
    required this.deviceType,
    required this.deviceOs,
    required this.appVersion,
    required this.appBuildNumber,
    required this.queryParameters,
  });

  Map<String, dynamic> toJson() {
    return {
      "appId": this.appId,
      "deviceType": this.deviceType,
      "deviceOs": this.deviceOs,
      "appVersion": this.appVersion,
      "appBuildNumber": this.appBuildNumber,
      ...this.queryParameters,
    };
  }
}
