import "package:agents_flutter_app/logic.dart";

class TimeModule extends LogicModule {
  DateTime dt = DateTime.now();

  bool isLessThan(DateTime dt) {
    this.dt = DateTime.now();
    print(this.dt.toString());
    print(dt.toString());
    return this.dt.compareTo(dt) < 0;
  }

  bool isGreaterThan(DateTime dt) {
    this.dt = DateTime.now();
    return this.dt.compareTo(dt) >= 0;
  }
}