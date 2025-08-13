import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'privacy_policy_screen.dart';
import 'input_page.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => _checkPrivacyPolicy());
  }

  void _checkPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? privacyAccepted = prefs.getBool('privacy_accepted');

    if (privacyAccepted == true) {
      Navigator.pushReplacementNamed(context, InputPage.id);
    } else {
      Navigator.pushReplacementNamed(context, PrivacyPolicyScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kactiveCardColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            Icon(
              Icons.favorite,
              size: 100.0,
              color: Color(0xFFEB1555),
            ),
            SizedBox(height: 20.0),
            // 应用名称
            Text(
              'BMI Calculator',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.0),
            // 加载指示器
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEB1555)),
            ),
          ],
        ),
      ),
    );
  }
}
