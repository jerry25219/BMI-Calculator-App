import 'package:bmi_calculator_app/Screens/privacy_policy_webview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Components/Icon_Content.dart';
import '../Components/Reusable_Bg.dart';
import '../Components/RoundIcon_Button.dart';
import '../constants.dart';
import 'Results_Page.dart';
import 'BMIHistoryPage.dart';
import 'goals_page.dart';
import 'nutrition_tools_page.dart';
import 'body_estimator_page.dart';
import '../Components/BottomContainer_Button.dart';
import '../calculator_brain.dart';
import 'feedback_page.dart';
import 'health_info_sources.dart';

// ignore: must_be_immutable
class InputPage extends StatefulWidget {
  static const String id = 'input_page';

  @override
  _InputPageState createState() => _InputPageState();
}

//ENUMERATION : The action of establishing number of something , implicit way
enum Gender {
  male,
  female,
}

class _InputPageState extends State<InputPage> {
  //by default male will be selected

  late Gender selectedGender = Gender.male;
  int height = 180;
  int weight = 50;
  int age = 20;
  // 活动水平：久坐、轻度活动、活跃
  String activity = 'sedentary';
  String? _reminderMessage;
  bool _showReminder = false;
  String? _previewBmi;
  String? _previewText;
  Color? _previewColor;

  // 统一计算入口：用于右上角按钮触发导航
  void _performCalculateAndNavigate() {
    final String gender = selectedGender == Gender.male ? 'male' : 'female';
    final Calculate calc =
        Calculate(height: height, weight: weight, gender: gender);
    _updatePreview();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          bmi: calc.result(),
          resultText: calc.getText(),
          advise: calc.getAdvise(),
          textColor: calc.getTextColor(),
          gender: selectedGender,
          height: height,
          weight: weight,
          activity: activity,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkReminderDue();
    _updatePreview();
  }

  Future<void> _checkReminderDue() async {
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getInt('reminder_days') ?? 0;
    if (days <= 0) return;
    final history = await BMIHistoryManager.getBMIHistory();
    DateTime? last;
    if (history.isNotEmpty) {
      history.sort((a, b) => b.time.compareTo(a.time));
      last = history.first.time;
    }
    final now = DateTime.now();
    final due = last == null || now.difference(last).inDays >= days;
    if (due) {
      setState(() {
        _reminderMessage = 'Time to weigh in (reminder every ${days} days)';
        _showReminder = true;
      });
    }
  }

  void _updatePreview() {
    final gender = selectedGender == Gender.male ? 'male' : 'female';
    final calc = Calculate(height: height, weight: weight, gender: gender);
    final bmi = calc.result();
    setState(() {
      _previewBmi = bmi;
      _previewText = calc.getText();
      _previewColor = calc.getTextColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI CALCULATOR'),
        centerTitle: true,
        actions: [
          // 仅保留右上角“计算”按钮
          TextButton.icon(
            onPressed: _performCalculateAndNavigate,
            icon: const Icon(Icons.calculate, color: Colors.white),
            label:
                const Text('CALCULATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showReminder && _reminderMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  color: const Color(0xFF4C4F5E),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active,
                        color: Colors.white),
                    title: Text(_reminderMessage!,
                        style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => setState(() => _showReminder = false),
                    ),
                  ),
                ),
              ),
            Card(
              color: kactiveCardColor,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GENDER', style: klabelTextStyle),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [Icon(FontAwesomeIcons.mars, size: 14), SizedBox(width: 6), Text('Male')],
                          ),
                          selected: selectedGender == Gender.male,
                          onSelected: (_) {
                            setState(() {
                              selectedGender = Gender.male;
                            });
                            _updatePreview();
                          },
                          selectedColor: kbottomContainerColor,
                        ),
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [Icon(FontAwesomeIcons.venus, size: 14), SizedBox(width: 6), Text('Female')],
                          ),
                          selected: selectedGender == Gender.female,
                          onSelected: (_) {
                            setState(() {
                              selectedGender = Gender.female;
                            });
                            _updatePreview();
                          },
                          selectedColor: kbottomContainerColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_previewBmi != null)
              Card(
                color: kactiveCardColor,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Preview', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_previewText ?? '',
                              style: TextStyle(color: _previewColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_previewBmi ?? '', style: kBMITextStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ReusableBg(
              colour: kactiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HEIGHT',
                    style: klabelTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        height.toString(),
                        style: kDigitTextStyle,
                      ),
                      Text(
                        'cm',
                        style: klabelTextStyle,
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: ksliderInactiveColor,
                      thumbColor: Color(0xFFEB1555),
                      overlayColor: Color(0x29EB1555),
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 15.0),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 35.0),
                    ),
                    child: Slider(
                      value: height.toDouble(),
                      min: 120,
                      max: 220,
                      onChanged: (double newValue) {
                        setState(() {
                          height = newValue.round();
                        });
                        _updatePreview();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 活动水平选择
            ReusableBg(
              colour: kactiveCardColor,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ACTIVITY LEVEL', style: klabelTextStyle),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Sedentary'),
                        selected: activity == 'sedentary',
                        onSelected: (_) =>
                            setState(() => activity = 'sedentary'),
                      ),
                      ChoiceChip(
                        label: const Text('Lightly Active'),
                        selected: activity == 'light',
                        onSelected: (_) => setState(() => activity = 'light'),
                      ),
                      ChoiceChip(
                        label: const Text('Active'),
                        selected: activity == 'active',
                        onSelected: (_) => setState(() => activity = 'active'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ReusableBg(
                    colour: kactiveCardColor,
                    cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'WEIGHT',
                          style: klabelTextStyle,
                        ),
                        Text(
                          weight.toString(),
                          style: kDigitTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundIconButton(
                              icon: FontAwesomeIcons.minus,
                              onPressed: () {
                                setState(() {
                                  weight--;
                                });
                                _updatePreview();
                              },
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            RoundIconButton(
                              icon: FontAwesomeIcons.plus,
                              onPressed: () {
                                setState(() {
                                  weight++;
                                });
                                _updatePreview();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableBg(
                    colour: kactiveCardColor,
                    cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AGE',
                          style: klabelTextStyle,
                        ),
                        Text(
                          age.toString(),
                          style: kDigitTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RoundIconButton(
                              icon: FontAwesomeIcons.minus,
                              onPressed: () {
                                setState(() {
                                  age--;
                                });
                              },
                            ),
                            SizedBox(width: 15.0),
                            RoundIconButton(
                              icon: FontAwesomeIcons.plus,
                              onPressed: () {
                                setState(() {
                                  age++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ElevatedButton.icon(
                onPressed: _performCalculateAndNavigate,
                icon: const Icon(Icons.calculate),
                label: const Text('CALCULATE'),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
