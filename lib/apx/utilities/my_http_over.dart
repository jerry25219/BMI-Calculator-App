import 'dart:io';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var http = super.createHttpClient(context);
    http.findProxy = (url) {
      // print('555555->debugIp = $debugIp');
      return 'PROXY 192.168.2.167:8888';
    };
    http.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return http;
  }
}