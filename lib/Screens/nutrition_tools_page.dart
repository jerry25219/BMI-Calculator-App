import 'package:flutter/material.dart';
import '../constants.dart';

class NutritionToolsPage extends StatefulWidget {
  static const String id = 'nutrition_tools_page';
  const NutritionToolsPage({Key? key}) : super(key: key);

  @override
  State<NutritionToolsPage> createState() => _NutritionToolsPageState();
}

class _NutritionToolsPageState extends State<NutritionToolsPage> {
  String gender = 'male';
  int age = 25;
  int height = 170;
  int weight = 65;
  String activity = 'sedentary';

  double? bmr;
  double? tdee;

  void _calculate() {
    // Mifflin-St Jeor
    double b = 10 * weight + 6.25 * height - 5 * age + (gender == 'male' ? 5 : -161);
    double factor = 1.2;
    switch (activity) {
      case 'light':
        factor = 1.375;
        break;
      case 'active':
        factor = 1.55;
        break;
    }
    setState(() {
      bmr = b;
      tdee = b * factor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('能量与营养计算')),
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
                    const Text('基本信息', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(children: [
                      ChoiceChip(label: const Text('Male'), selected: gender == 'male', onSelected: (_) => setState(() => gender = 'male')),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Female'), selected: gender == 'female', onSelected: (_) => setState(() => gender = 'female')),
                    ]),
                    const SizedBox(height: 8),
                    _numberRow('Age', age, (v) => setState(() => age = v)),
                    _numberRow('Height (cm)', height, (v) => setState(() => height = v)),
                    _numberRow('Weight (kg)', weight, (v) => setState(() => weight = v)),
                    const SizedBox(height: 8),
                    const Text('活动水平', style: TextStyle(color: Colors.white)),
                    Wrap(spacing: 8, children: [
                      ChoiceChip(label: const Text('Sedentary'), selected: activity == 'sedentary', onSelected: (_) => setState(() => activity = 'sedentary')),
                      ChoiceChip(label: const Text('Lightly Active'), selected: activity == 'light', onSelected: (_) => setState(() => activity = 'light')),
                      ChoiceChip(label: const Text('Active'), selected: activity == 'active', onSelected: (_) => setState(() => activity = 'active')),
                    ]),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _calculate, child: const Text('计算')), 
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (bmr != null && tdee != null)
              Card(
                color: kactiveCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('结果（仅供参考）', style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('BMR（基础代谢）≈ ${bmr!.round()} kcal', style: const TextStyle(color: Colors.white)),
                      Text('TDEE（维持能量）≈ ${tdee!.round()} kcal', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('示例宏量营养分配：', style: TextStyle(color: Colors.white)),
                      Text('• 40% 碳水：≈ ${(tdee!*0.4/4).round()} g', style: const TextStyle(color: Colors.white70)),
                      Text('• 30% 蛋白：≈ ${(tdee!*0.3/4).round()} g', style: const TextStyle(color: Colors.white70)),
                      Text('• 30% 脂肪：≈ ${(tdee!*0.3/9).round()} g', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      const Text('注意：不作为医疗建议；如需个性化方案，请咨询专业人士。', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
        IconButton(onPressed: () => onChanged(value-1), icon: const Icon(Icons.remove, color: Colors.white70)),
        Text(value.toString(), style: const TextStyle(color: Colors.white)),
        IconButton(onPressed: () => onChanged(value+1), icon: const Icon(Icons.add, color: Colors.white70)),
      ],
    );
  }
}

