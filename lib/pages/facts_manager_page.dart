import 'package:agents_flutter_app/logic/logic.dart';
import 'package:flutter/material.dart';
import 'package:agents_flutter_app/logic/data_handling.dart';

/// Page used to manage the facts created by the user
class FactsManagerPage extends StatefulWidget {
  final ModuleManager manager;
  late Map<String, LogicModule> modules; // Available modules
  late Map<String, LogicAction> functions; // Available actions
  late String currModule; // The selected module
  late String currFunction; // The selected function

  FactsManagerPage({super.key, required this.manager}) {
    modules = manager.getAllModules();
    currModule = modules.keys.first;
    functions = modules[currModule]!.getAvailableFunctions();
    currFunction = functions.keys.first;
  }

  @override
  State<FactsManagerPage> createState() => _FactsManagerPageState();
}

class _FactsManagerPageState extends State<FactsManagerPage> {
  String factName = "";
  Map<SymbolType, dynamic> vars = {}; // The action function's parameters
  

  final TextEditingController _controller = TextEditingController();

  /// Function that returns the right widget for the right type of data
  /// String typeName : the type as a string
  /// returns Widget : the widget that will be used in the UI
  Widget getInputForType(String typeName) {
    if (typeName == "TimeOfDay") {
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              TimeOfDay? time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 0, minute: 0));
              setState(() {
                vars[SymbolType(const Symbol('dt'), "TimeOfDay")] = time;
              });
            },
            child: const Text('Choose time'),
          ),
          (vars[SymbolType(const Symbol('dt'), 'TimeOfDay')] == null) ? const Text('No time chosen') : Text('${vars[SymbolType(const Symbol('dt'), 'TimeOfDay')]!.hour}:${vars[SymbolType(const Symbol('dt'), 'TimeOfDay')]!.minute}')
        ],
      );
    }
    return const Text('No type available');
  }

  /// Returns all the widgets needed for the parameters of a function
  /// Map<SymbolType, dynamic> args : the parameters for a function
  /// returns List<Widget> : the right widgets for these parameters
  List<Widget> getInputForFunction(Map<SymbolType, dynamic> args) {
    List<Widget> res = <Widget>[];
    vars = args;
    for (SymbolType arg in args.keys) {
      res.add(getInputForType(arg.type));
    }
    return res;
  }

  /// Checks if the fact name is not empty
  /// returns bool : is the fact name empty
  bool checkInputs() {
    return factName.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter fact's name",
                  ),
                  onChanged: (String newText) {
                    setState(() {
                      factName = Fact.parseName(newText);
                      _controller.value = _controller.value.copyWith(
                        text: factName,
                        selection: TextSelection.collapsed(offset: factName.length),
                      );
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Name parsed",
                  ),
                  controller: _controller,
                  readOnly: true,
                  maxLines: 1,
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Module :'),
                DropdownButton<String>(
                  value: widget.currModule,
                  items: widget.modules.keys.map<DropdownMenuItem<String>>((String m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    );
                  }).toList(),
                  onChanged: (String? m) {
                    setState(() {
                      widget.currModule = m!;
                    });
                  }
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Function :'),
                DropdownButton<String>(
                  key: UniqueKey(),
                  value: widget.currFunction,
                  items: widget.functions.keys.map<DropdownMenuItem<String>>((String f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(f),
                    );
                  }).toList(),
                  onChanged: (String? f) {
                    setState(() {
                      widget.currFunction = f!;
                      print(widget.currFunction);
                    });
                  }
                ),
              ],
            ),
            ...getInputForFunction(widget.functions[widget.currFunction]!.arguments),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    if (checkInputs()) {
                      widget.manager.modules[widget.currModule]!.addFact(Fact(factName), LogicAction(widget.functions[widget.currFunction]!.function, Map<SymbolType, dynamic>.from(vars)));
                      widget.modules = widget.manager.getAllModules();
                      List<Fact> facts = widget.manager.resolveAll();
                      for (Fact f in facts) {
                        print('${f.name} : ${f.state.toString()}');
                      }
                      DataHandler().save(widget.manager);
                      setState(() {
                        factName = "";
                        _controller.value = _controller.value.copyWith(
                          text: factName,
                          selection: TextSelection.collapsed(offset: factName.length),
                        );
                      });
                    }
                  },
                  child: const Text('Add fact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}