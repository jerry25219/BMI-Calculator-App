import 'package:bmi_calculator_app/Screens/home_tab_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'input_page.dart';
import 'privacy_policy_webview.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String id = 'privacy_policy_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kactiveCardColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF1D1E33),
                          borderRadius: BorderRadius.circular(10.0),
                          border:
                              Border.all(color: Color(0xFFEB1555), width: 2.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy Policy Summary',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '• This app does not collect any personal information\n'
                              '• All data is stored locally on your device only\n'
                              '• No data is uploaded or shared\n'
                              '• No special permissions required\n'
                              '• No ads or third-party trackers',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, PrivacyPolicyWebView.id);
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Click ',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'view details',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFFEB1555),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' to see the full privacy policy',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1D1E33),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'By agreeing to this privacy policy, you understand and accept how we handle your data. If you disagree, please tap "Disagree" to exit the app.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onPressed: () {
                          // 不同意，退出应用
                          SystemNavigator.pop();
                        },
                        child: Text(
                          'Disagree',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFEB1555),
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onPressed: () async {
                          // 同意，保存状态并进入主页
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('privacy_accepted', true);
                          Navigator.pushReplacementNamed(
                              context, HomeTabContainerPage.id);
                        },
                        child: Text(
                          'Agree',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
