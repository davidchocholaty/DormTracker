import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/screens/add_edit_place_screen.dart';
import 'package:dorm_tracker/database_helper.dart';

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
    places = List.from(widget.dorm.places); // Initialize from dorm's places
    _loadPlaces(); // Load places from the database when the screen is initialized
  }

  // Fetch places from the database
  Future<void> _loadPlaces() async {
    final fetchedPlaces = await DatabaseHelper.instance.fetchPlaces(widget.dorm.id!);
    setState(() {
      places = fetchedPlaces;
    });
  }

  // Add a new place to the database
  Future<void> _addPlace(String place) async {
    await DatabaseHelper.instance.insertPlace(widget.dorm.id!, place);
    _loadPlaces(); // Reload the list of places
  }

  // Edit an existing place in the database
  Future<void> _editPlace(int index, String newPlace) async {
    await DatabaseHelper.instance.updatePlace(widget.dorm.id!, places[index], newPlace);
    _loadPlaces(); // Reload the list of places
  }

  // Delete a place from the database
  Future<void> _deletePlace(int index) async {
    await DatabaseHelper.instance.deletePlace(widget.dorm.id!, places[index]);
    _loadPlaces(); // Reload the list of places
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dorm.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Dorm - ${widget.dorm.name}:',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Check if the list is empty
            if (places.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No places added yet. Add a place!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => const AddEditPlaceScreen(),
                          );
                          if (result != null && result is String) {
                            _addPlace(result); // Add the new place
                          }
                        },
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
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          builder: (context) => AddEditPlaceScreen(
                            place: places[index],
                            isEditing: true,
                          ),
                        );
                        if (result != null) {
                          if (result == 'delete') {
                            _deletePlace(index); // Delete place
                          } else {
                            _editPlace(index, result); // Edit place
                          }
                        }
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(places[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Hold card to modify',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: places.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  builder: (context) => const AddEditPlaceScreen(),
                );
                if (result != null && result is String) {
                  _addPlace(result); // Add the new place
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
