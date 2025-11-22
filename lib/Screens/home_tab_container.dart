import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../calculator_brain.dart';

import 'BMIHistoryPage.dart';
import 'BMITrendPage.dart';
import 'input_page.dart';
import 'tools_hub_page.dart';

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
  late List<GroupTabConfig> _activeGroups;
  late TabController _tabController;
  final Set<int> _builtIndices = {0}; // 懒加载：记录已构建的索引
  Map<String, int> _badgeMap = {};

  @override
  void initState() {
    super.initState();
    _allGroups = _buildAllGroups();
    _activeGroups = [];
    _tabController = TabController(length: 0, vsync: this);
    _tabController.addListener(_onTabChange);
    _loadActiveGroups();
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

  Future<void> _loadActiveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('active_groups');
    List<String> ids;
    if (saved != null && saved.isNotEmpty) {
      ids = saved;
    } else if (widget.initialGroups != null &&
        widget.initialGroups!.isNotEmpty) {
      ids = widget.initialGroups!;
    } else {
      // 默认仅放置不超过 5 个底部标签：首页/历史/趋势/工具
      ids = ['input', 'history', 'trend', 'tools'];
    }
    // 兼容旧的分组 id：若包含旧的功能页 id，则改为 tools 聚合
    final legacy = {'goals', 'nutrition', 'body', 'sources', 'privacy'};
    if (ids.any((e) => legacy.contains(e))) {
      ids.removeWhere((e) => legacy.contains(e));
      if (!ids.contains('tools')) ids.add('tools');
    }
    // 底部 TabBar 数量限制：不超过 5 个
    if (ids.length > 5) {
      ids = ids.take(5).toList();
    }
    setState(() {
      _activeGroups =
          _allGroups.where((g) => ids.contains(g.id)).toList(growable: true);
      _tabController.removeListener(_onTabChange);
      _tabController.dispose();
      _tabController = TabController(length: _activeGroups.length, vsync: this);
      _tabController.addListener(_onTabChange);
      _builtIndices.clear();
      _builtIndices.add(0);
    });
    _refreshBadges();
  }

  Future<void> _refreshBadges() async {
    final map = <String, int>{};
    for (final g in _activeGroups) {
      if (g.badgeCounter != null) {
        try {
          map[g.id] = await g.badgeCounter!.call();
        } catch (_) {}
      }
    }
    if (mounted) setState(() => _badgeMap = map);
  }

  void _openManageGroups() async {
    final selected = Set<String>.from(_activeGroups.map((g) => g.id));
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kactiveCardColor,
          title:
              const Text('Manage Tabs', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _allGroups.map((g) {
                final checked = selected.contains(g.id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) {
                    if (v == true) {
                      selected.add(g.id);
                    } else {
                      selected.remove(g.id);
                    }
                    // 强制刷新对话框状态
                    (ctx as Element).markNeedsBuild();
                  },
                  activeColor: Colors.white,
                  checkColor: kactiveCardColor,
                  title: Row(
                    children: [
                      Icon(g.icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(g.title,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selected.toList()),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      _applyGroupSelection(result);
    }
  }

  void _applyGroupSelection(List<String> ids) {
    setState(() {
      _activeGroups =
          _allGroups.where((g) => ids.contains(g.id)).toList(growable: true);
      final old = _tabController.index;
      _tabController.removeListener(_onTabChange);
      _tabController.dispose();
      _tabController = TabController(length: _activeGroups.length, vsync: this);
      _tabController.addListener(_onTabChange);
      _builtIndices.clear();
      _builtIndices.add(0);
      if (old < _activeGroups.length) {
        _tabController.index = old;
        _builtIndices.add(old);
      }
      _refreshBadges();
    });
    _persistActiveGroups(ids);
  }

  Future<void> _persistActiveGroups(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('active_groups', ids);
  }

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
        children: List.generate(_activeGroups.length, (i) => _lazyTab(i)),
      ),
      bottomNavigationBar: Material(
        color: theme.bottomAppBarTheme.color ?? kactiveCardColor,
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.transparent,
          tabs: _activeGroups.map((g) => _buildTab(g)).toList(),
        ),
      ),
    );
  }

  Widget _lazyTab(int i) {
    final built = _builtIndices.contains(i);
    if (!built) {
      return const Center(child: CircularProgressIndicator());
    }
    return _activeGroups[i].builder();
  }

  Widget _buildTab(GroupTabConfig g) {
    return Tab(
      icon: Icon(g.icon),
      text: g.title,
    );
  }
}
