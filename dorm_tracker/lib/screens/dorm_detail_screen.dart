import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/models/place.dart';
import 'package:dorm_tracker/screens/add_edit_place_screen.dart';
import 'package:dorm_tracker/screens/place_detail_screen.dart';
import 'package:dorm_tracker/database_helper.dart';

class DormDetailScreen extends StatefulWidget {
  final Dorm dorm;

  const DormDetailScreen({super.key, required this.dorm});

  @override
  DormDetailScreenState createState() => DormDetailScreenState();
}

class DormDetailScreenState extends State<DormDetailScreen> {
  late List<Place> places;

  @override
  void initState() {
    super.initState();
    places = [];
    _loadPlaces();
  }

  // Fetch places from the database
  Future<void> _loadPlaces() async {
    final fetchedPlaces = await DatabaseHelper.instance.fetchPlaces(widget.dorm.id!);
    setState(() {
      places = fetchedPlaces; // No need to map, as fetchedPlaces is already List<Place>
    });
  }

  // Add a new place to the database
  Future<void> _addPlace(String placeName) async {
    try {
      await DatabaseHelper.instance.insertPlace(widget.dorm.id!, placeName);
      await _loadPlaces();
    } catch (e) {
      _showError(e);
    }
  }

  // Edit an existing place in the database
  Future<void> _editPlace(int index, String newPlaceName) async {
    try {
      final place = places[index];
      await DatabaseHelper.instance.updatePlace(widget.dorm.id!, place.name, newPlaceName);
      await _loadPlaces();
    } catch (e) {
      _showError(e);
    }
  }

  // Delete a place from the database
  Future<void> _deletePlace(int index) async {
    final place = places[index];

    // Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Place'),
          content: Text('Are you sure you want to delete the place "${place.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If user confirmed, delete the place
    if (confirmDelete == true) {
      try {
        await DatabaseHelper.instance.deletePlace(widget.dorm.id!, place.name);
        await _loadPlaces(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Place "${place.name}" deleted successfully.')),
          );
        }
      } catch (e) {
        _showError(e);
      }
    }
  }

  // Display error message
  void _showError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
      ),
    );
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
              'Places in ${widget.dorm.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
                        onPressed: _showAddPlaceDialog,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return GestureDetector(
                            onLongPress: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                builder: (context) => AddEditPlaceScreen(
                                  place: place.name,
                                  isEditing: true,
                                ),
                              );
                              if (result != null) {
                                if (result == 'delete') {
                                  _deletePlace(index);
                                } else {
                                  _editPlace(index, result);
                                }
                              }
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(place.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetailScreen(
                                        dormName: widget.dorm.name,
                                        placeId: place.id,
                                        placeName: place.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tap to view details, hold to modify',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    ],
                  ),
                )
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

  void _showAddPlaceDialog() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => const AddEditPlaceScreen(),
    );
    if (result != null && result is String) {
      _addPlace(result);
    }
  }
}
