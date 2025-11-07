import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../calculator_brain.dart';
import '../constants.dart';

class BMITrendPage extends StatefulWidget {
  const BMITrendPage({Key? key}) : super(key: key);

  @override
  State<BMITrendPage> createState() => _BMITrendPageState();
}

enum TimeRangePreset { week, month, threeMonths, year, all, custom }

enum GenderFilter { all, male, female }

enum CategoryFilter { all, underweight, normal, overweight }

class _BMITrendPageState extends State<BMITrendPage> {
  List<BMIRecord> _allRecords = [];
  bool _loading = true;

  // Filters
  TimeRangePreset _timePreset = TimeRangePreset.month;
  DateTimeRange? _customRange;
  GenderFilter _genderFilter = GenderFilter.all;
  CategoryFilter _categoryFilter = CategoryFilter.all;

  // Export features removed; no chart capture key needed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final records = await BMIHistoryManager.getBMIHistory();
    setState(() {
      _allRecords = records;
      _loading = false;
    });
  }

  DateTimeRange _calcRangeFromPreset(TimeRangePreset preset) {
    final now = DateTime.now();
    switch (preset) {
      case TimeRangePreset.week:
        return DateTimeRange(
            start: now.subtract(const Duration(days: 7)), end: now);
      case TimeRangePreset.month:
        return DateTimeRange(
            start: now.subtract(const Duration(days: 30)), end: now);
      case TimeRangePreset.threeMonths:
        return DateTimeRange(
            start: now.subtract(const Duration(days: 90)), end: now);
      case TimeRangePreset.year:
        return DateTimeRange(
            start: now.subtract(const Duration(days: 365)), end: now);
      case TimeRangePreset.all:
        final times = _allRecords.map((e) => e.time).toList();
        if (times.isEmpty)
          return DateTimeRange(
              start: now.subtract(const Duration(days: 365)), end: now);
        times.sort((a, b) => a.compareTo(b));
        return DateTimeRange(start: times.first, end: times.last);
      case TimeRangePreset.custom:
        return _customRange ??
            DateTimeRange(
                start: now.subtract(const Duration(days: 30)), end: now);
    }
  }

  List<BMIRecord> _filteredRecords() {
    if (_allRecords.isEmpty) return [];
    final range = _timePreset == TimeRangePreset.custom
        ? (_customRange ?? _calcRangeFromPreset(TimeRangePreset.month))
        : _calcRangeFromPreset(_timePreset);

    bool matchGender(BMIRecord r) {
      switch (_genderFilter) {
        case GenderFilter.all:
          return true;
        case GenderFilter.male:
          return r.gender == 'male';
        case GenderFilter.female:
          return r.gender == 'female';
      }
    }

    String result(BMIRecord r) {
      if (r.bmi >= 25) return 'OVERWEIGHT';
      if (r.bmi < 18.5) return 'UNDERWEIGHT';
      return 'NORMAL';
    }

    bool matchCategory(BMIRecord r) {
      switch (_categoryFilter) {
        case CategoryFilter.all:
          return true;
        case CategoryFilter.underweight:
          return result(r) == 'UNDERWEIGHT';
        case CategoryFilter.normal:
          return result(r) == 'NORMAL';
        case CategoryFilter.overweight:
          return result(r) == 'OVERWEIGHT';
      }
    }

    final filtered = _allRecords
        .where((r) =>
            r.time.isAfter(range.start) &&
            r.time.isBefore(range.end.add(const Duration(seconds: 1))) &&
            matchGender(r) &&
            matchCategory(r))
        .toList();

    filtered.sort((a, b) => a.time.compareTo(b.time));
    return filtered;
  }

  List<BMIRecord> _downsample(List<BMIRecord> list, {int maxPoints = 400}) {
    if (list.length <= maxPoints) return list;
    final step = (list.length / maxPoints).ceil();
    final sampled = <BMIRecord>[];
    for (int i = 0; i < list.length; i += step) {
      sampled.add(list[i]);
    }
    // Ensure last point included
    if (sampled.last.time != list.last.time) sampled.add(list.last);
    return sampled;
  }

  Widget _buildChartCard(List<BMIRecord> records, double height) {
    if (records.isEmpty) {
      return Card(
        color: kactiveCardColor,
        margin: const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text('No data in selected range',
                style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }

    final data = _downsample(records);
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].bmi));
    }
    final minY = data.map((e) => e.bmi).reduce(math.min);
    final maxY = data.map((e) => e.bmi).reduce(math.max);

    String formatTick(int idx) {
      if (idx < 0 || idx >= data.length) return '';
      final t = data[idx].time;
      return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }

    final labelIndexes = <int>{0, data.length - 1};
    if (data.length > 3) {
      labelIndexes.add((data.length / 3).floor());
      labelIndexes.add((data.length * 2 / 3).floor());
    }

    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BMI Trend',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: height,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: (minY - 1).floorToDouble(),
                  maxY: (maxY + 1).ceilToDouble(),
                  gridData: FlGridData(
                      show: true,
                      horizontalInterval: 1,
                      verticalInterval:
                          math.max(1, (data.length / 6).floorToDouble())),
                  borderData: FlBorderData(
                      show: true,
                      border: const Border(
                          bottom: BorderSide(color: Colors.white24),
                          left: BorderSide(color: Colors.white24))),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          final show = labelIndexes.contains(idx);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(show ? formatTick(idx) : '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItems: (spots) {
                            return spots.map((s) {
                              final idx = s.x.toInt();
                              final r = data[idx];
                              final t = r.time;
                              final dateStr =
                                  '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
                              return LineTooltipItem(
                                  'BMI ${r.bmi.toStringAsFixed(1)}\n$dateStr',
                                  const TextStyle(
                                      color: Colors.white, fontSize: 12));
                            }).toList();
                          })),
                  lineBarsData: [
                    LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: const Color(0xFF24D876),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF24D876).withOpacity(0.2)))
                  ],
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                        y: 18.5,
                        color: Colors.orangeAccent,
                        strokeWidth: 1,
                        dashArray: [4, 4]),
                    HorizontalLine(
                        y: 24.9,
                        color: Colors.orangeAccent,
                        strokeWidth: 1,
                        dashArray: [4, 4]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    Future<void> pickCustomRange() async {
      final now = DateTime.now();
      final initialRange = _customRange ??
          DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: initialRange,
        helpText: 'Select custom date range',
      );
      if (picked != null) {
        setState(() {
          _timePreset = TimeRangePreset.custom;
          _customRange = picked;
        });
      }
    }

    Widget timeChip(TimeRangePreset preset, String label) {
      final selected = _timePreset == preset;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _timePreset = preset);
        },
        selectedColor: kbottomContainerColor,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      );
    }

    Widget genderChip(GenderFilter g, String label) {
      final selected = _genderFilter == g;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _genderFilter = g),
        selectedColor: kbottomContainerColor,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      );
    }

    Widget catChip(CategoryFilter c, String label) {
      final selected = _categoryFilter == c;
      Color? selColor;
      switch (c) {
        case CategoryFilter.underweight:
          selColor = Colors.deepOrangeAccent;
          break;
        case CategoryFilter.normal:
          selColor = const Color(0xFF24D876);
          break;
        case CategoryFilter.overweight:
          selColor = Colors.deepOrangeAccent;
          break;
        case CategoryFilter.all:
          selColor = kbottomContainerColor;
          break;
      }
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _categoryFilter = c),
        selectedColor: selColor,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      );
    }

    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Time Range',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              timeChip(TimeRangePreset.week, 'Last 7 days'),
              timeChip(TimeRangePreset.month, 'Last 30 days'),
              timeChip(TimeRangePreset.threeMonths, 'Last 90 days'),
              timeChip(TimeRangePreset.year, 'Last 1 year'),
              timeChip(TimeRangePreset.all, 'All'),
              ActionChip(
                label: const Text('Custom'),
                onPressed: pickCustomRange,
                backgroundColor: Colors.white10,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ]),
            const SizedBox(height: 16),
            const Text('Data Filters',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              genderChip(GenderFilter.all, 'All genders'),
              genderChip(GenderFilter.male, 'Male'),
              genderChip(GenderFilter.female, 'Female'),
              catChip(CategoryFilter.all, 'All categories'),
              catChip(CategoryFilter.underweight, 'UNDERWEIGHT'),
              catChip(CategoryFilter.normal, 'NORMAL'),
              catChip(CategoryFilter.overweight, 'OVERWEIGHT'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<BMIRecord> records) {
    if (records.isEmpty) {
      return Card(
        color: kactiveCardColor,
        margin: const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data', style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    final values = records.map((e) => e.bmi).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics Summary',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 8, children: [
              _statItem('Samples', records.length.toString()),
              _statItem('Average BMI', avg.toStringAsFixed(2)),
              _statItem('Min BMI', min.toStringAsFixed(1)),
              _statItem('Max BMI', max.toStringAsFixed(1)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Export features removed per request.

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords();
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Trend'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final chartHeight = isWide ? 320.0 : 240.0;
                final content = [
                  _buildChartCard(records, chartHeight),
                  _buildControls(context),
                  _buildStatsCard(records),
                ];

                if (isWide) {
                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: content[0]),
                        SizedBox(
                          width: 420,
                          child: Column(children: [content[1], content[2]]),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView(
                    children: content,
                  );
                }
              },
            ),
    );
  }
}
