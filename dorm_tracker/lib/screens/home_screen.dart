import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/screens/add_edit_dorm_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Dorm> dorms = [];

  void _addDorm(Dorm dorm) {
    setState(() {
      dorms.add(dorm);
    });
  }

  void _editDorm(int index, Dorm dorm) {
    setState(() {
      dorms[index] = dorm;
    });
  }

  void _deleteDorm(int index) {
    setState(() {
      dorms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DormTracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Dorms:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Use a nice font
              ),
            ),
            SizedBox(height: 20),
            if (dorms.isEmpty) 
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'There are no dorms yet. Please add a dorm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            builder: (context) => AddEditDormScreen(),
                          );
                          if (result != null) {
                            _addDorm(result);
                          }
                        },
                        child: Icon(Icons.add),
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(
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
                builder: (context) => AddEditDormScreen(),
              );
              if (result != null) {
                _addDorm(result);
              }
            },
            child: Icon(Icons.add),
          ),
    );
  }
}
