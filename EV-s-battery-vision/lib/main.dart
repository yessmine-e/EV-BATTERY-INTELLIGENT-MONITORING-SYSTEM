import 'package:flutter/material.dart';
import 'trajectory.dart';
import 'battery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Analytics Status',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation>{
  int _selectedIndex = 0;
  final List<Widget> _screens = [BatteryScreen(), Trajectory(),];

  void _onItemTapped(int index) {
    setState(() {_selectedIndex = index;});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
    ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],     // dark grey background
        type: BottomNavigationBarType.fixed,    // ensures backgroundColor is applied on all items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.battery_charging_full),
            label: 'Battery Status',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_road_rounded),
            label: 'Trajectory',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[400],
        unselectedItemColor: Colors.grey[400], // optional: tune unselected icon/text color
        onTap: _onItemTapped,
      ),
    );
  }
}


