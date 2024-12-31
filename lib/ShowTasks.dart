// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unused_element, camel_case_types, use_super_parameters

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:r_tasks/TaskModel/TaskModel.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ShowTasks extends StatefulWidget {
  final String initialTitle;
  final String initialContent;
  final String Date;
  final int taskIndex;
  final List<TaskModel> tasks;

  const ShowTasks({
    Key? key,
    required this.initialTitle,
    required this.initialContent,
    required this.Date,
    required this.taskIndex,
    required this.tasks,
  }) : super(key: key);

  @override
  State<ShowTasks> createState() => _ShowTasksState();
}

class _ShowTasksState extends State<ShowTasks> {
  late String currentTitle;
  late String currentContent;
  late String? currentCategory; // التصنيف الحالي
  final TextEditingController titleContro = TextEditingController();
  final TextEditingController contentContro = TextEditingController();
  bool isEditing = false;

  SharedPreferences? prefs;
  bool dark = false;
  final List<String> categories = ['العمل', 'الدراسة', 'التسوق', 'أخرى'];

  Future<void> savDark() async {
    if (prefs != null) {
      prefs!.setBool('daark', dark);
    }
  }

  @override
  void initState() {
    super.initState();
    currentTitle = widget.initialTitle;
    currentContent = widget.initialContent;
    currentCategory = widget.tasks[widget.taskIndex].category;
    titleContro.text = currentTitle;
    contentContro.text = currentContent;
    loadDark();
  }

  Future<void> loadDark() async {
    prefs = await SharedPreferences.getInstance();

    dark = prefs?.getBool('daark') ?? false;
    await savDark();
    setState(() {});
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'tasks',
      jsonEncode(widget.tasks.map((task) => task.toJson()).toList()),
    );
  }

  void _editTask() {
    setState(() {
      currentTitle = titleContro.text;
      currentContent = contentContro.text;

      TaskModel updatedTask = TaskModel(
        title: currentTitle,
        content: currentContent,
        date:
            '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
        category: currentCategory ?? 'أخرى',
      );

      widget.tasks[widget.taskIndex] = updatedTask;

      _saveTasks();

      Navigator.pop(context, updatedTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Card(
          color: Colors.brown,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade600,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.black),
              color: Colors.grey.shade500,
            ),
            alignment: Alignment.center,
            height: screenHeight * 0.075,
            margin: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  currentTitle,
                  style: TextStyle(
                    fontFamily: 'Lateef',
                    fontSize: screenWidth * 0.082,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  maxLines: null,
                                  minLines: 1,
                                  controller: titleContro,
                                  decoration: InputDecoration(
                                    hintText: 'تعديل العنوان',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: contentContro,
                                  maxLines: null,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'تعديل المحتوى',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // اختيار التصنيف
                              DropdownButtonFormField<String>(
                                value: currentCategory,
                                onChanged: (value) {
                                  setState(() {
                                    currentCategory = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'التصنيف',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              Center(
                                child: ElevatedButton(
                                  onPressed: _editTask,
                                  child: const Text('حفظ التعديلات'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    setState(() {
                      isEditing = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: dark ? Colors.black : Colors.yellow.shade100,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  color: Colors.grey.shade600,
                  offset: const Offset(0, 7),
                ),
              ],
              borderRadius: BorderRadius.circular(18),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    currentContent,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontFamily: 'sevi',
                      color: dark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    widget.Date,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontFamily: 'sevi',
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 1,
            child: Switch(
              value: dark,
              onChanged: (val) async {
                setState(() {
                  dark = val;
                });
                await savDark();
              },
            ),
          ),
        ],
      ),
    );
  }
}
