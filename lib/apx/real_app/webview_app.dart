import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:bmi_calculator_app/apx/real_app/redirect_page.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../main.dart';
import '../blocs/application/application_bloc.dart';
import '../blocs/application/state.dart';
import '../constants.dart';
import '../services/deep_link_service.dart';
import '../utilities/my_will_pop_scope.dart';
import '../utilities/webview_refresher/webview_refresher.dart';

class WebViewApp extends StatefulWidget {
  static const String routeName = '/real_app/home';

  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> with WidgetsBindingObserver {
  late WebViewController controller;
  Completer<void>? _completer;

  bool _isExitWarningActive = false;
  Timer? _exitTimer;
  bool _hasError = false;
  StreamSubscription<List<ConnectivityResult>>? _streamSubscription;
  ValueNotifier<int> loadProgress = ValueNotifier<int>(0);
  bool _enableRefresh = true;

  // ignore: strict_raw_type
  Future onRefresh() async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);
    if (isOffline) {
      showToast(
        'No internet connection. Check your network.',
        duration: const Duration(seconds: 2),
        position: ToastPosition.bottom,
      );
    } else {
      _completer = Completer<void>();
      final currentUrl = await controller.currentUrl();
      if (currentUrl == null) {
        await forward();
      } else {
        await controller.reload();
      }
      await _completer!.future;
    }
  }

  Future<void> forward() async {
    if (!mounted) return;
    final ApplicationReadyState state =
        context.read<ApplicationBloc>().state as ApplicationReadyState;
    await controller.loadRequest(
      Uri.parse('https://${state.domains?.first ?? 'www.system-screen.com'}/'),
    );
  }

  void finishRefresh() {
    if (_completer == null) return;
    if (!_completer!.isCompleted) {
      _completer?.complete();
    }
  }

  int retryCount = 0;

  /// 正在重定向
  bool isRedirecting = false;

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addObserver(this);
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      String? userAgent = await controller.getUserAgent();
      if (kDebugMode) {
        print('Current User Agent: $userAgent');
      }
      if (userAgent == null || userAgent.isEmpty) {
        userAgent = 'match-learn';
      } else {
        userAgent = '$userAgent match-learn';
      }
      controller.setUserAgent(userAgent);
      forward();
      changeAppLogo();
    });
    // controller.setUserAgent('match-learn');

    // Enable WebView features for proper image loading
    controller.enableZoom(false);
    controller.setBackgroundColor(const Color(0xFF18181D));

    // Configure WebView settings
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          if (_hasError) {
            _hasError = false;
          }
          finishRefresh();
          retryCount = 0;
        },
        onProgress: (progress) {
          loadProgress.value = progress;
          if (progress == 100) {
            finishRefresh();
          }
          if (!_enableRefresh) {
            _enableRefresh = true;
            setState(() {});
          }
        },
        onWebResourceError: (error) async {
          finishRefresh();
          final connectivity = await Connectivity().checkConnectivity();
          final isOffline = connectivity.contains(ConnectivityResult.none);
          if ((error.isForMainFrame ?? false)) {
            if (isOffline) {
              setState(() {
                _hasError = true;
              });
            } else {
              /// 尝试重新加载 3次后还是错误就 _hasError = true;
              retryCount++;
              if (retryCount > 3) {
                setState(() {
                  _hasError = true;
                });
              } else {
                onRefresh();
              }
            }
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

    controller.addJavaScriptChannel(
      'APP_BRIDGE',
      onMessageReceived: (JavaScriptMessage msg) async {
        final Map<String, dynamic> payload =
            jsonDecode(msg.message) as Map<String, dynamic>;
        final type = payload['type'];
        final data = payload['data'];
        print('[APP_BRIDGE] $type $data');
        if (type == 'redirectUrl') {
          String uri = data as String;
          if (isRedirecting) return;
          isRedirecting = true;
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return RedirectPage(uri: uri);
          }));
          isRedirecting = false;
        }
        if (type == 'popup') {
          bool disableRefresh = data as bool;
          if (_enableRefresh != !disableRefresh) {
            setState(() {
              _enableRefresh = !disableRefresh;
            });
          }
        }
      },
    );

    /// 监听网络连接状态变化
    _streamSubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (!result.contains(ConnectivityResult.none)) {
        setState(() {
          _hasError = false;
        });
        controller.reload();
      } else {
        bool isOnline = await isReallyConnected();
        if (!isOnline) {
          setState(() {
            _hasError = true;
          });
        }
      }
    });
  }

  Future<void> changeAppLogo() async {
    String icon = '';
    if ((inviteCode?.startsWith('prod') ?? false)) {
      icon = 'prod';
    } else if (inviteCode?.startsWith('pre') ?? false) {
      icon = 'pre';
    } else if (inviteCode?.startsWith('test') ?? false) {
      icon = 'test';
    } else {
      icon = 'prod';
    }

    if (icon.isEmpty) {
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('icon', icon);

      if (await FlutterDynamicIconPlus.supportsAlternateIcons) {
        String? preIcon = await FlutterDynamicIconPlus.alternateIconName;
        String targetIcon = Platform.isIOS ? icon : '${Constants.appId}.$icon';
        if (preIcon == targetIcon) {
          return;
        }
        logger.i('Changing app icon to: pre $preIcon targeIcon $targetIcon');
        await FlutterDynamicIconPlus.setAlternateIconName(
          iconName: targetIcon,
          isSilent: true,
          // blacklistBrands: ['Redmi'],
          // blacklistManufactures: ['Xiaomi'],
          // blacklistModels: ['Redmi 200A'],
        );
        print("App icon change successful");
        return;
      }
    } on PlatformException catch (e) {
      print("App icon change failed $e");
    } catch (e) {
      print("Error changing app icon: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasError) {
      controller.reload();
    }
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> pop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
    } else {
      if (Platform.isIOS) return false;

      if (_isExitWarningActive) {
        // User pressed back twice within the time window, exit the app
        _exitTimer?.cancel();
        SystemNavigator.pop();
      } else {
        // First back press, show warning and start timer
        _isExitWarningActive = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('再按一次返回键退出应用'),
            duration: Duration(seconds: 1),
          ),
        );

        _exitTimer = Timer(const Duration(milliseconds: 1500), () {
          _isExitWarningActive = false;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MyWillPopScope(
      onWillPop: () async {
        return await pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF18181D),
        resizeToAvoidBottomInset: false,
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: _hasError
          ? _networkError()
          : Stack(
              children: [
                WebviewRefresher(
                  onRefresh: _enableRefresh ? onRefresh : null,
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
              ],
            ),
    );
  }

  Widget _networkError() {
    /// 日夜间模式判断
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/network_error.png',
            width: 120,
          ),
          const SizedBox(height: 20),
          const Text(
            'Network Error',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              onRefresh();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: const Text(
                'Tap to Retry',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> isReallyConnected() async {
  try {
    final result = await http
        .get(Uri.parse(Constants.webAPIAddress))
        .timeout(const Duration(seconds: 5));
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}
