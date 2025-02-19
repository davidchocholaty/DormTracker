import 'package:flutter/material.dart';
import 'package:dorm_tracker/database_helper.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String dormName;
  final String placeName;

  const PlaceDetailScreen({super.key, required this.dormName, required this.placeName});

  @override
  PlaceDetailScreenState createState() => PlaceDetailScreenState();
}

class PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late List<Map<String, dynamic>> items; // List of items with name & count

  @override
  void initState() {
    super.initState();
    items = []; // Initialize empty list
    _loadItems(); // Load from database
  }

  // Fetch items for this place from the database
  Future<void> _loadItems() async {
    final fetchedItems = await DatabaseHelper.instance.fetchItems(widget.placeName);
    setState(() {
      items = fetchedItems;
    });
  }

  // Add a new item
  Future<void> _addItem(String itemName) async {
    try {
      // Try to add the item to the database
      await DatabaseHelper.instance.insertItem(widget.placeName, itemName, 0);

      // Reload list after successfully adding the item
      await _loadItems();
    } catch (e) {
      // Handle error when item already exists
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

  // Update item count
  Future<void> _updateItemCount(int index, int newCount) async {
    await DatabaseHelper.instance.updateItemCount(widget.placeName, items[index]['name'], newCount);
    await _loadItems(); // Reload items from database
  }

  // Delete an item
  Future<void> _deleteItem(int index) async {
    await DatabaseHelper.instance.deleteItem(widget.placeName, items[index]['name']);
    await _loadItems(); // Reload list
  }

  // Open dialog to manually edit count
  Future<void> _editItemCount(int index) async {
    TextEditingController controller =
        TextEditingController(text: items[index]['count'].toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Count"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Enter new count"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                int? newValue = int.tryParse(controller.text);
                if (newValue != null && newValue >= 0) {
                  Navigator.pop(context, newValue);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      _updateItemCount(index, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.placeName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Items in ${widget.placeName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              const Center(
                child: Text("No items added yet. Add some!", style: TextStyle(color: Colors.grey)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(items[index]['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: (items[index]['count'] > 0) 
                                ? () {
                                    _updateItemCount(index, items[index]['count'] - 1);
                                  } 
                                : null, // Disable button when count is 0
                            ),
                            GestureDetector(
                              onTap: () => _editItemCount(index), // Open manual edit dialog
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  items[index]['count'].toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _updateItemCount(index, items[index]['count'] + 1),
                            ),
                          ],
                        ),
                        onLongPress: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Delete Item"),
                                content: Text("Are you sure you want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            _deleteItem(index);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          TextEditingController controller = TextEditingController();

          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add New Item"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Item name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.pop(context, controller.text.trim());
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );

          if (result != null) {
            _addItem(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
