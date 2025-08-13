import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyWebView extends StatefulWidget {
  static const String id = 'privacy_policy_webview';

  const PrivacyPolicyWebView({
    Key? key,
  }) : super(key: key);

  @override
  _PrivacyPolicyWebViewState createState() => _PrivacyPolicyWebViewState();
}

class _PrivacyPolicyWebViewState extends State<PrivacyPolicyWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      );

    _loadContent();
  }

  Future<void> _loadContent() async {
    controller.loadRequest(Uri.parse('https://priv.cagayan365.store/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy Details'),
        backgroundColor: Color(0xFF0A0E21),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEB1555)),
              ),
            ),
        ],
      ),
    );
  }
}
