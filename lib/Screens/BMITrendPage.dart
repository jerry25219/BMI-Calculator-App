import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double? _goalBmi;

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
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getDouble('goal_bmi');
    setState(() {
      _allRecords = records;
      _loading = false;
      _goalBmi = goal;
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
    final minY = data.map((e) => e.bmi).reduce(math.min);
    final maxY = data.map((e) => e.bmi).reduce(math.max);
    final yMin = (minY - 1).floorToDouble();
    final yMax = (maxY + 1).ceilToDouble();

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
              child: _BMIChart(
                records: data,
                yMin: yMin,
                yMax: yMax,
                labelIndexes: labelIndexes.toList()..sort(),
                formatTick: formatTick,
                goalBmi: _goalBmi,
              ),
            ),
            const SizedBox(height: 8),
            const Text('参考线: 18.5、23.9、27.9',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
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
        showCheckmark: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
        showCheckmark: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
        showCheckmark: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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

class _BMIChart extends StatelessWidget {
  final List<BMIRecord> records;
  final double yMin;
  final double yMax;
  final List<int> labelIndexes;
  final String Function(int) formatTick;
  final double? goalBmi;

  const _BMIChart({
    Key? key,
    required this.records,
    required this.yMin,
    required this.yMax,
    required this.labelIndexes,
    required this.formatTick,
    this.goalBmi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        painter: _BMIChartPainter(
          records: records,
          yMin: yMin,
          yMax: yMax,
          labelIndexes: labelIndexes,
          formatTick: formatTick,
          goalBmi: goalBmi,
        ),
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
    });
  }
}

class _BMIChartPainter extends CustomPainter {
  final List<BMIRecord> records;
  final double yMin;
  final double yMax;
  final List<int> labelIndexes;
  final String Function(int) formatTick;
  final double? goalBmi;

  _BMIChartPainter({
    required this.records,
    required this.yMin,
    required this.yMax,
    required this.labelIndexes,
    required this.formatTick,
    required this.goalBmi,
  });

  final Color axisColor = Colors.white24;
  final Color gridColor = Colors.white12;
  final Color lineColor = const Color(0xFF24D876);
  final Color dotColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.fromLTRB(48, 16, 16, 32);
    final chartRect = Rect.fromLTWH(
        padding.left,
        padding.top,
        size.width - padding.left - padding.right,
        size.height - padding.top - padding.bottom);

    // Draw axes
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    // Y axis
    canvas.drawLine(Offset(chartRect.left, chartRect.top),
        Offset(chartRect.left, chartRect.bottom), axisPaint);
    // X axis
    canvas.drawLine(Offset(chartRect.left, chartRect.bottom),
        Offset(chartRect.right, chartRect.bottom), axisPaint);

    // Draw grid lines (horizontal every 1 BMI unit)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (double y = yMin; y <= yMax; y += 1) {
      final dy = _mapY(y, chartRect);
      canvas.drawLine(
          Offset(chartRect.left, dy), Offset(chartRect.right, dy), gridPaint);
    }

    // Draw dashed horizontal reference lines for CN classification
    void drawDashedH(double yValue, Color color) {
      final dy = _mapY(yValue, chartRect);
      final dashPaint = Paint()
        ..color = color
        ..strokeWidth = 1;
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      double x = chartRect.left;
      while (x < chartRect.right) {
        final x2 = math.min(x + dashWidth, chartRect.right);
        canvas.drawLine(Offset(x, dy), Offset(x2, dy), dashPaint);
        x += dashWidth + dashSpace;
      }
    }

    drawDashedH(18.5, Colors.orangeAccent);
    drawDashedH(23.9, Colors.orangeAccent);
    drawDashedH(27.9, Colors.orangeAccent);
    if (goalBmi != null && goalBmi! >= yMin && goalBmi! <= yMax) {
      drawDashedH(goalBmi!, Colors.lightBlueAccent);
    }

    // Prepare path for BMI line
    final path = Path();
    if (records.isNotEmpty) {
      for (int i = 0; i < records.length; i++) {
        final p = _mapPoint(i.toDouble(), records[i].bmi, chartRect);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
    }
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, linePaint);

    // Draw area under the curve (light fill)
    final areaPath = Path.from(path);
    areaPath.lineTo(
        _mapPoint((records.length - 1).toDouble(), yMin, chartRect).dx,
        _mapPoint((records.length - 1).toDouble(), yMin, chartRect).dy);
    areaPath.lineTo(
        _mapPoint(0, yMin, chartRect).dx, _mapPoint(0, yMin, chartRect).dy);
    areaPath.close();
    final fillPaint = Paint()
      ..color = const Color(0xFF24D876).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < records.length; i++) {
      final p = _mapPoint(i.toDouble(), records[i].bmi, chartRect);
      canvas.drawCircle(p, 2.5, dotPaint);
    }

    // Draw left axis labels (every 1 BMI unit)
    for (double y = yMin; y <= yMax; y += 1) {
      final dy = _mapY(y, chartRect);
      final tp = TextPainter(
        text: TextSpan(
          text: y.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
          canvas, Offset(chartRect.left - 8 - tp.width, dy - tp.height / 2));
    }

    // Draw bottom axis labels at selected indexes
    for (final idx in labelIndexes) {
      final p = _mapPoint(idx.toDouble(), yMin, chartRect);
      final label = formatTick(idx);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: chartRect.width / 3);
      tp.paint(canvas, Offset(p.dx - tp.width / 2, chartRect.bottom + 4));
    }
  }

  double _mapY(double y, Rect rect) {
    final t = (y - yMin) / (yMax - yMin);
    return rect.bottom - t * rect.height;
  }

  Offset _mapPoint(double xIdx, double yVal, Rect rect) {
    final x =
        rect.left + (xIdx / math.max(1, (records.length - 1))) * rect.width;
    final y = _mapY(yVal, rect);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _BMIChartPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.labelIndexes != labelIndexes ||
        oldDelegate.goalBmi != goalBmi;
  }
}
