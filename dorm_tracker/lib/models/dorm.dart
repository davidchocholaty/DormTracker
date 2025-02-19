import 'package:dorm_tracker/models/place.dart';

class Dorm {
  final int? id;
  final String name;
  final List<Place> places;

  Dorm({this.id, required this.name, this.places = const []});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
