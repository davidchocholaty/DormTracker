import 'package:flutter/material.dart';
import 'package:dorm_tracker/database_helper.dart';
import 'package:dorm_tracker/screens/add_edit_item_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String dormName;
  final int placeId;
  final String placeName;

  const PlaceDetailScreen({super.key, required this.dormName, required this.placeId, required this.placeName});

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
    final fetchedItems = await DatabaseHelper.instance.fetchItems(widget.placeId);
    setState(() {
      items = fetchedItems;
    });
  }

  // Add a new item
  Future<void> _addItem(String itemName) async {
    try {
      await DatabaseHelper.instance.insertItem(widget.placeId, itemName, 0);
      await _loadItems();
    } catch (e) {
      // Cast e to Exception if it's an Exception
      String errorMessage = (e is Exception) ? e.toString() : 'An unexpected error occurred';
      
      if (mounted) {
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  // Edit an existing item in the database
  Future<void> _editItem(int index, String newItemName) async {
    try {
      await DatabaseHelper.instance.updateItemName(widget.placeId, items[index]['name'], newItemName);
      await _loadItems();
    } catch (e) {
      // Cast e to Exception if it's an Exception
      String errorMessage = (e is Exception) ? e.toString() : 'An unexpected error occurred';
      
      if (mounted) {
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  // Show error snack bar
  void _showErrorSnackBar(String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.amber, // Amber color for warning
      duration: const Duration(seconds: 3),
    ),
  );
}

  // Update item count
  Future<void> _updateItemCount(int index, int newCount) async {
    await DatabaseHelper.instance.updateItemCount(widget.placeId, items[index]['name'], newCount);
    await _loadItems();
  }

  // Delete an item
  Future<void> _deleteItem(int index) async {
    String itemName = items[index]["name"];
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete the item "$itemName"?'),
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
      await DatabaseHelper.instance.deleteItem(widget.placeId, itemName);
      await _loadItems();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item "$itemName" deleted successfully.')));
    }
  }

  // Edit item count dialog
  Future<void> _editItemCount(int index) async {
    TextEditingController controller = TextEditingController(text: items[index]['count'].toString());

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
              onPressed: () => Navigator.pop(context),
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
      appBar: AppBar(title: Text("${widget.dormName} - ${widget.placeName}")),
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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No items added yet. Add some!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _showAddItemDialog,
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
                                    onPressed: items[index]['count'] > 0
                                        ? () {
                                            _updateItemCount(index, items[index]['count'] - 1);
                                          }
                                        : null, // Disable when count is 0
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
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.height * 0.2,
                                      ),
                                      child: AddEditItemScreen(
                                        itemName: items[index]['name'],
                                        isEditing: true,
                                      ),
                                    );
                                  },
                                );

                                if (result != null) {
                                  if (result == 'delete') {
                                    _deleteItem(index); // Delete item
                                  } else {
                                    _editItem(index, result); // Edit item
                                  }
                                }
                              },
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
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showAddItemDialog,
              child: const Icon(Icons.add),
            ),
    );
  }

  // Show add item dialog
  void _showAddItemDialog() async {
    TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.2,
          ),
          child: AlertDialog(
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
          ),
        );
      },
    );

    if (result != null) {
      _addItem(result);
    }
  }
}
