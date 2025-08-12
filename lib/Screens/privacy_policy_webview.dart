import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;
import '../constants.dart';

class PrivacyPolicyWebView extends StatefulWidget {
  static const String id = 'privacy_policy_webview';
  final String? url;
  final bool useLocalHtml;

  const PrivacyPolicyWebView({
    Key? key,
    this.url,
    this.useLocalHtml = false,
  })  : assert(url != null || useLocalHtml == true),
        super(key: key);

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
    if (widget.useLocalHtml) {
      // 根据系统语言选择加载中文或英文版本
      final String assetPath = 'assets/bmi_privacy_policy.html';

      final String htmlContent = await rootBundle.loadString(assetPath);
      controller.loadHtmlString(htmlContent);
    } else if (widget.url != null) {
      controller.loadRequest(Uri.parse(widget.url!));
    }
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
