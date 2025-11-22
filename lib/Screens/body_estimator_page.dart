import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

class BodyEstimatorPage extends StatefulWidget {
  static const String id = 'body_estimator_page';
  const BodyEstimatorPage({Key? key}) : super(key: key);

  @override
  State<BodyEstimatorPage> createState() => _BodyEstimatorPageState();
}

class _BodyEstimatorPageState extends State<BodyEstimatorPage> {
  String gender = 'male';
  int height = 170; // cm
  int waist = 80; // cm
  int neck = 38; // cm
  int hip = 95; // cm (for female)

  double? bf;

  void _calculate() {
    // US Navy method, works with cm using log10 on cm values
    double h = height.toDouble();
    double w = waist.toDouble();
    double n = neck.toDouble();
    double result;
    if (gender == 'male') {
      result = 495 / (1.0324 - 0.19077 * log(w - n) / ln10 + 0.15456 * log(h) / ln10) - 450;
    } else {
      double hp = hip.toDouble();
      result = 495 / (1.29579 - 0.35004 * log(w + hp - n) / ln10 + 0.22100 * log(h) / ln10) - 450;
    }
    setState(() {
      bf = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('体脂率与腰臀比估算')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: kactiveCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('输入（单位：cm）', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(children: [
                      ChoiceChip(label: const Text('Male'), selected: gender == 'male', onSelected: (_) => setState(() => gender = 'male')),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Female'), selected: gender == 'female', onSelected: (_) => setState(() => gender = 'female')),
                    ]),
                    const SizedBox(height: 8),
                    _numberRow('Height', height, (v) => setState(() => height = v)),
                    _numberRow('Waist', waist, (v) => setState(() => waist = v)),
                    _numberRow('Neck', neck, (v) => setState(() => neck = v)),
                    if (gender == 'female') _numberRow('Hip', hip, (v) => setState(() => hip = v)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _calculate, child: const Text('估算体脂率')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: kactiveCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('腰臀比（WHR）', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('WHR = 腰围(waist) / 臀围(hip)', style: const TextStyle(color: Colors.white)),
                    if (gender == 'female')
                      Text('当前 WHR ≈ ${(waist / hip).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70))
                    else
                      const Text('男性未输入臀围，WHR不计算', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (bf != null)
              Card(
                color: kactiveCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('体脂率估算（仅供参考）', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('BF% ≈ ${bf!.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('声明：此公式仅供参考，存在误差，不用于诊断或医疗目的。', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _numberRow(String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        Expanded(child: Text('$label (cm)', style: const TextStyle(color: Colors.white))),
        IconButton(onPressed: () => onChanged(value-1), icon: const Icon(Icons.remove, color: Colors.white70)),
        Text(value.toString(), style: const TextStyle(color: Colors.white)),
        IconButton(onPressed: () => onChanged(value+1), icon: const Icon(Icons.add, color: Colors.white70)),
      ],
    );
  }
}

