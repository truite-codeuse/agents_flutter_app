import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimePage extends StatelessWidget {
  const TimePage({super.key});

  @override
  Widget build(BuildContext context) {
    var timeState = context.watch<TimePageState>();
    var time = timeState.formattedDate;
    timeState.createTimer();

    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Text(time),
        ],
      ),
    );
  }
}

class TimePageState extends ChangeNotifier {

  var dateFormat = 'dd-MM-yyy – kk:mm:ss';
  late String formattedDate = DateFormat(dateFormat).format(DateTime.now());
  bool created = false;

  void createTimer(){
    if(!created) {
      created = true;
      Timer.periodic(const Duration(seconds: 1), (timer) => updateClock());
    }
  }

  void updateClock() {
    formattedDate = DateFormat('dd-MM-yyy – kk:mm:ss').format(DateTime.now());
    notifyListeners();
  }
}
