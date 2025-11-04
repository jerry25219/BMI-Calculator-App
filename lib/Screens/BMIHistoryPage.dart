import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'BMITrendPage.dart';
import '../calculator_brain.dart';
import '../constants.dart';

class BMIHistoryPage extends StatefulWidget {
  @override
  _BMIHistoryPageState createState() => _BMIHistoryPageState();
}

class _BMIHistoryPageState extends State<BMIHistoryPage> {
  List<BMIRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final records = await BMIHistoryManager.getBMIHistory();

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Widget _buildTrendChart(List<BMIRecord> records) {
    if (records.isEmpty) return SizedBox.shrink();

    // 按时间升序排列，方便画趋势线
    final sorted = List<BMIRecord>.from(records)
      ..sort((a, b) => a.time.compareTo(b.time));

    // 生成点位：x 为索引（时间顺序），y 为 BMI
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].bmi));
    }

    final minY = sorted.map((e) => e.bmi).reduce(math.min);
    final maxY = sorted.map((e) => e.bmi).reduce(math.max);
    // 给上下各留一点可视边距
    final yPadding = 1.0;

    String _formatDateShort(int index) {
      // 仅展示少量刻度，避免拥挤
      if (index < 0 || index >= sorted.length) return '';
      final t = sorted[index].time;
      return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }

    // 计算需要显示的几个关键刻度：首、末、以及中间两个点
    final labelIndexes = <int>{0, sorted.length - 1};
    if (sorted.length > 3) {
      labelIndexes.add((sorted.length / 3).floor());
      labelIndexes.add((sorted.length * 2 / 3).floor());
    }

    return Card(
      color: kactiveCardColor,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'BMI 趋势',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (sorted.length - 1).toDouble(),
                  minY: (minY - yPadding).floorToDouble(),
                  maxY: (maxY + yPadding).ceilToDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval:
                        math.max(1, (sorted.length / 6).floorToDouble()),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white12,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.white24, width: 1),
                      left: BorderSide(color: Colors.white24, width: 1),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          final show = labelIndexes.contains(idx);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              show ? _formatDateShort(idx) : '',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((s) {
                          final idx = s.x.toInt();
                          final r = sorted[idx];
                          final t = r.time;
                          final dateStr =
                              '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
                          return LineTooltipItem(
                            'BMI ${r.bmi.toStringAsFixed(1)}\n$dateStr',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.lightBlueAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.lightBlueAccent.withOpacity(0.2),
                      ),
                    ),
                  ],
                  // 参考线：正常 BMI 范围 18.5 ~ 24.9
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
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
                    ],
                  ),
                ),
              ),
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
        centerTitle: true,
        title: Text('BMI History'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            tooltip: '趋势图',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const BMITrendPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));
                    return FadeTransition(opacity: animation.drive(tween), child: child);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await BMIHistoryManager.clearHistory();
              _loadHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('History cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(child: Text('No history records', style: kBodyTextStyle))
              : Column(
                  children: [
                    // 趋势图
                    _buildTrendChart(_records),
                    // 历史列表
                    Expanded(
                      child: ListView.builder(
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record =
                              _records[_records.length - 1 - index]; // 反序，最新在最上
                          final bmiValue = record.bmi.toStringAsFixed(1);
                          final dateTime = record.time;
                          final formattedDate =
                              '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

                          Color textColor = Colors.green;
                          String resultText = 'NORMAL';
                          if (record.bmi >= 25) {
                            textColor = Colors.deepOrangeAccent;
                            resultText = 'OVERWEIGHT';
                          } else if (record.bmi < 18.5) {
                            textColor = Colors.deepOrangeAccent;
                            resultText = 'UNDERWEIGHT';
                          }

                          return Card(
                            color: kactiveCardColor,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'BMI: $bmiValue',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        resultText,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Height: ${record.height} cm',
                                    style: kBodyTextStyle,
                                  ),
                                  Text(
                                    'Weight: ${record.weight} kg',
                                    style: kBodyTextStyle,
                                  ),
                                  Text(
                                    'Gender: ${record.gender == 'male' ? 'Male' : 'Female'}',
                                    style: kBodyTextStyle,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Record time: $formattedDate',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
