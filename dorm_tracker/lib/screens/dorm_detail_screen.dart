import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
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
    try {
      await DatabaseHelper.instance.insertPlace(widget.dorm.id!, place);
      await _loadPlaces(); // Reload the list of places
    } catch (e) {
      // Show a warning SnackBar if the exception is thrown
      if (e is Exception) {
        String errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.amber, // Amber color for warning
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred"),
            backgroundColor: Colors.red, // Red background for errors
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Edit an existing place in the database
  Future<void> _editPlace(int index, String newPlace) async {
    try {
      await DatabaseHelper.instance.updatePlace(widget.dorm.id!, places[index], newPlace);
      await _loadPlaces(); // Reload the list of places
    } catch (e) {
      // Show a warning SnackBar if the exception is thrown
      if (e is Exception) {
        String errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.amber, // Amber color for warning
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Handle unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred"),
            backgroundColor: Colors.red, // Red background for errors
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Delete a place from the database
  Future<void> _deletePlace(int index) async {
    await DatabaseHelper.instance.deletePlace(widget.dorm.id!, places[index]);
    await _loadPlaces(); // Reload the list of places
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
                          onTap: () {
                            // Navigate to PlaceDetailScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceDetailScreen(
                                  dormName: widget.dorm.name,
                                  placeName: places[index],
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
