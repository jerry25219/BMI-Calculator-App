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
    // 采用「设置页面」常规设计：分组 + 列表项 + 右箭头跳转
    return Scaffold(
      appBar: AppBar(
        title: const Text('工具'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader(title: '目标与提醒'),
            _SettingsTile(
              icon: Icons.flag,
              title: '目标 & 提醒',
              subtitle: _goalsDue ? '已到期：建议尽快称重' : '设置目标BMI与本地提醒天数',
              trailing: _goalsDue
                  ? const _Badge(text: '待处理')
                  : const Icon(Icons.chevron_right, color: Colors.white70),
              onTap: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => GoalsPage()));
                _loadIndicators();
              },
            ),
            const _SectionHeader(title: '计算工具'),
            _SettingsTile(
              icon: Icons.local_fire_department,
              title: '能量与营养',
              subtitle: 'BMR/TDEE 计算与示例宏量营养分配',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NutritionToolsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.monitor_weight,
              title: '体脂与腰臀比',
              subtitle: '海军体脂率公式与腰臀比估算',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BodyEstimatorPage()),
              ),
            ),
            const _SectionHeader(title: '资料与隐私'),
            _SettingsTile(
              icon: Icons.library_books,
              title: '健康资料来源',
              subtitle: '查看常用资料来源与链接',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HealthInfoSourcesPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip,
              title: '隐私政策',
              subtitle: '查看与撤回隐私政策同意',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PrivacyPolicyWebView()),
              ),
            ),
            const _SectionHeader(title: '帮助与反馈'),
            _SettingsTile(
              icon: Icons.feedback,
              title: '用户反馈',
              subtitle: '提交问题与建议，帮助我们改进',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FeedbackPage()),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '历史记录：$_historyCount 条',
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
