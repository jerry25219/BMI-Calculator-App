import 'package:bmi_calculator_app/Components/BottomContainer_Button.dart';
import 'package:bmi_calculator_app/Screens/BMITrendPage.dart';
import 'package:bmi_calculator_app/Screens/input_page.dart';
import 'package:bmi_calculator_app/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Components/Reusable_Bg.dart';
import '../calculator_brain.dart';
import 'BMIHistoryPage.dart';
import 'feedback_page.dart';
import 'health_info_sources.dart';

class ResultPage extends StatefulWidget {
  final String resultText;
  final String bmi;
  final String advise;
  final Color textColor;
  final Gender gender;
  final int height;
  final int weight;
  final String activity;

  ResultPage({
    required this.textColor,
    required this.resultText,
    required this.bmi,
    required this.advise,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activity,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    // Automatically save BMI result
    _saveResult();
  }

  Future<void> _saveResult() async {
    // Save data locally
    String genderStr = widget.gender == Gender.male ? 'male' : 'female';

    // Parse BMI value
    double bmiValue = double.parse(widget.bmi);

    // Create BMI record
    BMIRecord record = BMIRecord(
      height: widget.height,
      weight: widget.weight,
      gender: genderStr,
      bmi: bmiValue,
      time: DateTime.now(),
      activity: widget.activity,
    );

    // Save record
    await BMIHistoryManager.saveBMIRecord(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('BMI CALCULATOR'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.feedback),
            onPressed: () {
              Navigator.pushNamed(context, FeedbackPage.id);
            },
            tooltip: 'Feedback',
          ),
        ],
      ),
      bottomNavigationBar: BottomContainer(
        text: 'RE-CALCULATE',
        onTap: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.bottomCenter,
              child: Text(
                'Your Result',
                style: ktitleTextStyle,
              ),
            ),
            ReusableBg(
              colour: kactiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.resultText,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 27.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.bmi,
                    style: kBMITextStyle,
                  ),
                  Text(
                    'China adult BMI categories (reference)',
                    style: klabelTextStyle,
                  ),
                  Column(
                    children: const [
                      Text('< 18.5: Underweight', style: kBodyTextStyle),
                      SizedBox(height: 4),
                      Text('18.5 – 23.9: Normal', style: kBodyTextStyle),
                      SizedBox(height: 4),
                      Text('24.0 – 27.9: Overweight', style: kBodyTextStyle),
                      SizedBox(height: 4),
                      Text('≥ 28: Obese', style: kBodyTextStyle),
                    ],
                  ),
                  Text(
                    widget.advise,
                    textAlign: TextAlign.center,
                    style: kBodyTextStyle,
                  ),
                  Text(
                    'Activity level: ${_activityLabel(widget.activity)}',
                    style:
                        const TextStyle(fontSize: 12.0, color: Colors.white70),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Important note: This app provides general health information only and does not constitute medical advice. BMI is not suitable for children, pregnant women, or professional athletes. Please consult a doctor for personalized advice.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 12.0, color: Colors.white70),
                        ),
                        SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, HealthInfoSourcesPage.id);
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Information sources: ',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.white70),
                                ),
                                TextSpan(
                                  text: 'WHO & CDC (click to view)',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFFEB1555),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BMIHistoryPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xFF4C4F5E),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'HISTORY',
                                  style: kBodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BMITrendPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xFF4C4F5E),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.show_chart,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'TREND',
                                  style: kBodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _activityLabel(String activity) {
  switch (activity) {
    case 'light':
      return 'Lightly active';
    case 'active':
      return 'Active';
    default:
      return 'Sedentary';
  }
}
