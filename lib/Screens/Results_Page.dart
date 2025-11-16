import 'package:bmi_calculator_app/Components/BottomContainer_Button.dart';
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

  ResultPage({
    required this.textColor,
    required this.resultText,
    required this.bmi,
    required this.advise,
    required this.gender,
    required this.height,
    required this.weight,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.bottomCenter,
              child: Text(
                'Your Result',
                style: ktitleTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ReusableBg(
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
                    'Normal BMI range:',
                    style: klabelTextStyle,
                  ),
                  Text(
                    '18.5 - 24.9 kg/m²',
                    style: kBodyTextStyle,
                  ),
                  Text(
                    widget.advise,
                    textAlign: TextAlign.center,
                    style: kBodyTextStyle,
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
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BMIHistoryPage(),
                        ),
                      );
                    },
                    constraints: BoxConstraints.tightFor(
                      width: 200.0,
                      height: 56.0,
                    ),
                    fillColor: Color(0xFF4C4F5E),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'VIEW HISTORY',
                          style: kBodyTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomContainer(
            text: 'RE-CALCULATE',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
