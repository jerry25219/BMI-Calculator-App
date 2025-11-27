import 'package:flutter/material.dart';
import '../calculator_brain.dart';
import '../constants.dart';

class HealthAdvicePage extends StatefulWidget {
  static const String routeName = '/health_advice';

  const HealthAdvicePage({Key? key}) : super(key: key);

  @override
  State<HealthAdvicePage> createState() => _HealthAdvicePageState();
}

class _HealthAdvicePageState extends State<HealthAdvicePage> {
  BMIRecord? _latest;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    setState(() => _loading = true);
    final list = await BMIHistoryManager.getBMIHistory();
    list.sort((a, b) => b.time.compareTo(a.time));
    setState(() {
      _latest = list.isNotEmpty ? list.first : null;
      _loading = false;
    });
  }

  String _activityLabel(String? activity) {
    switch (activity) {
      case 'light':
        return 'Lightly active';
      case 'active':
        return 'Active';
      default:
        return 'Sedentary';
    }
  }

  String _bmiCategory(double bmi) {
    if (bmi >= 28.0) return 'OBESE';
    if (bmi >= 24.0) return 'OVERWEIGHT';
    if (bmi >= 18.5) return 'NORMAL';
    return 'UNDERWEIGHT';
  }

  List<Widget> _buildAdvice(BMIRecord r) {
    final items = <Widget>[];
    final cat = _bmiCategory(r.bmi);

    Widget section(String title, List<String> lines) => Card(
          color: kactiveCardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...lines.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(t, style: kBodyTextStyle),
                    )),
              ],
            ),
          ),
        );

    items.add(Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your latest data',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 8, children: [
              _kv('Gender', r.gender),
              _kv('Age', '-'),
              _kv('Height', '${r.height} cm'),
              _kv('Weight', '${r.weight} kg'),
              _kv('BMI', r.bmi.toStringAsFixed(1)),
              _kv('Activity', _activityLabel(r.activity)),
            ]),
          ],
        ),
      ),
    ));

    switch (cat) {
      case 'OBESE':
        items.add(section('Advice (OBESE)', [
          'Gradually reduce energy intake; prioritize simple cooking and avoid fried/high-sugar foods.',
          'Aim for at least 150–300 minutes of moderate aerobic activity per week plus strength training 2–3 times.',
          'Target loss no more than 0.5 kg per week; monitor sleep and stress.',
        ]));
        break;
      case 'OVERWEIGHT':
        items.add(section('Advice (OVERWEIGHT)', [
          'Control portion size; emphasize vegetables, whole grains, and lean protein.',
          'Aerobic exercise ≥150 minutes/week; add progressive resistance training.',
          'Reduce sugary drinks/snacks; hydrate adequately.',
        ]));
        break;
      case 'NORMAL':
        items.add(section('Advice (NORMAL)', [
          'Maintain balanced diet and regular training; keep daily activity high.',
          'Prefer whole foods; limit ultra-processed items.',
          'Schedule periodic check-ins to keep habits consistent.',
        ]));
        break;
      case 'UNDERWEIGHT':
        items.add(section('Advice (UNDERWEIGHT)', [
          'Increase energy intake with nutrient-dense foods (nuts, dairy, quality protein).',
          'Focus on strength training; ensure adequate recovery and sleep.',
          'If BMI remains low, consult a doctor for personalized guidance.',
        ]));
        break;
    }

    items.add(section('Weekly Action Checklist', [
      'Plan meals ahead; include protein in every meal.',
      'Exercise 3–5 times/week; track duration and intensity.',
      'Weigh once per week around the same time.',
    ]));

    items.add(Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Disclaimer: This content is for general health information only and does not constitute medical advice. Please consult healthcare professionals for personalized recommendations.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    ));

    return items;
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(v,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Advice'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_latest == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No history data yet. Please calculate BMI first.',
                        style: TextStyle(color: Colors.white70)),
                  ),
                )
              : ListView(children: _buildAdvice(_latest!))),
    );
  }
}
