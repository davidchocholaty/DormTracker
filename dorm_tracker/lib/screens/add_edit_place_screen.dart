import 'package:flutter/material.dart';

class AddEditPlaceScreen extends StatefulWidget {
  final String? place;
  final bool isEditing;

  const AddEditPlaceScreen({super.key, this.place, this.isEditing = false});

  @override
  AddEditPlaceScreenState createState() => AddEditPlaceScreenState();
}

class AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _placeName;

  @override
  void initState() {
    super.initState();
    _placeName = widget.place ?? '';
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
                  widget.isEditing ? 'Edit Place' : 'Add Place',
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
                        initialValue: _placeName,
                        decoration: const InputDecoration(labelText: 'Place Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _placeName = value!;
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
                                Navigator.of(context).pop(_placeName);
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
