import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/common/services/timer-formatter.service.dart';

class TimerText extends StatefulWidget {
  TimerText({this.stopwatch});
  final Stopwatch stopwatch;
  TimerTextState createState() => TimerTextState(stopwatch: stopwatch);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;
  TimerTextState({this.stopwatch}) {
    timer = Timer.periodic(Duration(milliseconds: 30), callback);
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        TimerTextFormatter.format(stopwatch.elapsedMilliseconds);
    return Text(formattedTime,
        style: TextStyle(fontSize: 40.0, fontFamily: "Open Sans"));
  }
}
