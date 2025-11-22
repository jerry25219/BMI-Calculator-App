import 'package:flutter/material.dart';
import '../constants.dart';
import 'goals_page.dart';
import 'nutrition_tools_page.dart';
import 'body_estimator_page.dart';
import 'health_info_sources.dart';
import 'privacy_policy_screen.dart';

class ToolsHubPage extends StatefulWidget {
  const ToolsHubPage({Key? key}) : super(key: key);

  @override
  State<ToolsHubPage> createState() => _ToolsHubPageState();
}

class _ToolsHubPageState extends State<ToolsHubPage>
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Material(
              color: theme.bottomAppBarTheme.color ?? kactiveCardColor,
              child: TabBar(
                controller: _controller,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.flag), text: '目标'),
                  Tab(icon: Icon(Icons.local_fire_department), text: '营养'),
                  Tab(icon: Icon(Icons.monitor_weight), text: '体脂'),
                  Tab(icon: Icon(Icons.library_books), text: '资料'),
                  Tab(icon: Icon(Icons.privacy_tip), text: '隐私'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  GoalsPage(),
                  NutritionToolsPage(),
                  BodyEstimatorPage(),
                  HealthInfoSourcesPage(),
                  PrivacyPolicyScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
