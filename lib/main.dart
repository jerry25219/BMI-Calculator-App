import 'dart:async';
import 'dart:io';

import 'package:bmi_calculator_app/apx/blocs/application/application_bloc.dart';
import 'package:bmi_calculator_app/apx/real_app/webview_app.dart';
import 'package:bmi_calculator_app/apx/services/deep_link_service.dart';
import 'package:bmi_calculator_app/apx/utilities/debug_print_output.dart';
import 'package:bmi_calculator_app/apx/utilities/my_http_over.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/input_page.dart';
import 'Screens/splash_screen.dart';
import 'Screens/privacy_policy_screen.dart';
import 'Screens/privacy_policy_webview.dart';
import 'Screens/feedback_page.dart';
import 'apx/pages/loading_page.dart';
import 'Screens/health_info_sources.dart';

final logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all);

String launcherIcon = 'ic_launcher';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // 仅支持竖屏（Flutter 层约束）
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    HttpOverrides.global = MyHttpOverrides();
    try {
      final deepLinkService = DeepLinkService();
      if (Platform.isAndroid || Platform.isIOS) {
        await deepLinkService.initialize();
      } else {
        await deepLinkService.initOhos();
      }
      logger.i('DeepLinkService initialized successfully');
    } catch (e, stackTrace) {
      logger.i('Failed to initialize DeepLinkService: $e\n$stackTrace');
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iconTemp = prefs.getString('icon') ?? 'launcher';
    launcherIcon = 'ic_$iconTemp';

    runApp(MyApp());
  }, (err, stackTrace) {
    print(err);
    print(stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Map<String, Widget Function(BuildContext)> get _routes => {
        LoadingPage.routeName: (context) => LoadingPage(),
        SplashScreen.id: (context) => SplashScreen(),
        WebViewApp.routeName: (context) => WebViewApp(),
        InputPage.id: (context) => InputPage(),
        PrivacyPolicyScreen.id: (context) => PrivacyPolicyScreen(),
        PrivacyPolicyWebView.id: (context) => PrivacyPolicyWebView(),
        FeedbackPage.id: (context) => FeedbackPage(),
        HealthInfoSourcesPage.id: (context) => const HealthInfoSourcesPage(),
      };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ApplicationBloc()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF0A0E21),
          scaffoldBackgroundColor: Color(0xFF0A0E21),
        ),
        builder: (context, child) {
          return OKToast(child: child!);
        },
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        initialRoute: LoadingPage.routeName,
        routes: _routes,
        onGenerateRoute: (RouteSettings settings) {
          final String? routeName = settings.name;

          if (routeName != null) {
            try {
              String path;
              Map<String, String> queryParams = {};
              if (routeName.startsWith('dfbmi://')) {
                final uri = Uri.parse(routeName);
                path = uri.host;
                queryParams = uri.queryParameters;
                deepLinkQueryParams = uri.queryParameters;
              } else {
                final uri = Uri.parse(routeName);
                path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
                queryParams = uri.queryParameters;
                deepLinkQueryParams = uri.queryParameters;
                if (path.isEmpty && queryParams.containsKey('code')) {
                  path = 'home';
                }
              }
              logger.i('deepLink $deepLinkQueryParams');
              if (path == 'home') {
                // final code = queryParams['code'];
                // final host = queryParams['host'];
                // final platform = queryParams['platform'];
                // final mode = queryParams['mode'];
                return MaterialPageRoute<void>(
                  settings: RouteSettings(
                    name: LoadingPage.routeName,
                    arguments: deepLinkQueryParams,
                  ),
                  // arguments: code != null
                  //     ? {'code': code, 'host': host, 'platform': platform}
                  //     : null),
                  builder: (context) => LoadingPage(),
                );
              }
            } catch (e) {}
          }
          if (_routes.containsKey(routeName)) {
            return MaterialPageRoute<void>(
                settings: settings,
                builder: (context) => _routes[routeName]!(context));
          }
          return MaterialPageRoute<void>(
              settings: settings, builder: (context) => Container());
        },
      ),
    );
  }
}
