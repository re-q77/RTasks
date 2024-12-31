// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:r_tasks/HomeTasks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool _isMoved = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    Launched();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isMoved = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showText = true;
        });

        Future.delayed(Duration(seconds: 9), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ViewTasks()),
            (route) => false,
          );
        });
      });
    });
  }

  Future<void> Launched() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A237E),
                    Color(0xFF8A4C93),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _showText,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        ScaleAnimatedText(
                          'مرحباً بك في ',
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontFamily: 'sevi',
                          ),
                        ),
                        ColorizeAnimatedText(
                          'تطبيق المهام اليومية',
                          textStyle: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Lateef'),
                          colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                          ],
                        ),
                        FadeAnimatedText(
                          'رتب مهـامك الآن',
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Lateef',
                          ),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: screenHeight * 0.015,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Redwan ',
                          style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontFamily: 'sevi',
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text('Alqahtani',
                            style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontFamily: 'sevie',
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            top: _isMoved ? 90 : 500,
            right: 40,
            child: Image.asset(
              'images/rt2.png',
              width: screenWidth * 0.75,
              height: screenHeight * 0.39,
            ),
          ),
        ],
      ),
    );
  }
}
