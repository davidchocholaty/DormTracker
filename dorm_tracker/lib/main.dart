import 'package:flutter/material.dart';
import 'package:dorm_tracker/screens/home_screen.dart';

void main() {
  runApp(const DormTrackerApp());
}

class DormTrackerApp extends StatelessWidget {
  const DormTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DormTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
