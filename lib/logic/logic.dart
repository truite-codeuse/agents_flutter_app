import "dart:core";
import "dart:math";
import "package:agents_flutter_app/logic/modules/time_module.dart";
import "package:flutter/material.dart";

/// The possible decisions of the agent (deny or allow the call)
enum Outcome {
  allow,
  deny
}

/// Represents a rule that will return an outcome if the list of facts is true
class LogicRule {
  late String identifier; // unique id
  // IF RULE IS PRIORITY
  LogicRule? preferred;
  LogicRule? unpreferred;
  // ENDIF RULE IS PRIORITY
  late List<Fact> facts; // body of the rule
  late Outcome outcome; // the decision to take

  LogicRule(this.identifier, this.facts, this.outcome);

  LogicRule.pref(this.identifier, this.preferred, this.unpreferred) {
    outcome = preferred!.outcome;
    facts = preferred!.facts;
  }

  /// When the rule comes from Gorgias
  LogicRule.fromString(String rule, ModuleManager m) {
    List<String> splitted = rule.replaceAll(RegExp(r'^(rule)|\(|\)| |:-|\.|\[\]'), '').split(',');
    identifier = splitted[0];
    outcome = splitted[1] == 'deny' ? Outcome.deny : Outcome.allow;
    List<Fact> facts = [];
    if (splitted.length > 2) {
      var userFacts = m.resolveAll();
      for (int i = 2; i < splitted.length; i++) {
        facts.add(userFacts.where((f) => f.name == splitted[i]).first);
      }
    }
    preferred = null;
    unpreferred = null;
    this.facts = facts;
  }

  /// When the rule comes from Gorgias and is a priority rule
  LogicRule.fromStringPref(String rule, ModuleManager m) {
    List<String> splitted = rule.replaceAll(RegExp(r'^(rule)|(prefer)|\(|\)| |:-|\.|\[\]'), '').split(',');
    identifier = splitted[0];
    LogicRule r1 = m.rules[splitted[1]]!;
    LogicRule r2 = m.rules[splitted[2]]!;
    preferred = r1;
    unpreferred = r2;
    outcome = r1.outcome;
    facts = r1.facts;
  }

  /// True if the rule does not have any child
  bool isPreference() {
    return (preferred != null) && (unpreferred != null);
  }

  /// Returns the preference order of the rule
  /// 0 if the rule is not a preference
  /// The max of the preference order of its childs + 1 otherwise
  int preferenceOrder() {
    if (!isPreference()) {
      return 0;
    }
    else {
      int i = preferred!.preferenceOrder();
      int j = unpreferred!.preferenceOrder();
      return max(i, j) + 1;
    }
  }

  @override
  String toString() {
    final factsString = facts.map((e) => e.name).join(',');
    if (isPreference()) {
      return "rule($identifier, prefer(${preferred!.identifier}, ${unpreferred!.identifier}), []) :- $factsString.";
    }
    else {
      return "rule($identifier, ${outcome.name}, []) :- $factsString.";
    }
  }
}

/// Extension of the == for TimeOfDay type
extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}

/// Factory pattern for module instanciation
class Factory {
  static final factories = <String, Function>{
    "TimeModule": () => TimeModule()
  };

  static make(String t) {
    return factories[t]!();
  }
}

class StringToType {
  static Type convert(String str) {
    switch (str) {
      case 'String':
        return String;
      case 'int':
        return int;
      case 'DateTime':
        return DateTime;
      case 'TimeOfDay':
        return TimeOfDay;
      case 'TimeModule':
        return TimeModule;
      default:
        return Object;
    }
  }
}

class ValueToString {
  static String convert(dynamic d, String type) {
    switch (StringToType.convert(type)) {
      case String:
        return d;
      case int:
        return d.toString();
      case DateTime:
        return d.toString();
      case TimeOfDay:
        return '${d.hour}:${d.minute}';
      default:
        return 'Object';
    }
  }
}

class StringToValue {
  static dynamic convert(String d, String type) {
    switch (StringToType.convert(type)) {
      case String:
        return d;
      case int:
        return int.parse(d);
      case DateTime:
        return DateTime.parse(d);
      case TimeOfDay:
        return TimeOfDay(hour:int.parse(d.split(':')[0]), minute:int.parse(d.split(':')[1]));
      default:
        return Object();
    }
  }
}

/// Represents an action (abstract function)
class LogicAction {
  final Function function; // A function that returns a boolean
  final Map<SymbolType, dynamic> arguments; // The parameters of the function

  LogicAction(this.function, this.arguments);

  Function getFunction() {
    return function;
  }

  Map<SymbolType, dynamic> getArguments() {
    return arguments;
  }

  /// String representation of the function's name
  String getFunctionName() {
    return function.toString().replaceFirstMapped(RegExp("^.*?'(.*)'.*\$"), (match) => match[1]!);
  }

  /// From action to JSON
  Map<String, dynamic> serialize() {
    Map<String, dynamic> funcJson = {};
    funcJson["functionName"] = getFunctionName();
    funcJson["args"] = [];
    for (SymbolType s in arguments.keys) {
      funcJson["args"].add({"symboltype": {"symbol":s.symbol.toString().replaceAll("\\", '').replaceFirstMapped(RegExp("^.*?\"(.*)\".*\$"), (match) => match[1]!), "type":s.type}, "value":ValueToString.convert(arguments[s], s.type)});
    }
    return funcJson;
  }
}

/// Represents a parameter in a function
class SymbolType {
  final Symbol symbol; // The name if the parameter
  final String type; // Its value

  SymbolType(this.symbol, this.type);

  @override
  String toString() {
    return '${symbol.toString()} ($type)';
  }

  @override
  int get hashCode => (symbol.toString() + type).hashCode;

  @override
  bool operator ==(dynamic other) {
    return (symbol.toString() == other.symbol.toString()) && (type == other.type);
  }
}

/// The representation of a fact
class Fact {
  String name; // Unique name (id)
  bool state; // Its state given by the execution of the LogicAction associated with it

  Fact(String name) : name = parseName(name), state = false; 
  Fact.full(String name, this.state) : name = parseName(name);

  /// No spaces in the name (replaced by underscores)
  static String parseName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r' '), '_');
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(dynamic other) {
    return (name == other.name);
  }
}

/// Abstract representation of a module
abstract class LogicModule {
  final Map<Fact, LogicAction> userFacts = {}; // Facts from the user that are linked with the module (they use actions from this module)
  final Map<String, LogicAction> availableFunctions = {}; // All the actions available to the user

  void addFact(Fact fact, LogicAction action) {
    userFacts.putIfAbsent(fact, () => action);
  }

  Map<Fact, LogicAction> getFacts() {
    return userFacts;
  }

  Map<Symbol, dynamic> getParameters(Map<SymbolType, dynamic> arguments) {
    return arguments.map((k,v) => MapEntry(k.symbol, v));
  }

  /// Computes and sets the state of all the facts contained in this module
  List<Fact> resolve() {
    List<Fact> res = <Fact>[];
    for (Fact key in userFacts.keys) {
      var parameters = getParameters(userFacts[key]!.arguments);
      print('Fact : $key, ${userFacts[key]!.serialize()}');
      key.state = Function.apply(userFacts[key]!.function, [], parameters);
      res.add(key);
    }
    return res;
  }

  Map<String, LogicAction> getAvailableFunctions() {
    return availableFunctions;
  }

  String getType() {
    return toString();
  }

  @override
  String toString() {
    return runtimeType.toString();
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(covariant other) {
    return hashCode == other.hashCode;
  }

  /// Module to JSON
  Map<String, dynamic> serialize() {
    Map<String, dynamic> json = {"facts": []};
    for (Fact f in userFacts.keys) {
      json["facts"].add({"name":f.name, "action":userFacts[f]!.serialize()});
    }
    return json;
  }
}

/// Manager of all the resources (modules and rules)
class ModuleManager {
  Map<String, LogicModule> modules = {}; // The modules available
  Map<String, LogicRule> rules = {}; // The rules created by the user

  ModuleManager() {
    TimeModule tm = TimeModule();
    addModule("TimeModule", tm);
  }

  ModuleManager.fromJson(dynamic jsonFile) {
    var jmodules = jsonFile["manager"];
    for (var module in jmodules) {
      var m = Factory.make(module["module"]);
      for (var fact in module["facts"]) {
        Fact f = Fact(fact["name"]);
        var args = fact["action"]["args"];
        Map<SymbolType, dynamic> arguments = {};
        for (var arg in args) {
          SymbolType symb = SymbolType(Symbol(arg["symboltype"]["symbol"]), arg["symboltype"]["type"]);
          arguments[symb] = StringToValue.convert(arg["value"], symb.type);
        }
        LogicAction action = LogicAction(m.availableFunctions[fact["action"]["functionName"]].getFunction(), arguments);
        m.addFact(f, action);
      }
      addModule(module["module"], m);
    }
  }

  LogicModule? getModule(String moduleName) {
    return modules[moduleName];
  }

  Map<String, LogicModule> getAllModules() {
    return modules;
  }

  void addModule(String moduleName, LogicModule m) {
    modules.putIfAbsent(moduleName, () => m);
  }

  void removeModule(String moduleName) {
    modules.remove(moduleName);
  }

  void addRule(LogicRule r) {
    rules.putIfAbsent(r.identifier, () => r);
  }

  void removeRule(String r) {
    rules.remove(r);
  }

  /// Computes and sets the state of the facts in a particular module
  List<Fact> resolve(String moduleName) {
    List<Fact> res = <Fact>[];
    res.addAll(getModule(moduleName)!.resolve());
    return res;
  }

  /// Computes and sets the state of the facts in all the modules
  List<Fact> resolveAll() {
    List<Fact> res = <Fact>[];
    for (String moduleName in modules.keys) {
      res.addAll(modules[moduleName]!.resolve());
    }
    return res;
  }

  /// Manager to JSON
  Map<String, dynamic> serialize() {
    Map<String, dynamic> json = {"manager":[]};
    for (String moduleName in modules.keys) {

      json["manager"].add({"module": moduleName, "facts": modules[moduleName]!.serialize()["facts"]});
    }
    return json;
  }
}