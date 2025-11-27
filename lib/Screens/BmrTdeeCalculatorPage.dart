import 'package:flutter/material.dart';
import '../constants.dart';
import '../calculator_brain.dart';

class BmrTdeeCalculatorPage extends StatefulWidget {
  static const String routeName = '/bmr_tdee';

  const BmrTdeeCalculatorPage({Key? key}) : super(key: key);

  @override
  State<BmrTdeeCalculatorPage> createState() => _BmrTdeeCalculatorPageState();
}

class _BmrTdeeCalculatorPageState extends State<BmrTdeeCalculatorPage> {
  String _gender = 'male';
  int _age = 25;
  int _height = 170;
  int _weight = 65;
  String _activity = 'sedentary';

  double? _bmr;
  double? _tdee;

  @override
  void initState() {
    super.initState();
    _prefillFromLatest();
  }

  Future<void> _prefillFromLatest() async {
    final history = await BMIHistoryManager.getBMIHistory();
    if (history.isNotEmpty) {
      history.sort((a, b) => b.time.compareTo(a.time));
      final r = history.first;
      setState(() {
        _gender = r.gender;
        _height = r.height;
        _weight = r.weight;
        _activity = r.activity ?? 'sedentary';
      });
    }
  }

  void _recalculate() {
    final bmr = calculateBmr(
      gender: _gender,
      age: _age,
      height: _height,
      weight: _weight,
    );
    final tdee = calculateTdee(bmr: bmr, activity: _activity);
    setState(() {
      _bmr = bmr;
      _tdee = tdee;
    });
  }

  Future<void> _saveRecord() async {
    if (_bmr == null || _tdee == null) {
      _recalculate();
    }
    final rec = BmrTdeeRecord(
      gender: _gender,
      age: _age,
      height: _height,
      weight: _weight,
      activity: _activity,
      bmr: _bmr ?? 0,
      tdee: _tdee ?? 0,
      time: DateTime.now(),
    );
    await BmrTdeeHistoryManager.save(rec);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved BMR/TDEE record')),
    );
  }

  Widget _buildNumberRow(String label, int value, void Function(int) onChange,
      {int min = 0, int max = 300}) {
    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    onChanged: (d) => onChange(d.round()),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$value',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMR & TDEE'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _saveRecord, icon: const Icon(Icons.save))
        ],
      ),
      body: ListView(
        children: [
          Card(
            color: kactiveCardColor,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Information',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _gender,
                        dropdownColor: const Color(0xFF4C4F5E),
                        items: const [
                          DropdownMenuItem(
                              value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'female', child: Text('Female')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'male'),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activity,
                        dropdownColor: const Color(0xFF4C4F5E),
                        items: const [
                          DropdownMenuItem(
                              value: 'sedentary', child: Text('Sedentary')),
                          DropdownMenuItem(
                              value: 'light', child: Text('Lightly Active')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'moderate', child: Text('Very Active')),
                          DropdownMenuItem(
                              value: 'vigorous', child: Text('Extra Active')),
                        ],
                        onChanged: (v) => setState(() => _activity = v ?? 'sedentary'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          _buildNumberRow('Age', _age, (v) => setState(() => _age = v),
              min: 10, max: 90),
          _buildNumberRow('Height (cm)', _height,
              (v) => setState(() => _height = v),
              min: 120, max: 220),
          _buildNumberRow('Weight (kg)', _weight,
              (v) => setState(() => _weight = v),
              min: 30, max: 200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _recalculate,
              icon: const Icon(Icons.calculate),
              label: const Text('CALCULATE'),
            ),
          ),
          const SizedBox(height: 8),
          if (_bmr != null && _tdee != null)
            Card(
              color: kactiveCardColor,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Results',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 12, runSpacing: 8, children: [
                      _kv('BMR', '${_bmr!.toStringAsFixed(0)} kcal/day'),
                      _kv('TDEE', '${_tdee!.toStringAsFixed(0)} kcal/day'),
                      _kv('Maintain', '${_tdee!.toStringAsFixed(0)} kcal/day'),
                      _kv('Cut (−10%)',
                          '${(_tdee! * 0.9).toStringAsFixed(0)} kcal/day'),
                      _kv('Bulk (+10%)',
                          '${(_tdee! * 1.1).toStringAsFixed(0)} kcal/day'),
                    ]),
                    const SizedBox(height: 12),
                    const Text(
                      'Estimation only. Adjust based on progress and well-being.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            color: kactiveCardColor,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Disclaimer: This calculator provides estimations for general guidance and does not replace professional medical or nutrition advice.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
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
}
