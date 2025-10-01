import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../utilities/crypto_utils.dart';

part 'register_data.freezed.dart';
part 'register_data.g.dart';

class RegisterData {
  String? invitationCode;
  String? deviceId;
  String? platform;
  String? host;

  RegisterData({this.invitationCode, this.deviceId, this.platform, this.host});

  Map<String, dynamic> toJson() {
    return {
      'invitationCode': invitationCode,
      'deviceId': deviceId,
      'platform': platform,
      'host': host
    };
  }

  String encrypt() {
    // First we generate json string from self
    final jsonString = json.encode(toJson());
    // Then we encrypt the json string using the public key using RSA

    return CryptoUtils().encrypt(jsonString);
  }
}
