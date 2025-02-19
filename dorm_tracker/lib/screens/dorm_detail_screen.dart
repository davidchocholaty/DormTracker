import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';

class DormDetailScreen extends StatefulWidget {
  final Dorm dorm;

  const DormDetailScreen({super.key, required this.dorm});

  @override
  DormDetailScreenState createState() => DormDetailScreenState();
}

class DormDetailScreenState extends State<DormDetailScreen> {
  late List<String> places;

  @override
  void initState() {
    super.initState();
    places = List.from(widget.dorm.places); // Copy to allow modifications
  }

  void _addPlace(String place) {
    setState(() {
      places.add(place);
    });
  }

  void _deletePlace(int index) {
    setState(() {
      places.removeAt(index);
    });
  }

  void _showAddPlaceDialog() {
    String newPlace = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a new place"),
        content: TextField(
          onChanged: (value) => newPlace = value,
          decoration: const InputDecoration(hintText: "Enter place name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (newPlace.isNotEmpty) {
                _addPlace(newPlace);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dorm.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Places in ${widget.dorm.name}:',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (places.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No places added yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _showAddPlaceDialog,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text(places[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePlace(index),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Tap "+" to add a place',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: places.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showAddPlaceDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}
