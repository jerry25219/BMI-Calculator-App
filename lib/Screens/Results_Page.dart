import 'package:bmi_calculator_app/Components/BottomContainer_Button.dart';
import 'package:bmi_calculator_app/Screens/input_page.dart';
import 'package:bmi_calculator_app/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Components/Reusable_Bg.dart';
import '../calculator_brain.dart';
import 'BMIHistoryPage.dart';
import 'feedback_page.dart';

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
    // 自动保存BMI结果
    _saveResult();
  }

  Future<void> _saveResult() async {
    // 将数据保存到本地
    String genderStr = widget.gender == Gender.male ? 'male' : 'female';

    // 解析BMI值
    double bmiValue = double.parse(widget.bmi);

    // 创建BMI记录
    BMIRecord record = BMIRecord(
      height: widget.height,
      weight: widget.weight,
      gender: genderStr,
      bmi: bmiValue,
      time: DateTime.now(),
    );

    // 保存记录
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
                    '18.5 - 25 kg/m2',
                    style: kBodyTextStyle,
                  ),
                  Text(
                    widget.advise,
                    textAlign: TextAlign.center,
                    style: kBodyTextStyle,
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
