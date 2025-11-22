import 'package:bmi_calculator_app/Screens/privacy_policy_webview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../calculator_brain.dart';
import 'goals_page.dart';
import 'nutrition_tools_page.dart';
import 'body_estimator_page.dart';
import 'health_info_sources.dart';
import 'privacy_policy_screen.dart';
import 'feedback_page.dart';

class ToolsHubPage extends StatefulWidget {
  const ToolsHubPage({Key? key}) : super(key: key);

  @override
  State<ToolsHubPage> createState() => _ToolsHubPageState();
}

class _ToolsHubPageState extends State<ToolsHubPage> {
  bool _goalsDue = false;
  int _historyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadIndicators();
  }

  Future<void> _loadIndicators() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final days = prefs.getInt('reminder_days') ?? 0;
      final history = await BMIHistoryManager.getBMIHistory();
      setState(() => _historyCount = history.length);
      if (days > 0) {
        DateTime? last;
        if (history.isNotEmpty) {
          history.sort((a, b) => b.time.compareTo(a.time));
          last = history.first.time;
        }
        final now = DateTime.now();
        final due = last == null || now.difference(last).inDays >= days;
        if (mounted) setState(() => _goalsDue = due);
      } else {
        if (mounted) setState(() => _goalsDue = false);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Standard "Settings" style: grouped sections + list tiles + chevron navigation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader(title: 'Goals & Reminders'),
            _SettingsTile(
              icon: Icons.flag,
              title: 'Goals & Reminders',
              subtitle: _goalsDue
                  ? 'Due: Please weigh in soon'
                  : 'Set target BMI and local reminder interval',
              trailing: _goalsDue
                  ? const _Badge(text: 'Due')
                  : const Icon(Icons.chevron_right, color: Colors.white70),
              onTap: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => GoalsPage()));
                _loadIndicators();
              },
            ),
            const _SectionHeader(title: 'Calculators'),
            _SettingsTile(
              icon: Icons.local_fire_department,
              title: 'Energy & Nutrition',
              subtitle: 'BMR/TDEE calculation and sample macro distribution',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NutritionToolsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.monitor_weight,
              title: 'Body Fat & WHR',
              subtitle: 'US Navy body fat estimate and waist-hip ratio',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BodyEstimatorPage()),
              ),
            ),
            const _SectionHeader(title: 'Resources & Privacy'),
            _SettingsTile(
              icon: Icons.library_books,
              title: 'Health Info Sources',
              subtitle: 'View common sources and useful links',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HealthInfoSourcesPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'View or withdraw privacy policy consent',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PrivacyPolicyWebView()),
              ),
            ),
            const _SectionHeader(title: 'Help & Feedback'),
            _SettingsTile(
              icon: Icons.feedback,
              title: 'User Feedback',
              subtitle: 'Submit issues and suggestions to help us improve',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FeedbackPage()),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'History records: $_historyCount',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle: subtitle != null
              ? Text(subtitle!, style: const TextStyle(color: Colors.white70))
              : null,
          trailing: trailing ??
              const Icon(Icons.chevron_right, color: Colors.white70),
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        const Divider(height: 1, color: Colors.white12),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
