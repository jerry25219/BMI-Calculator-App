import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _groupByMonth = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('BMI History'),
        actions: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Text('Group:',
                                style: TextStyle(color: Colors.white70)),
                            ChoiceChip(
                              label: const Text('Monthly'),
                              selected: _groupByMonth,
                              onSelected: (_) =>
                                  setState(() => _groupByMonth = true),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('No grouping'),
                              selected: !_groupByMonth,
                              onSelected: (_) =>
                                  setState(() => _groupByMonth = false),
                            ),
                          ]),
                          Text('${_records.length} records',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    // 趋势图
                    // 历史列表
                    Expanded(
                      child: _groupByMonth
                          ? _buildGroupedList()
                          : _buildFlatList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFlatList() {
    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[_records.length - 1 - index]; // 反序，最新在最上
        return _buildRecordCard(record, index);
      },
    );
  }

  Widget _buildGroupedList() {
    final sorted = List<BMIRecord>.from(_records)
      ..sort((a, b) => a.time.compareTo(b.time));
    final groups = <String, List<BMIRecord>>{};
    for (final r in sorted) {
      final key = '${r.time.year}-${r.time.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(r);
    }
    final keys = groups.keys.toList()..sort();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, idx) {
        final key = keys[keys.length - 1 - idx]; // 最新月份在前
        final list = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Text(key,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ),
            ...list.reversed.toList().asMap().entries.map((e) {
              final record = e.value;
              final index = _records.indexOf(record);
              return _buildRecordCard(record, index);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRecordCard(BMIRecord record, int index) {
    final bmiValue = record.bmi.toStringAsFixed(1);
    final dateTime = record.time;
    final formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    Color textColor = const Color(0xFF24D876);
    String resultText = 'NORMAL';
    if (record.bmi >= 28.0) {
      textColor = Colors.deepOrangeAccent;
      resultText = 'OBESE';
    } else if (record.bmi >= 24.0) {
      textColor = Colors.deepOrangeAccent;
      resultText = 'OVERWEIGHT';
    } else if (record.bmi < 18.5) {
      textColor = Colors.deepOrangeAccent;
      resultText = 'UNDERWEIGHT';
    }

    return Card(
      color: kactiveCardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BMI: $bmiValue',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(children: [
                  Text(
                    resultText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    tooltip: 'Edit',
                    onPressed: () => _editRecord(index, record),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_forever, color: Colors.white70),
                    tooltip: 'Delete',
                    onPressed: () => _deleteRecord(index),
                  ),
                ])
              ],
            ),
            const SizedBox(height: 8),
            Text('Height: ${record.height} cm', style: kBodyTextStyle),
            Text('Weight: ${record.weight} kg', style: kBodyTextStyle),
            Text('Gender: ${record.gender == 'male' ? 'Male' : 'Female'}',
                style: kBodyTextStyle),
            if (record.activity != null)
              Text('Activity: ${record.activity}', style: kBodyTextStyle),
            const SizedBox(height: 8),
            Text('Record time: $formattedDate',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRecord(int index) async {
    final list = List<BMIRecord>.from(_records);
    // 反序展示，删除时需要定位实际索引
    final realIndex = list.length - 1 - index;
    list.removeAt(realIndex);
    await BMIHistoryManager.setBMIHistory(list);
    _loadHistory();
  }

  Future<void> _editRecord(int index, BMIRecord record) async {
    final weightController =
        TextEditingController(text: record.weight.toString());
    final heightController =
        TextEditingController(text: record.height.toString());
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kactiveCardColor,
          title:
              const Text('Edit Record', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newW = int.tryParse(weightController.text.trim());
                final newH = int.tryParse(heightController.text.trim());
                if (newW != null && newH != null) {
                  final newBmi = newW / math.pow(newH / 100, 2);
                  final list = List<BMIRecord>.from(_records);
                  final realIndex = list.length - 1 - index;
                  list[realIndex] = BMIRecord(
                    height: newH,
                    weight: newW,
                    gender: record.gender,
                    bmi: newBmi,
                    time: record.time,
                    activity: record.activity,
                  );
                  await BMIHistoryManager.setBMIHistory(list);
                  Navigator.pop(ctx);
                  _loadHistory();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportCsv() async {
    if (_records.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No data to export')));
      return;
    }
    final buffer = StringBuffer('time,bmi,height,weight,gender,activity\n');
    for (final r in _records) {
      buffer.writeln(
          '${r.time.toIso8601String()},${r.bmi.toStringAsFixed(1)},${r.height},${r.weight},${r.gender},${r.activity ?? ''}');
    }
    final csvText = buffer.toString();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kactiveCardColor,
        title: const Text('Export CSV', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: SelectableText(csvText,
              style: const TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV copied to clipboard')));
            },
            child: const Text('Copy to clipboard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kactiveCardColor,
        title: const Text('Import CSV', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
              hintText:
                  'Paste CSV text: time,bmi,height,weight,gender,activity'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              final lines =
                  text.split('\n').where((l) => l.trim().isNotEmpty).toList();
              // Skip header line if present
              int startIdx = 0;
              if (lines.first.toLowerCase().startsWith('time,')) startIdx = 1;
              final imported = <BMIRecord>[];
              for (int i = startIdx; i < lines.length; i++) {
                final cols = lines[i].split(',');
                if (cols.length < 5) continue;
                try {
                  final time = DateTime.parse(cols[0]);
                  final bmi = double.parse(cols[1]);
                  final height = int.parse(cols[2]);
                  final weight = int.parse(cols[3]);
                  final gender = cols[4];
                  final activity = cols.length > 5
                      ? (cols[5].isEmpty ? null : cols[5])
                      : null;
                  imported.add(BMIRecord(
                    height: height,
                    weight: weight,
                    gender: gender,
                    bmi: bmi,
                    time: time,
                    activity: activity,
                  ));
                } catch (_) {}
              }
              if (imported.isNotEmpty) {
                final merged = List<BMIRecord>.from(_records)..addAll(imported);
                await BMIHistoryManager.setBMIHistory(merged);
                Navigator.pop(ctx);
                _loadHistory();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Imported ${imported.length} records')));
              } else {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No valid records parsed')));
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
