import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMIRecord {
  final int height;
  final int weight;
  final String gender;
  final double bmi;
  final DateTime time;
  final String? activity; // sedentary | light | active

  BMIRecord({
    required this.height,
    required this.weight,
    required this.gender,
    required this.bmi,
    required this.time,
    this.activity,
  });

  // 将对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'gender': gender,
      'bmi': bmi,
      'time': time.toIso8601String(),
      'activity': activity,
    };
  }

  // 从JSON创建对象
  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      height: json['height'],
      weight: json['weight'],
      gender: json['gender'],
      bmi: json['bmi'],
      time: DateTime.parse(json['time']),
      activity: json['activity'],
    );
  }
}

class BMIHistoryManager {
  static const String _storageKey = 'bmi_history';

  // 保存BMI记录
  static Future<void> saveBMIRecord(BMIRecord record) async {
    final prefs = await SharedPreferences.getInstance();

    // 获取现有记录
    List<BMIRecord> records = await getBMIHistory();

    // 添加新记录
    records.add(record);

    // 将记录列表转换为JSON字符串列表
    List<String> jsonList =
        records.map((record) => jsonEncode(record.toJson())).toList();

    // 保存到SharedPreferences
    await prefs.setStringList(_storageKey, jsonList);
  }

  // 用整体列表覆盖保存（用于编辑/删除）
  static Future<void> setBMIHistory(List<BMIRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // 获取所有BMI历史记录
  static Future<List<BMIRecord>> getBMIHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // 获取JSON字符串列表
    List<String>? jsonList = prefs.getStringList(_storageKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    // 将JSON字符串列表转换为BMIRecord对象列表
    return jsonList.map((jsonString) {
      Map<String, dynamic> json = jsonDecode(jsonString);
      return BMIRecord.fromJson(json);
    }).toList();
  }

  // 清除所有历史记录
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

class Calculate {
  Calculate({required this.height, required this.weight, this.gender = 'male'});
  final int height;
  final int weight;
  final String gender;
  double _bmi = 0;
  String result() {
    _bmi = (weight / pow(height / 100, 2));
    return _bmi.toStringAsFixed(1);
  }

  // 保存当前BMI计算结果到历史记录
  Future<void> saveToHistory() async {
    BMIRecord record = BMIRecord(
      height: height,
      weight: weight,
      gender: gender,
      bmi: _bmi,
      time: DateTime.now(),
    );

    await BMIHistoryManager.saveBMIRecord(record);
  }

  String getText() {
    // 使用中国成人BMI分级
    if (_bmi >= 28.0) return 'OBESE';
    if (_bmi >= 24.0) return 'OVERWEIGHT';
    if (_bmi >= 18.5) return 'NORMAL';
    return 'UNDERWEIGHT';
  }

  String getAdvise() {
    // 简化建议，后续可根据年龄/性别/活动水平进一步个性化
    if (_bmi >= 28.0) {
      return 'Your BMI is in the obese range. Gradually reduce energy intake and increase moderate-intensity exercise (e.g., brisk walking, cycling). Aim to lose no more than 0.5 kg per week and consult a doctor for personalized advice.';
    } else if (_bmi >= 24.0) {
      return 'Your BMI is in the overweight range. Reduce high energy density foods (sugary drinks, fried foods), and do at least 150 minutes of aerobic exercise per week along with strength training.';
    } else if (_bmi >= 18.5) {
      return 'Your BMI is in the normal range. Maintain a balanced diet and regular exercise; prioritize vegetables, whole grains, and quality protein.';
    } else {
      return 'Your BMI is low. Increase energy and protein intake appropriately, focus on strength training and adequate rest. If it remains low, please consult a doctor.';
    }
  }

  Color getTextColor() {
    if (_bmi >= 24.0 || _bmi < 18.5) {
      return Colors.deepOrangeAccent;
    }
    return const Color(0xFF24D876);
  }
}
