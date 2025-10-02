// import 'package:flutter/foundation.dart';

import 'package:bmi_calculator_app/apx/model/domains.dart';

class RegisterResult {
  final Domains domains;
  final bool succeed;

  const RegisterResult({required this.domains, required this.succeed});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
        domains: Domains.fromJson(json['domains']), succeed: json['succeed']);
  }
}
