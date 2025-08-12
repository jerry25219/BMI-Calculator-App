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

  BMIRecord({
    required this.height,
    required this.weight,
    required this.gender,
    required this.bmi,
    required this.time,
  });

  // 将对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'gender': gender,
      'bmi': bmi,
      'time': time.toIso8601String(),
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
  Color _textColor = Color(0xFF24D876);
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
    if (_bmi >= 25) {
      return 'OVERWEIGHT';
    } else if (_bmi > 18.5) {
      return 'NORMAL';
    } else {
      return 'UNDERWEIGHT';
    }
  }

  String getAdvise() {
    if (_bmi >= 25) {
      return 'You have a more than normal body weight.\n Try to do more Exercise';
    } else if (_bmi > 18.5) {
      return 'You have a normal body weight.\nGood job!';
    } else {
      return 'You have a lower than normal body weight.\n Try to eat more';
    }
  }

  Color getTextColor() {
    if (_bmi >= 25 || _bmi <= 18.5) {
      return Colors.deepOrangeAccent;
    } else {
      return Color(0xFF24D876);
    }
  }
}
