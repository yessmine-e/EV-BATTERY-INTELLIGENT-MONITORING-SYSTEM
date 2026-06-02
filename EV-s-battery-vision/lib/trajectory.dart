import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Trajectory extends StatefulWidget {
  @override
  _TrajectoryState createState() => _TrajectoryState();
}

class _TrajectoryState extends State<Trajectory> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text('Route Map', style: TextStyle(
        color: Colors.green[100], fontWeight: FontWeight.bold,),),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

          // 3) Blur (tunes readability)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.transparent),
            ),
          ),
          // 4) Data display
          Positioned.fill(
            child: StreamBuilder<BatteryData>(
              stream: _dbService.getBatteryData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                // Get battery type
                final String type = data.batteryType.toLowerCase();
                // Default values
                double batteryCapacity = 60.0; // in kWh
                double kmPerKWh = 5.5;

                // Set based on chemistry
                if (type.contains("lifepo4")) {
                  batteryCapacity = 50.0;
                  kmPerKWh = 5.2;
                } else if (type.contains("li-ion")) {
                  batteryCapacity = 60.0;
                  kmPerKWh = 5.8;
                }
                // Estimate usable energy
                final double usableEnergyKWh =(data.soc / 100) * ((type.contains("lifepo4")) ? 1.0 : data.soh / 100) * batteryCapacity;
                // Estimate distance
                final double estimatedKm = usableEnergyKWh * kmPerKWh;
                // Power estimation
                final double powerKW = (data.voltage * data.current) / 1000;
                // Time ranges (in hours)
                final double timeMin = usableEnergyKWh / (powerKW * 1.2);
                final double timeMax = usableEnergyKWh / (powerKW * 0.6);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🚗 The trajectory you can still go:",
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${estimatedKm.toStringAsFixed(1)} km",
                        style: TextStyle(fontSize: 32,
                            color: Colors.green[200],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "⏳ Estimated Time Remaining:",
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      _buildTile('- Min', '${timeMin.toStringAsFixed(2)} h', color: Colors.white70,),
                      _buildTile('- Max', '${timeMax.toStringAsFixed(2)} h', color: Colors.white70,),

                      SizedBox(height: 30),
                      Divider(color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        "📊 View More Details",
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      _buildTile('SOC (for the next hour)', '${data.socForecast.toStringAsFixed(1)}%', color: Colors.white70,),
                      _buildTile('SOH (for the next hour)', '${data.sohForecast.toStringAsFixed(1)}%', color: Colors.white70,),
                      _buildTile('RUL', '${data.rul.toStringAsFixed(1)} cycles', color: Colors.white70,),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTile(String title, String value,
      {required Color color}) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
            title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        trailing: Text(
            value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}


class BatteryData {
  final double batteryTemp;
  final String batteryType;  // New field for SOH
  final double current;
  final double soc;
  final double voltage;
  final double soh;

  final double socForecast;
  final double sohForecast;
  final int rul;

  BatteryData({
    required this.batteryTemp,
    required this.batteryType,
    required this.current,
    required this.soc,
    required this.voltage,
    required this.soh,

    required this.socForecast,
    required this.sohForecast,
    required this.rul,
  });

  factory BatteryData.fromMap(Map<dynamic, dynamic> map) {
    final forecast = map['Forecast'] ?? {};
    return BatteryData(
      batteryTemp: map['BatteryTemp']?.toDouble() ?? 0.0,
      batteryType: map['BatteryType']?.toString() ?? "",

      current: map['Current']?.toDouble() ?? 0.0,
      soc: map['SOC']?.toDouble() ?? 0.0,
      voltage: map['Voltage']?.toDouble() ?? 0.0,
      soh: map['SOH']?.toDouble() ?? 0.0, // Add this key in Firebase

      socForecast: forecast['SOC_1h']?.toDouble() ?? 0.0,
      sohForecast: forecast['SOH_1h']?.toDouble() ?? 0.0,
      rul: forecast['RUL']?.toInt() ?? 0,

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