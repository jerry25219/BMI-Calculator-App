import 'dart:async';
import 'dart:io';

import 'package:bmi_calculator_app/apx/blocs/application/application_bloc.dart';
import 'package:bmi_calculator_app/apx/real_app/webview_app.dart';
import 'package:bmi_calculator_app/apx/services/deep_link_service.dart';
import 'package:bmi_calculator_app/apx/utilities/debug_print_output.dart';
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

final logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
    output: DebugPrintOutput(),
    level: Level.all);

String launcherIcon = 'ic_launcher';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // HttpOverrides.global = MyHttpOverrides();
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
        initialRoute: LoadingPage.routeName,
        routes: _routes,
        onGenerateRoute: (RouteSettings settings) {
          final String? routeName = settings.name;
          final Object? arguments = settings.arguments;

          if (routeName != null) {
            try {
              String path;
              Map<String, String> queryParams = {};
              if (routeName.startsWith('dragonfly://')) {
                final uri = Uri.parse(routeName);
                path = uri.host;
                queryParams = uri.queryParameters;
              } else {
                final uri = Uri.parse(routeName);
                path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
                queryParams = uri.queryParameters;
                if (path.isEmpty && queryParams.containsKey('code')) {
                  path = 'home';
                }
              }

              if (path == 'home') {
                final code = queryParams['code'];
                return MaterialPageRoute<void>(
                  settings: RouteSettings(
                      name: LoadingPage.routeName,
                      arguments: code != null ? {'code': code} : null),
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
