import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/screens/add_edit_place_screen.dart';

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
  }

  void _addPlace(String place) {
    setState(() {
      places.add(place);
    });
  }

  void _editPlace(int index, String place) {
    setState(() {
      places[index] = place;
    });
  }

  void _deletePlace(int index) {
    setState(() {
      places.removeAt(index);
    });
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
              'Places in ${widget.dorm.name}:',
              style: const TextStyle(
                fontSize: 28,
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
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => const AddEditPlaceScreen(),
                          );
                          if (result != null && result is String) {
                            _addPlace(result);
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
                            _deletePlace(index);
                          } else {
                            _editPlace(index, result);
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
                  _addPlace(result);
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
