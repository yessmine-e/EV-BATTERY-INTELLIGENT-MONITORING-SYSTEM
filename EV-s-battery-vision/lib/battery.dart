import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BatteryScreen extends StatefulWidget {
  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Battery Status',style: TextStyle(color: Colors.green[100], fontWeight: FontWeight.bold,),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,

      ),
      body: Stack(
        children: [

          // 1) Fullscreen background image
          Positioned.fill(
            child: Image.asset(
              'assets/176_1675695780.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2) Semi‑transparent overlay to darken for contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          // 3) Optional blur (tunes readability)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 4) Your tiles in a ListView
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<BatteryData>(
                stream: _dbService.getBatteryData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return ListView(
                    children: [
                      _buildTile('SOC (State of Charge)', '${data.soc}%',
                        color: Colors.white,
                        icon: Icons.battery_charging_full,),
                      _buildTile(
                        'Battery Type', data.batteryType, color: Colors.white,
                        icon: Icons.battery_1_bar,),
                      _buildTile(
                        'Charging Duration', '${data.chargingDuration} min',
                        color: Colors.white, icon: Icons.av_timer,),
                      _buildTile('SOH (State of Health)', '${data.soh}%',
                        color: Colors.white, icon: Icons.health_and_safety,),
                      _buildTile('Charging Cycles', '${data.chargingCycles}',
                        color: Colors.white,
                        icon: Icons.electrical_services_sharp,),
                      _buildTile(
                        'Current', '${data.current} A', color: Colors.white,
                        icon: Icons.electric_bolt,),
                      _buildTile(
                        'Battery Temperature', '${data.batteryTemp} °C',
                        color: Colors.white, icon: Icons.device_thermostat,),
                      _buildTile(
                        'Voltage', '${data.voltage} V', color: Colors.white,
                        icon: Icons.electric_bolt,),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String title, String value,
      {required Color color, required IconData icon}) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        trailing: Text(
            value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class BatteryData {
  final double batteryTemp;
  final String batteryType;  // New field for SOH

  final int chargingCycles;
  final double chargingDuration;

  final double current;
  final double soc;
  final double voltage;
  final double soh;


  BatteryData({
    required this.batteryTemp,
    required this.batteryType,

    required this.chargingCycles,
    required this.chargingDuration,

    required this.current,
    required this.soc,
    required this.voltage,
    required this.soh,
  });

  factory BatteryData.fromMap(Map<dynamic, dynamic> map) {
    return BatteryData(
      batteryTemp: map['BatteryTemp']?.toDouble() ?? 0.0,
      batteryType: map['BatteryType']?.toString() ?? "",

      chargingCycles: map['ChargingCycles']?.toInt() ?? 0,
      chargingDuration: map['ChargingDuration']?.toDouble() ?? 0.0,

      current: map['Current']?.toDouble() ?? 0.0,
      soc: map['SOC']?.toDouble() ?? 0.0,
      voltage: map['Voltage']?.toDouble() ?? 0.0,

      soh: map['SOH']?.toDouble() ?? 0.0, // Add this key in Firebase
    );
  }
}

class DatabaseService {
  final DatabaseReference _ref =  FirebaseDatabase.instance.ref('battery-data');
  Stream<BatteryData> getBatteryData() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return BatteryData.fromMap(data);
    });
  }
}