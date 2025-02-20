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
      await DatabaseHelper.instance.insertDorm(dorm);
      await _loadDorms();
    } catch (e) {
      _showError(e);
    }
  }

  // Edit a dorm's name in the database
  Future<void> _editDorm(int index, Dorm dorm) async {
    try {
      await DatabaseHelper.instance.updateDorm(dorm);
      await _loadDorms();
    } catch (e) {
      _showError(e);
    }
  }

  // Delete a dorm from the database with confirmation
  Future<void> _deleteDorm(int index) async {
    String dormName = dorms[index].name;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Dorm'),
          content: Text('Are you sure you want to delete the dorm "$dormName"? This action cannot be undone.'),
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
        await DatabaseHelper.instance.deleteDorm(dorms[index].id!);
        await _loadDorms();
        _showSnackBar('Dorm "$dormName" deleted successfully.');
      } catch (e) {
        _showError(e);
      }
    }
  }

  // Show dialog for adding or editing a dorm
  Future<void> _showAddEditDormDialog({Dorm? dorm, bool isEditing = false}) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.2; // 20% of the screen height

    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.only(top: topPadding),
        child: AddEditDormScreen(
          dorm: dorm,
          isEditing: isEditing,
        ),
      ),
    );

    if (result != null) {
      if (result == 'delete') {
        if (dorm != null) _deleteDorm(dorms.indexWhere((d) => d.id == dorm.id));
      } else if (isEditing) {
        _editDorm(dorms.indexWhere((d) => d.id == dorm?.id), result);
      } else {
        _addDorm(result);
      }
    }
  }

  void _showError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              'Your Dorms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () => _showAddEditDormDialog(),
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
                        itemCount: dorms.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onLongPress: () => _showAddEditDormDialog(
                              dorm: dorms[index],
                              isEditing: true,
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(dorms[index].name),
                                onTap: () {
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
              )
          ],
        ),
      ),
      floatingActionButton: dorms.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddEditDormDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }
}
