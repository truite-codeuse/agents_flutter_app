import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'time_page.dart';
import 'geolocation_page.dart';

void main() {
  runApp(const MyApp());
}

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
              icon: Icon(Icons.access_time),
              label: 'Time',
            ),
            NavigationDestination(
              icon: Icon(Icons.gps_fixed),
              label: 'GPS',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
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
          const HomePage(),
          const TimePage(),
          const GeolocationPage(), // Geolocation module
          const Placeholder(), // Calendar module
        ][currentPageIndex],// const MainPageStructure(title: 'The IntellAgent app !'),
      );
  }
}
