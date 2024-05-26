import "package:agents_flutter_app/logic/logic.dart";
import "package:flutter/material.dart";

/// Extension of a LogicModule, works with time
class TimeModule extends LogicModule {

  TimeModule() {
    availableFunctions['isLessThan'] = LogicAction(isLessThan,{SymbolType(const Symbol('dt'), 'TimeOfDay'): const TimeOfDay(hour: 0, minute: 0)});
    availableFunctions['isGreaterThan'] = LogicAction(isGreaterThan,{SymbolType(const Symbol('dt'), 'TimeOfDay'): const TimeOfDay(hour: 0, minute: 0)});
  }

  TimeOfDay dt = TimeOfDay.fromDateTime(DateTime.now());

  /// If dt < current time then true
  bool isLessThan({TimeOfDay dt = const TimeOfDay(hour: 0, minute: 0)}) {
    this.dt = TimeOfDay.fromDateTime(DateTime.now());
    return this.dt.compareTo(dt) < 0;
  }

  /// If dt > current time then true
  bool isGreaterThan({TimeOfDay dt = const TimeOfDay(hour: 0, minute: 0)}) {
    this.dt = TimeOfDay.fromDateTime(DateTime.now());
    return this.dt.compareTo(dt) >= 0;
  }
}