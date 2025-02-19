import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/screens/add_edit_dorm_screen.dart';
import 'package:dorm_tracker/screens/dorm_detail_screen.dart';
import 'package:dorm_tracker/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Dorm> dorms = [];

  @override
  void initState() {
    super.initState();
    _loadDorms();
  }

  // Load dorms from the database
  Future<void> _loadDorms() async {
    final fetchedDorms = await DatabaseHelper.instance.fetchDorms();
    setState(() {
      dorms = fetchedDorms;
    });
  }

  // Add a new dorm to the database
  Future<void> _addDorm(Dorm dorm) async {
    try {
      // Try to add the dorm to the database
      await DatabaseHelper.instance.insertDorm(dorm);

      // Reload the list of dorms after successfully adding the dorm
      await _loadDorms();
    } catch (e) {
      // Handle error when dorm name already exists
      if (e is Exception) {
        String errorMessage = e.toString();

        // Show warning SnackBar with amber color
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

  // Edit a dorm's name in the database
  Future<void> _editDorm(int index, Dorm dorm) async {
    try {
      // Try to update the dorm in the database
      await DatabaseHelper.instance.updateDorm(dorm);

      // Reload the list of dorms after successfully editing the dorm
      await _loadDorms();
    } catch (e) {
      // Handle error when dorm name already exists
      if (e is Exception) {
        String errorMessage = e.toString();

        // Show warning SnackBar with amber color
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

  // Delete a dorm from the database
  Future<void> _deleteDorm(int index) async {
    await DatabaseHelper.instance.deleteDorm(dorms[index].id!);
    await _loadDorms(); // Reload dorms after deleting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DormTracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Dorms:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Use a nice font
              ),
            ),
            const SizedBox(height: 20),
            if (dorms.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'There are no dorms yet. Please add a dorm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => const AddEditDormScreen(),
                          );
                          if (result != null) {
                            _addDorm(result);
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
                  itemCount: dorms.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          builder: (context) => AddEditDormScreen(
                            dorm: dorms[index],
                            isEditing: true,
                          ),
                        );
                        if (result != null) {
                          if (result == 'delete') {
                            _deleteDorm(index);
                          } else {
                            _editDorm(index, result);
                          }
                        }
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(dorms[index].name),
                          onTap: () {
                            // Navigate to DormDetailScreen with the selected dorm
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DormDetailScreen(dorm: dorms[index]),
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
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: dorms.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  builder: (context) => const AddEditDormScreen(),
                );
                if (result != null) {
                  _addDorm(result);
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
