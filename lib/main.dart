import 'package:flutter/material.dart';
import 'Screens/input_page.dart';
import 'Screens/splash_screen.dart';
import 'Screens/privacy_policy_screen.dart';
import 'Screens/privacy_policy_webview.dart';
import 'Screens/feedback_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        InputPage.id: (context) => InputPage(),
        PrivacyPolicyScreen.id: (context) => PrivacyPolicyScreen(),
        PrivacyPolicyWebView.id: (context) => PrivacyPolicyWebView(
              useLocalHtml: true,
            ),
        FeedbackPage.id: (context) => FeedbackPage(),
      },
    );
  }
}
