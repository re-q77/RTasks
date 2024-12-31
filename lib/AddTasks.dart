// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:r_tasks/TaskModel/TaskModel.dart';

class AddTasks extends StatefulWidget {
  final Function(TaskModel) onTaskAdded;

  AddTasks({required this.onTaskAdded});

  @override
  _AddTasksState createState() => _AddTasksState();
}

class _AddTasksState extends State<AddTasks> {
  final TextEditingController titleCont = TextEditingController();
  final TextEditingController contentCont = TextEditingController();
  String? selectedCategory;
  final List<String> categories = ['العمل', 'الدراسة', 'التسوق', 'أخرى'];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة مهمة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: null,
                minLines: 1,
                controller: titleCont,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.019),
              TextField(
                keyboardType: TextInputType.text,
                maxLines: null,
                minLines: 1,
                controller: contentCont,
                decoration: InputDecoration(
                  labelText: 'المحتوى',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.019),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
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
              SizedBox(height: screenHeight * 0.019),
              Padding(
                padding: const EdgeInsets.only(
                  left: 50,
                ),
                child: Container(
                  width: screenWidth * 0.55,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          topLeft: Radius.circular(40)),
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.green],
                        end: Alignment.bottomRight,
                        begin: Alignment.topLeft,
                      )),
                  child: TextButton(
                    onPressed: () {
                      String title = titleCont.text;
                      String content = contentCont.text;

                      if (title.isNotEmpty &&
                          content.isNotEmpty &&
                          selectedCategory != null) {
                        TaskModel task = TaskModel(
                          title: title,
                          content: content,
                          category: selectedCategory!,
                          date:
                              '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                        );

                        widget.onTaskAdded(task);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يرجى ملء جميع الحقول',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      "إضافة",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'sevi',
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.055),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
