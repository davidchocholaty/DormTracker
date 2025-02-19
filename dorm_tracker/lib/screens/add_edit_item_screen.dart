import 'package:flutter/material.dart';

class AddEditItemScreen extends StatefulWidget {
  final String? itemName;
  final bool isEditing;

  const AddEditItemScreen({super.key, this.itemName, this.isEditing = false});

  @override
  AddEditItemScreenState createState() => AddEditItemScreenState();
}

class AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _itemName;

  @override
  void initState() {
    super.initState();
    _itemName = widget.itemName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing ? 'Edit Item' : 'Add Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _itemName,
                        decoration: const InputDecoration(labelText: 'Item Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _itemName = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                Navigator.of(context).pop(_itemName);
                              }
                            },
                            child: Text(widget.isEditing ? 'Save' : 'Add'),
                          ),
                          if (widget.isEditing)
                            const SizedBox(width: 10),
                          if (widget.isEditing)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop('delete');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
