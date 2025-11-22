import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class GoalsPage extends StatefulWidget {
  static const String id = 'goals_page';
  const GoalsPage({Key? key}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final TextEditingController _goalBmiController = TextEditingController();
  final TextEditingController _reminderDaysController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getDouble('goal_bmi');
    final days = prefs.getInt('reminder_days') ?? 0;
    setState(() {
      _goalBmiController.text = goal?.toStringAsFixed(1) ?? '';
      _reminderDaysController.text = days > 0 ? days.toString() : '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final g = double.tryParse(_goalBmiController.text.trim());
    final d = int.tryParse(_reminderDaysController.text.trim());
    if (g != null) await prefs.setDouble('goal_bmi', g);
    if (d != null && d > 0) {
      await prefs.setInt('reminder_days', d);
    } else {
      await prefs.remove('reminder_days');
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goals and reminders saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: kactiveCardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target BMI', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _goalBmiController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(hintText: 'e.g., 22.0'),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text('Recommended range: 18.5 – 23.9', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: kactiveCardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weigh-in reminder (days)', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _reminderDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'e.g., 3 (remind every 3 days)'),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text('Note: No system notifications, only in-app prompts. You can clear/disable anytime.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
    );
  }
}
