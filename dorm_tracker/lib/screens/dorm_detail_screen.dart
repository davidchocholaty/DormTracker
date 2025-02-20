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

  Future<void> _loadPlaces() async {
    final fetchedPlaces = await DatabaseHelper.instance.fetchPlaces(widget.dorm.id!);
    setState(() {
      places = fetchedPlaces;
    });
  }

  Future<void> _addPlace(String placeName) async {
    try {
      await DatabaseHelper.instance.insertPlace(widget.dorm.id!, placeName);
      await _loadPlaces();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _editPlace(int index, String newPlaceName) async {
    try {
      final place = places[index];
      await DatabaseHelper.instance.updatePlace(widget.dorm.id!, place.name, newPlaceName);
      await _loadPlaces();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deletePlace(int index) async {
    final place = places[index];

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Place'),
          content: Text('Are you sure you want to delete the place "${place.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await DatabaseHelper.instance.deletePlace(widget.dorm.id!, place.name);
        await _loadPlaces();
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
                            onLongPress: () => _showEditPlaceDialog(place.name, index),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.2;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(top: topPadding),
        child: const AddEditPlaceScreen(),
      ),
    );

    if (result != null) {
      _addPlace(result);
    }
  }

  void _showEditPlaceDialog(String placeName, int index) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.2;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(top: topPadding),
        child: AddEditPlaceScreen(
          place: placeName,
          isEditing: true,
        ),
      ),
    );

    if (result != null) {
      if (result == 'delete') {
        _deletePlace(index);
      } else {
        _editPlace(index, result);
      }
    }
  }
}
