import 'package:bmi_calculator_app/Screens/tools_hub_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../calculator_brain.dart';

import 'BMIHistoryPage.dart';
import 'BMITrendPage.dart';
import 'input_page.dart';

class GroupTabConfig {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function() builder;
  final Future<int> Function()? badgeCounter;

  GroupTabConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
    this.badgeCounter,
  });
}

class HomeTabContainerPage extends StatefulWidget {
  static const String id = 'home_tab_container_page';
  final List<String>? initialGroups;
  final bool allowSwipe; // 若设置为 false，将禁用左右滑动手势

  const HomeTabContainerPage(
      {Key? key, this.initialGroups, this.allowSwipe = false})
      : super(key: key);

  @override
  State<HomeTabContainerPage> createState() => _HomeTabContainerPageState();
}

class _HomeTabContainerPageState extends State<HomeTabContainerPage>
    with TickerProviderStateMixin {
  late List<GroupTabConfig> _allGroups;
  late TabController _tabController;
  final Set<int> _builtIndices = {0}; // 懒加载：记录已构建的索引

  @override
  void initState() {
    super.initState();
    _allGroups = _buildAllGroups();
    // 固定为四个主页面：Home / History / Trend / Settings
    _tabController = TabController(length: _allGroups.length, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _builtIndices.add(_tabController.index);
    });
  }

  List<GroupTabConfig> _buildAllGroups() {
    return [
      GroupTabConfig(
        id: 'input',
        title: 'Home',
        icon: Icons.home,
        builder: () => InputPage(),
      ),
      GroupTabConfig(
        id: 'history',
        title: 'History',
        icon: Icons.history,
        builder: () => BMIHistoryPage(),
        badgeCounter: () async {
          final list = await BMIHistoryManager.getBMIHistory();
          return list.length; // 用记录数作为指示
        },
      ),
      GroupTabConfig(
        id: 'trend',
        title: 'Trend',
        icon: Icons.show_chart,
        builder: () => BMITrendPage(),
      ),
      // 工具聚合页，将目标、营养、体脂、资料、隐私等页面内嵌为二级 Tab
      GroupTabConfig(
        id: 'setting',
        title: 'Settings',
        icon: Icons.dashboard_customize,
        builder: () => const ToolsHubPage(),
        // 使用提醒到期与否作为角标（来自 Goals 的逻辑）
        badgeCounter: () async {
          final prefs = await SharedPreferences.getInstance();
          final days = prefs.getInt('reminder_days') ?? 0;
          if (days <= 0) return 0;
          final history = await BMIHistoryManager.getBMIHistory();
          DateTime? last;
          if (history.isNotEmpty) {
            history.sort((a, b) => b.time.compareTo(a.time));
            last = history.first.time;
          }
          final now = DateTime.now();
          final due = last == null || now.difference(last).inDays >= days;
          return due ? 1 : 0;
        },
      ),
    ];
  }

  // 已移除分组管理相关逻辑，固定为四个主页面

  @override
  Widget build(BuildContext context) {
    final physics = widget.allowSwipe
        ? const PageScrollPhysics()
        : const NeverScrollableScrollPhysics();
    final theme = Theme.of(context);
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: physics,
        children: List.generate(_allGroups.length, (i) => _lazyTab(i)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _allGroups.map((g) => _buildTab(g)).toList(),
        currentIndex: _tabController.index,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _tabController.index = i);
        },
      ),

      // bottomNavigationBar: Material(
      //   color: theme.bottomAppBarTheme.color ?? kactiveCardColor,
      //   child: TabBar(
      //     controller: _tabController,
      //     isScrollable: false,
      //     labelColor: Colors.white,
      //     unselectedLabelColor: Colors.white70,
      //     dividerColor: Colors.transparent,
      //     tabs: _activeGroups.map((g) => _buildTab(g)).toList(),
      //   ),
      // ),
    );
  }

  Widget _lazyTab(int i) {
    final built = _builtIndices.contains(i);
    if (!built) {
      return const Center(child: CircularProgressIndicator());
    }
    return _allGroups[i].builder();
  }

  BottomNavigationBarItem _buildTab(GroupTabConfig g) {
    return BottomNavigationBarItem(
      icon: Icon(g.icon),
      label: g.title,
    );
  }
}
