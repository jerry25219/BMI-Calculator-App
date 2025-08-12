import 'package:flutter/material.dart';
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
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[_records.length -
                        1 -
                        index]; // Reverse order, newest on top
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
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
