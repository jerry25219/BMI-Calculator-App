import 'package:bmi_calculator_app/apx/real_app/float_button.dart';
import 'package:bmi_calculator_app/apx/utilities/webview_refresher/webview_refresher.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class RedirectPage extends StatefulWidget {
  const RedirectPage({super.key, required this.uri});
  final String uri;

  @override
  State<RedirectPage> createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  late WebViewController controller;
  ValueNotifier<int> loadProgress = ValueNotifier<int>(0);
  bool _enableRefresh = true;

  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.uri));

    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        limitsNavigationsToAppBoundDomains: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(
      params,
    );

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.enableZoom(true);
    controller.setBackgroundColor(const Color(0xFF18181D));

    // Configure WebView settings
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {},
        onProgress: (progress) {
          loadProgress.value = progress;
        },
        onWebResourceError: (error) async {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );
    controller.loadRequest(Uri.parse(widget.uri));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181D),
      resizeToAvoidBottomInset: false,
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Stack(
        children: [
          WebviewRefresher(
            onRefresh: _enableRefresh
                ? () async {
                    await controller.reload();
                  }
                : null,
            controller: controller,
            platform: TargetPlatform.iOS,
          ),
          // 进度条
          Align(
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder<int>(
              valueListenable: loadProgress,
              builder: (context, progress, child) {
                if (progress == 100) {
                  return const SizedBox.shrink();
                }
                return LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.transparent,
                  color: Colors.blue,
                );
              },
            ),
          ),
          FloatButton(onBack: () {
            Navigator.of(context).pop();
          }, onChange: (isDragging) {
            setState(() {
              _enableRefresh = !isDragging;
            });
            controller.enableZoom(!isDragging);
          }),
        ],
      ),
    );
  }
}
