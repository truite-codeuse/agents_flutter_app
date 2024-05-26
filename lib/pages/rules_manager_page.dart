import 'package:agents_flutter_app/logic/data_handling.dart';
import 'package:agents_flutter_app/logic/logic.dart';
import 'package:flutter/material.dart';

/// Page used to manage the rules created by the user
class RulesManagerPage extends StatefulWidget {
  final ModuleManager manager;
  late List<Fact> userFacts; // All the facts created by the user
  late Map<String, LogicRule> rules;
  late Map<Fact, bool> isChecked; // Will the fact be in the rule's body ?

  RulesManagerPage({super.key, required this.manager}) {
    userFacts = manager.resolveAll();
    rules = manager.rules;
    isChecked = {for (Fact f in userFacts) f : false};
  }

  @override
  State<RulesManagerPage> createState() => _RulesManagerPageState();
}

class _RulesManagerPageState extends State<RulesManagerPage> {

  String ruleName = "";
  String prefName = "";
  bool allow = false;
  bool chosen = true;
  final TextEditingController _controller = TextEditingController();
  
  /// Checks if the rule doesn't have an empty name and if this name is unique
  /// Adds the new rule to the app (and checks for conflicts)
  void checkValidity() async {
    if (ruleName != "" && !widget.rules.keys.contains(ruleName)) {
      final List<Fact> facts = [
        for (Fact f in widget.isChecked.keys)
          if (widget.isChecked[f]!)
            f
      ];
      final Outcome outcome = allow ? Outcome.allow : Outcome.deny;
      LogicRule l = LogicRule(ruleName, facts, outcome);
      List<LogicRule> newRules = await addRule(l);
      if (newRules.isNotEmpty) {
        for (LogicRule l in newRules){
          widget.manager.addRule(l);
        }
        setState(() {
          widget.rules = widget.manager.rules;
        });
        PrologHandler().saveRules(widget.manager);
      }
      
    }
  }

  /// Search for conflicts and returns them (if the user clicks outside of the modal then it returns an empty list)
  /// LogicRule toAdd : the rule to add
  /// return Future<List<LogicRule>> : the rule to add and all the priority rules to solve conflicts
  Future<List<LogicRule>> addRule(LogicRule toAdd) async {
    List<LogicRule> addings = [toAdd];
    for (LogicRule r in widget.rules.values) {
      if (toAdd.preferenceOrder() == r.preferenceOrder() && toAdd.outcome != r.outcome) {
        LogicRule? preference = await askPreference(context, toAdd, r);
        if (preference != null) {
          var newadds = await addRule(preference);
          addings.addAll(newadds);
        }
        else {
          addings = [];
          return addings;
        }
      }
    }
    return addings;
  }

  /// Modal builder to ask the preference of the user
  Future<LogicRule?> askPreference(BuildContext context, LogicRule r1, LogicRule r2) {
    return showDialog<LogicRule>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Choose a preference'),
              content: Scaffold(
                body: Column(
                  children: [
                    const Text(
                      'Please choose between these rules',
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(r1.identifier),
                        Checkbox(
                          value: chosen,
                          onChanged: (value) {
                            setState(() {
                              chosen = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(r2.identifier),
                        Checkbox(
                          value: !chosen,
                          onChanged: (value) {
                            setState(() {
                              chosen = !value!;
                            });
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter prefrence's name",
                          ),
                          onChanged: (String newText) {
                            setState(() {
                              prefName = Fact.parseName(newText);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Confirm'),
                  onPressed: () {
                    String name = prefName != "" ? prefName : '${r1.identifier}_${r2.identifier}';
                    LogicRule pref = LogicRule.pref(name, r1, r2);
                    Navigator.of(context).pop(pref);
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Rules"),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.rules.keys.length,
                  itemBuilder: (context, index) {
                    return Text(widget.rules[widget.rules.keys.toList()[index]].toString());
                  },
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter rule's name",
                    ),
                    onChanged: (String newText) {
                      setState(() {
                        ruleName = Fact.parseName(newText);
                        _controller.value = _controller.value.copyWith(
                          text: ruleName,
                          selection: TextSelection.collapsed(offset: ruleName.length),
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
              for (Fact f in widget.userFacts)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(f.name),
                    Checkbox(
                      tristate: false,
                      value: widget.isChecked[f],
                      onChanged: (value) {
                        setState(() {
                          widget.isChecked[f] = value!;
                        });
                      }
                    ),
                  ],
                ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text("Allow"),
                    Checkbox(
                    tristate: false,
                    value: allow,
                    onChanged: (value) {
                      setState(() {
                        allow = value!;
                      });
                    }
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: checkValidity,
                    child: const Text('Add rule'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
