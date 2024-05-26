import 'dart:async';
import 'package:agents_flutter_app/logic/logic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agents_flutter_app/logic/gorgias_api.dart';

/// THIS PAGE IS NOT USED IN THE PROJECT
/// IT WAS ONLY A TEST PAGE FOR THE TIME MODULE

class TimePage extends StatelessWidget {
  final ModuleManager manager;
  const TimePage({super.key, required this.manager});
  

  void gorgiasCall() {
    final gorgias = GorgiasAPI();
  }

  void resolve() {
    List<Fact> facts = manager.resolveAll();
    for (Fact f in facts) {
      print('${f.name} : ${f.state.toString()}');
    }
  }

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
            MaterialButton(onPressed: () => gorgiasCall(), child: const Text('Press me'),),
            MaterialButton(onPressed: () => resolve(), child: const Text('Time module'),),
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
