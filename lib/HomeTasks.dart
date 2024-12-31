// ignore_for_file: prefer_const_constructors, file_names, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, non_constant_identifier_names, avoid_types_as_parameter_names, no_leading_underscores_for_local_identifiers, unused_element, unused_import, sized_box_for_whitespace, prefer_conditional_assignment, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:r_tasks/AddTasks.dart';
import 'package:r_tasks/TaskModel/TaskModel.dart';
import 'package:r_tasks/ShowTasks.dart';
import 'package:r_tasks/categoris.dart';
import 'package:r_tasks/fi_chart.dart';
import 'package:r_tasks/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ViewTasks extends StatefulWidget {
  const ViewTasks({
    super.key,
  });
  @override
  _ViewTasksState createState() => _ViewTasksState();
}

class _ViewTasksState extends State<ViewTasks>
    with SingleTickerProviderStateMixin {
  List<TaskModel> tasks = [];
  List<bool> selectedTasks = [];
  bool showCheckbox = false;
  DateTime? firstTaskTime;
  int Last12Hours = 0;
  SharedPreferences? prefs;
  bool dark = false;

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();

    dark = prefs?.getBool('dark') ?? false;

    String? firstTime = prefs?.getString('firstTaskTime');
    if (firstTime != null) {
      firstTaskTime = DateTime.parse(firstTime);
    }

    Last12Hours = prefs?.getInt('Last12Hours') ?? 0;

    if (firstTaskTime != null &&
        DateTime.now().difference(firstTaskTime!).inHours >= 12) {
      firstTaskTime = null;
      Last12Hours = 0;
      await savePreferences();
    }

    setState(() {});
  }

  Future<void> savePreferences() async {
    if (prefs != null) {
      if (firstTaskTime != null) {
        prefs!.setString('firstTaskTime', firstTaskTime!.toIso8601String());
      } else {
        prefs!.remove('firstTaskTime');
      }

      prefs!.setInt('Last12Hours', Last12Hours);

      // حفظ الوضع الداكن
      prefs!.setBool('dark', dark);
    }
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      setState(() {
        tasks = (jsonDecode(tasksData) as List)
            .map((task) => TaskModel.fromJson(task))
            .toList();
        selectedTasks = List.generate(tasks.length, (_) => false);
      });
    } else {
      setState(() {
        selectedTasks = [];
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

  String? selectedCategory;

  void addTask(TaskModel task) {
    setState(() {
      tasks.add(task);
      selectedTasks.add(false);

      if (firstTaskTime == null) {
        firstTaskTime = DateTime.now();
      }

      if (firstTaskTime != null &&
          DateTime.now().difference(firstTaskTime!).inHours < 12) {
        Last12Hours++;
      } else {
        firstTaskTime = DateTime.now();
        Last12Hours = 1;
      }

      savePreferences();
    });

    saveTasks();
  }

  void deleteSelectedTasks() {
    setState(() {
      tasks =
          tasks.where((task) => !selectedTasks[tasks.indexOf(task)]).toList();

      selectedTasks = List.generate(tasks.length, (_) => false);
      showCheckbox = false;
    });
    saveTasks();
  }

  void editTask(
      int index, String newTitle, String newContent, String? newCategory) {
    setState(() {
      tasks[index] = TaskModel(
        title: newTitle,
        content: newContent,
        date: tasks[index].date,
        category: newCategory ?? tasks[index].category,
      );
    });
    saveTasks();
  }

  int getSelected() {
    return selectedTasks.where((selected) => selected).length;
  }

  void showEdit(int index) {
    String newTitle = tasks[index].title;
    String newContent = tasks[index].content;
    String? newCategory = tasks[index].category;

    final List<String> categories = ['العمل', 'الدراسة', 'التسوق', 'أخرى'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تعديل المهمة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "العنوان"),
                onChanged: (value) => newTitle = value,
                controller: TextEditingController(text: tasks[index].title),
              ),
              TextField(
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(labelText: "الوصف"),
                onChanged: (value) => newContent = value,
                controller: TextEditingController(text: tasks[index].content),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              DropdownButtonFormField<String>(
                value: newCategory,
                onChanged: (value) {
                  newCategory = value;
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                editTask(index, newTitle, newContent, newCategory);
                Navigator.pop(context);
              },
              child: Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> taskColors = [
      Colors.blue.shade100,
      Colors.green.shade200,
      Colors.amber.shade100,
      Colors.red.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
    ];

    final backgroundColor = dark ? Colors.black : Colors.grey.shade100;
    final textColor = dark ? Colors.white : Colors.black;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            bottom: showCheckbox
                ? Tab(
                    child: Container(
                      width: screenWidth * 0.048,
                      child: CircleAvatar(
                        backgroundColor: Colors.yellow,
                        child: Text('${getSelected()}'),
                      ),
                    ),
                  )
                : null,
            leading: IconButton(
              icon: Icon(Icons.category, color: Colors.grey.shade500),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Category(),
                  ),
                );
              },
            ),
            actions: [
              Switch(
                value: dark,
                onChanged: (val) async {
                  setState(() {
                    dark = val;
                  });
                  await savePreferences();
                },
              ),
            ],
            expandedHeight: screenHeight * 0.37,
            pinned: true,
            backgroundColor: dark ? Colors.grey.shade800 : Colors.blue.shade900,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double scrollPercentage =
                    (constraints.maxHeight - kToolbarHeight) /
                        (screenHeight * 0.37 - kToolbarHeight);
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: screenWidth * 0.04,
                    bottom: screenHeight * 0.02,
                  ),
                  title: Row(
                    children: [
                      Opacity(
                        opacity: (1 - scrollPercentage).clamp(0.0, 1.0),
                        child: CircleAvatar(
                          radius: screenWidth * 0.06,
                          backgroundColor: Colors.white,
                          child: Text(
                            '${tasks.length}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Opacity(
                        opacity: (1 - scrollPercentage).clamp(0.0, 1.0),
                        child: Text(
                          'قائمة المهام',
                          style: TextStyle(
                              fontSize: screenWidth * 0.049,
                              color: Colors.white,
                              fontFamily: 'sevi',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  background: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                              backgroundColor: Colors.grey.shade500,
                              child: IconButton(
                                icon: Icon(Icons.bar_chart),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          fi_chart(tasks: tasks),
                                    ),
                                  );
                                },
                              )),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: scrollPercentage.clamp(0.0, 1.0),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.15,
                                  backgroundColor: Colors.white,
                                  child: tasks.isEmpty
                                      ? Text('بدون مهام')
                                      : tasks.length == 1
                                          ? Text('مهمة واحدة')
                                          : Text(
                                              ' ${tasks.length} \n  مهــام ',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: screenWidth * 0.06,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth * 0.14,
                            height: screenHeight * 0.03,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              '$Last12Hours',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: screenHeight * 0.03,
                        left: screenWidth * 0.02,
                        right: screenWidth * 0.02,
                        child: Row(
                          children: [
                            SizedBox(width: screenWidth * 0.00),
                            Expanded(
                                child: Container(
                              width: double.infinity,
                              height: screenHeight * 0.055,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                            )),
                          ],
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.32,
                        left: screenWidth * 0.0,
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth * 0.99,
                              child: TextButton(
                                onPressed: () {
                                  showSearch(
                                    context: context,
                                    delegate: RTasks(seTasks: tasks),
                                  );
                                },
                                child: Text(
                                  'search... 🔎',
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.055),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  color: backgroundColor,
                  child: RefreshIndicator(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: screenHeight * 0.35,
                          crossAxisSpacing: screenWidth * 0.04,
                          mainAxisSpacing: screenHeight * 0.02,
                        ),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShowTasks(
                                            initialTitle: tasks[index].title,
                                            initialContent:
                                                tasks[index].content,
                                            Date: tasks[index].date,
                                            taskIndex: index,
                                            tasks: tasks,
                                          ),
                                        ),
                                      );

                                      if (result != null &&
                                          result is TaskModel) {
                                        setState(() {
                                          tasks[index] = result;
                                          saveTasks();
                                        });
                                      }
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        showCheckbox = true;
                                      });
                                    },
                                    child: Container(
                                      width: screenWidth * 0.5,
                                      height: screenHeight * 0.3,
                                      decoration: BoxDecoration(
                                        color: dark
                                            ? Colors.grey.shade800
                                            : taskColors[
                                                index % taskColors.length],
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade600,
                                            blurRadius: 10,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: screenWidth * 0.1,
                                            backgroundColor: dark
                                                ? Colors.grey.shade700
                                                : Colors.blue.shade700,
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth * 0.06,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.06),
                                          Text(
                                            tasks[index].content,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: textColor,
                                              fontFamily: 'sevi',
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Text(
                                            tasks[index].title,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            tasks[index].date,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (showCheckbox)
                                    Positioned(
                                      top: screenHeight * 0.005,
                                      right: screenWidth * 0.01,
                                      child: Checkbox(
                                        splashRadius: screenWidth * 0.02,
                                        activeColor: Colors.white,
                                        checkColor: Colors.black,
                                        value: selectedTasks[index],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTasks[index] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      onRefresh: () {
                        return loadTasks();
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTasks(
                      onTaskAdded: (task) {
                        addTask(task);
                      },
                    ),
                  ),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
          if (showCheckbox)
            Positioned(
              bottom: 20,
              right: screenWidth * 0.2,
              child: Container(
                width: screenWidth * 0.70,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (getSelected() == 1)
                      IconButton(
                        onPressed: () {
                          int index = selectedTasks.indexOf(true);
                          showEdit(index);
                        },
                        icon: Icon(Icons.edit_note, color: Colors.white),
                      ),
                    IconButton(
                      onPressed: deleteSelectedTasks,
                      icon: Icon(Icons.delete, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showCheckbox = false;
                          selectedTasks =
                              List.generate(tasks.length, (_) => false);
                        });
                      },
                      icon: Icon(Icons.cancel, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RTasks extends SearchDelegate {
  final List<TaskModel> seTasks;
  List filter = [];
  TaskModel? selected;

  RTasks({required this.seTasks});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(selected!.title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowTasks(
              initialTitle: selected!.title,
              initialContent: selected!.content,
              Date: selected!.date,
              taskIndex: seTasks.length,
              tasks: seTasks,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query == '') {
      return ListView.builder(
        itemCount: seTasks.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(seTasks[index].title));
        },
      );
    } else {
      filter = seTasks
          .where((r) => r.title.contains(query) || r.content.contains(query))
          .toList();
      return ListView.builder(
          itemCount: filter.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                query = filter[index].title;
                selected = filter[index];
              },
              title: Text(filter[index].title),
            );
          });
    }
  }
}
