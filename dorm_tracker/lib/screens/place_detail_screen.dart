import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {
  final String dormName;
  final String placeName;

  const PlaceDetailScreen({super.key, required this.dormName, required this.placeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Place: $placeName',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Located in: $dormName',
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
