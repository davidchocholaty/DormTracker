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
    await DatabaseHelper.instance.insertDorm(dorm);
    _loadDorms(); // Reload dorms after adding
  }

  // Edit a dorm's name in the database
  Future<void> _editDorm(int index, Dorm dorm) async {
    await DatabaseHelper.instance.updateDorm(dorm);
    _loadDorms(); // Reload dorms after editing
  }

  // Delete a dorm from the database
  Future<void> _deleteDorm(int index) async {
    await DatabaseHelper.instance.deleteDorm(dorms[index].id!);
    _loadDorms(); // Reload dorms after deleting
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
              'Hold card to modify',
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
