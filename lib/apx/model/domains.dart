class Domains {
  final List<String> platform;
  final String? android;
  final String? ios;
  final String? harmony;

  Domains({required this.platform, this.android, this.ios,this.harmony});

  factory Domains.fromJson(Map<String, dynamic> json) {
    return Domains(
      platform: (json['platform'] as List<dynamic>).map((e) => e as String).toList(),
      android: json['android'],
      ios: json['ios'],
      harmony: json['harmony'],
    );
  }
}
