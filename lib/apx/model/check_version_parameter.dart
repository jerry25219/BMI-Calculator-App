
class CheckVersionParameter {
  final String appId;
  final String deviceType;
  final String deviceOs;
  final String appVersion;
  final String appBuildNumber;
  final String platform;
  final String host;

  const CheckVersionParameter(
      {required this.appId,
      required this.deviceType,
      required this.deviceOs,
      required this.appVersion,
      required this.appBuildNumber,
      required this.platform,
      required this.host,
      });

  factory CheckVersionParameter.fromJson(Map<String, dynamic> json) {
    return CheckVersionParameter(
      appId: json["appId"],
      deviceType: json["deviceType"],
      deviceOs: json["deviceOs"],
      appVersion: json["appVersion"],
      appBuildNumber: json["appBuildNumber"],
      platform: json["platform"],
      host: json["host"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "appId": this.appId,
      "deviceType": this.deviceType,
      "deviceOs": this.deviceOs,
      "appVersion": this.appVersion,
      "appBuildNumber": this.appBuildNumber,
      "platform": this.platform,
      "host": this.host,
    };
  }
}
