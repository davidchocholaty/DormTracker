import 'package:flutter/material.dart';
import 'package:dorm_tracker/models/dorm.dart';

class AddEditDormScreen extends StatefulWidget {
  final Dorm? dorm;
  final bool isEditing;

  const AddEditDormScreen({super.key, this.dorm, this.isEditing = false});

  @override
  AddEditDormScreenState createState() => AddEditDormScreenState();
}

class AddEditDormScreenState extends State<AddEditDormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.dorm?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Optional: max width for larger screens
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing ? 'Edit Dorm' : 'Add Dorm',
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
                        initialValue: _name,
                        decoration: const InputDecoration(labelText: 'Dorm Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
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
                                // If editing, preserve the existing dorm id
                                final updatedDorm = Dorm(
                                  id: widget.dorm?.id,  // Preserve the existing id when editing
                                  name: _name,
                                );
                                Navigator.of(context).pop(updatedDorm);
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
