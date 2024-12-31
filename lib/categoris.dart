// ignore_for_file: prefer_const_constructors, camel_case_types, unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:r_tasks/ShowTasks.dart';
import 'package:r_tasks/TaskModel/TaskModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category>
    with SingleTickerProviderStateMixin {
  List<TaskModel> tasks = [];
  TabController? tabContr;
  final List<String> _categories = ['العمل', 'الدراسة', 'التسوق', 'أخرى'];

  @override
  void initState() {
    super.initState();
    tabContr = TabController(length: _categories.length, vsync: this);
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      setState(() {
        tasks = (jsonDecode(tasksData) as List)
            .map((task) => TaskModel.fromJson(task))
            .toList();
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'tasks',
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("قائمة التصنيفات"),
        centerTitle: true,
        bottom: TabBar(
          controller: tabContr,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: TabBarView(
        controller: tabContr,
        children: _categories.map((category) {
          List<TaskModel> categoryTasks =
              tasks.where((task) => task.category == category).toList();

          return ListView.builder(
            itemCount: categoryTasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(categoryTasks[index].title),
                subtitle: Text(categoryTasks[index].content),
                trailing: Text(categoryTasks[index].date),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowTasks(
                                initialTitle: categoryTasks[index].title,
                                initialContent: categoryTasks[index].content,
                                taskIndex: index,
                                tasks: tasks,
                                Date: categoryTasks[index].date,
                              )));
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
