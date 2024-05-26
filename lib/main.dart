import 'package:agents_flutter_app/logic/logic.dart';
import 'package:agents_flutter_app/pages/rules_manager_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/time_page.dart';
import 'pages/facts_manager_page.dart';
import 'logic/data_handling.dart';


void main() {
  runApp(const MyApp());
}

/// Main thread of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => TimePageState(),
      child: MaterialApp(
        title: 'IntellAgent',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainPageStructure(),
      ),
    );
  }
}

class MainPageStructure extends StatefulWidget {
  
  const MainPageStructure({super.key});

  @override
  State<MainPageStructure> createState() => _MainPageStructureState();
}

class _MainPageStructureState extends State<MainPageStructure> {
  int currentPageIndex = 0;
  late ModuleManager manager;

  _MainPageStructureState();

  @override
  void initState() {
    // Files init and queries to Gorgias to get the rules
    var db = DataHandler();
    var pl = PrologHandler();
    manager = ModuleManager();
    db.loadFromDatabase().then((m) {
      manager = m;
      pl.getRules(manager).then((rules) {
        manager.rules = rules;
        pl.saveRules(m);
        print('Manager loaded !');
        print(manager.resolveAll());
        print(manager.rules);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add),
              label: 'Add Fact',
            ),
            NavigationDestination(
              icon: Icon(Icons.add),
              label: 'Manage Rules',
            ),
          ],
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          animationDuration: const Duration(milliseconds: 1000),
          backgroundColor: Colors.white,
        ),
        body: [
          HomePage(manager:manager),
          FactsManagerPage(manager: manager),
          RulesManagerPage(manager: manager),
        ][currentPageIndex],
      );
  }
}
