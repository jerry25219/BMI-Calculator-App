import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../calculator_brain.dart';
import '../constants.dart';

class WeightTrendPage extends StatefulWidget {
  static const String routeName = '/weight_trend';
  const WeightTrendPage({Key? key}) : super(key: key);

  @override
  State<WeightTrendPage> createState() => _WeightTrendPageState();
}

enum WeightTimeRange { week, month, threeMonths, year, all, custom }

class _WeightTrendPageState extends State<WeightTrendPage> {
  List<BMIRecord> _all = [];
  bool _loading = true;
  WeightTimeRange _preset = WeightTimeRange.month;
  DateTimeRange? _custom;
  double? _goalWeight;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await BMIHistoryManager.getBMIHistory();
    final prefs = await SharedPreferences.getInstance();
    final gw = prefs.getDouble('goal_weight');
    setState(() {
      _all = list..sort((a, b) => a.time.compareTo(b.time));
      _goalWeight = gw;
      _loading = false;
    });
  }

  DateTimeRange _rangeFromPreset(WeightTimeRange p) {
    final now = DateTime.now();
    switch (p) {
      case WeightTimeRange.week:
        return DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
      case WeightTimeRange.month:
        return DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
      case WeightTimeRange.threeMonths:
        return DateTimeRange(start: now.subtract(const Duration(days: 90)), end: now);
      case WeightTimeRange.year:
        return DateTimeRange(start: now.subtract(const Duration(days: 365)), end: now);
      case WeightTimeRange.all:
        if (_all.isEmpty) return DateTimeRange(start: now.subtract(const Duration(days: 365)), end: now);
        return DateTimeRange(start: _all.first.time, end: _all.last.time);
      case WeightTimeRange.custom:
        return _custom ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    }
  }

  List<BMIRecord> _filtered() {
    if (_all.isEmpty) return [];
    final range = _preset == WeightTimeRange.custom ? _rangeFromPreset(WeightTimeRange.custom) : _rangeFromPreset(_preset);
    return _all
        .where((r) => r.time.isAfter(range.start) && r.time.isBefore(range.end.add(const Duration(seconds: 1))))
        .toList();
  }

  Widget _buildChart(List<BMIRecord> recs) {
    if (recs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text('No data in selected range', style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    final weights = recs.map((e) => e.weight.toDouble()).toList();
    final minY = weights.reduce(math.min);
    final maxY = weights.reduce(math.max);
    final spots = <FlSpot>[];
    for (int i = 0; i < recs.length; i++) {
      spots.add(FlSpot(i.toDouble(), recs[i].weight.toDouble()));
    }

    String bottomLabel(int i) {
      if (i < 0 || i >= recs.length) return '';
      final t = recs[i].time;
      return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }

    final goalLine = (_goalWeight != null)
        ? HorizontalLine(y: _goalWeight!, color: Colors.lightBlueAccent, dashArray: [8, 4], strokeWidth: 1)
        : null;

    return SizedBox(
      height: 260,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, horizontalInterval: 1, getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white12, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 36,
                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(color: Colors.white70, fontSize: 12))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: math.max(1, (recs.length / 3).floorToDouble()),
                getTitlesWidget: (v, _) => Text(bottomLabel(v.toInt()), style: const TextStyle(color: Colors.white70, fontSize: 12))),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minY: (minY - 1).floorToDouble(),
        maxY: (maxY + 1).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(spots: spots, isCurved: false, color: const Color(0xFF24D876), dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0xFF24D876).withOpacity(0.15)))
        ],
        extraLinesData: goalLine != null ? ExtraLinesData(horizontalLines: [goalLine]) : const ExtraLinesData(horizontalLines: []),
        borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Colors.white24), left: BorderSide(color: Colors.white24))),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Trend'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Set Goal Weight',
            icon: const Icon(Icons.flag),
            onPressed: _setGoalWeight,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Card(
                  color: kactiveCardColor,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weight Trend',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildChart(filtered),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: kactiveCardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip(WeightTimeRange.week, 'Last 7 days'),
                      _chip(WeightTimeRange.month, 'Last 30 days'),
                      _chip(WeightTimeRange.threeMonths, 'Last 90 days'),
                      _chip(WeightTimeRange.year, 'Last 1 year'),
                      _chip(WeightTimeRange.all, 'All'),
                      ActionChip(
                        label: const Text('Custom'),
                        onPressed: _pickRange,
                        backgroundColor: Colors.white10,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ]),
                  ),
                ),
                _buildStats(filtered),
              ],
            ),
    );
  }

  Widget _buildStats(List<BMIRecord> recs) {
    if (recs.isEmpty) {
      return Card(
        color: kactiveCardColor,
        margin: const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data', style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    final vals = recs.map((e) => e.weight.toDouble()).toList();
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    final min = vals.reduce(math.min);
    final max = vals.reduce(math.max);
    final delta30 = _delta(recs, days: 30);
    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(spacing: 12, runSpacing: 8, children: [
          _kv('Samples', recs.length.toString()),
          _kv('Average (kg)', avg.toStringAsFixed(1)),
          _kv('Min (kg)', min.toStringAsFixed(1)),
          _kv('Max (kg)', max.toStringAsFixed(1)),
          _kv('Last 30 days (kg)', delta30),
        ]),
      ),
    );
  }

  String _delta(List<BMIRecord> recs, {int days = 30}) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final within = recs.where((r) => r.time.isAfter(start)).toList();
    if (within.length < 2) return '-';
    final diff = within.last.weight - within.first.weight;
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _custom ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: initial,
      helpText: 'Select custom date range',
    );
    if (picked != null) {
      setState(() {
        _preset = WeightTimeRange.custom;
        _custom = picked;
      });
    }
  }

  Widget _chip(WeightTimeRange p, String label) {
    final sel = _preset == p;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      showCheckmark: false,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      onSelected: (_) => setState(() => _preset = p),
      selectedColor: kbottomContainerColor,
      labelStyle: TextStyle(color: sel ? Colors.white : Colors.white70),
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

  Future<void> _setGoalWeight() async {
    final controller = TextEditingController(
        text: _goalWeight != null ? _goalWeight!.toStringAsFixed(1) : '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4C4F5E),
        title: const Text('Set Goal Weight', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'kg', hintStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(controller.text.trim());
      if (v != null && v > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('goal_weight', v);
        setState(() => _goalWeight = v);
      }
    }
  }
}
