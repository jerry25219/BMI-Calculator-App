class Domains {
  final List<String> platform;
  final String android;
  final String ios;

  Domains({required this.platform, required this.android, required this.ios});

  factory Domains.fromJson(Map<String, dynamic> json) {
    return Domains(
      platform: json['platform'],
      android: json['android'],
      ios: json['ios'],
    );
  }
}
