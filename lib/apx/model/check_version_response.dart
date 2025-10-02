
class CheckVersionResponse {
  bool upgradeAble;
  String? upgradeUri;
  String? code;
  String? authorization;
  String? clientId;
  String? contentLanguage;

  CheckVersionResponse({required this.upgradeAble, this.upgradeUri, this.code, this.authorization, this.clientId, this.contentLanguage});

  // fromJson
  factory CheckVersionResponse.fromJson(Map<String, dynamic> json) {
    return CheckVersionResponse(
      upgradeAble: json['upgradeAble'],
      upgradeUri: json['upgradeUri'],
      code: json['code'],
      authorization: json['authorization'],
      clientId: json['clientId'],
      contentLanguage: json['contentLanguage'],
    );
  }
}
