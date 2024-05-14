import 'dart:async';
import 'package:agents_flutter_app/logic.dart';
import 'package:agents_flutter_app/time_module.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agents_flutter_app/gorgias_api.dart';

class TimePage extends StatelessWidget {
  final DateTime after = DateTime.now().add(const Duration(minutes: 1));
  final DateTime before = DateTime.now().subtract(const Duration(minutes: 1));

  TimePage({super.key});
  

  void gorgiasCall() {
    final gorgias = GorgiasAPI();
    gorgias.testGorgias();
  }

  void resolve(TimeModule tm) {
    List<Fact> facts = tm.resolve();
    for (Fact f in facts) {
      print('${f.name} : ${f.state.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var timeState = context.watch<TimePageState>();
    var time = timeState.formattedDate;
    timeState.createTimer();

    TimeModule tm = TimeModule();
    
    Fact f1 = Fact('My First Fact');
    Fact f2 = Fact('My Second FacT');
    tm.addFact(f1, tm.isLessThan, [after]);
    tm.addFact(f2, tm.isLessThan, [before]);

    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Text(time),
            MaterialButton(onPressed: () => gorgiasCall(), child: const Text('Press me'),),
            MaterialButton(onPressed: () => resolve(tm), child: const Text('Time module'),),
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
