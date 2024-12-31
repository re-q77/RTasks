// ignore_for_file: file_names, unused_import

import 'dart:io';

class TaskModel {
  final String title;
  final String content;
  final String date;
  final String category;

  TaskModel({
    required this.title,
    required this.content,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'category': category,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
