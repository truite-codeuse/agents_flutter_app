import "dart:collection";

class Fact {
  String name;
  bool state;

  Fact(String name) : name = name.toLowerCase().replaceAll(RegExp(r' '), '_'), state = false;
  Fact.full(String name, this.state) : name = name.toLowerCase().replaceAll(RegExp(r' '), '_');

  @override
  String toString() {
    return name;
  }
  
}

class LogicModule {
  final Map<Fact, (Function, List<dynamic>)> facts = HashMap();

  void addFact(Fact fact, Function func, List<dynamic> args) {
    facts[fact] = (func, args);
  }

  List<Fact> resolve() {
    List<Fact> res = <Fact>[];
    facts.forEach((key, value) {
      if (value.$2.isNotEmpty) {
        key.state = Function.apply(value.$1, value.$2);
        res.add(key);
      }
      else {
        key.state = value.$1();
        res.add(key);
      }
    });
    return res;
  }
}