// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, camel_case_types

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:r_tasks/TaskModel/TaskModel.dart';

class fi_chart extends StatelessWidget {
  final List<TaskModel> tasks;

  fi_chart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    Map<String, int> taskCategory = {};
    for (var task in tasks) {
      taskCategory[task.category] = (taskCategory[task.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("إحصائيات المهام"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PieChart(
          PieChartData(
            sections: taskCategory.entries.map((entry) {
              return PieChartSectionData(
                title: entry.key,
                value: entry.value.toDouble(),
                color: _getCategoryColor(entry.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'العمل':
        return Colors.blue;
      case 'الدراسة':
        return Colors.green;
      case 'التسوق':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
