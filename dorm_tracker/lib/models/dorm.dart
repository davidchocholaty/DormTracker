class Dorm {
  final String name;
  final List<String> places; // List of places in the dorm

  Dorm({required this.name, List<String>? places}) : places = places ?? [];

  // Convert Dorm to a Map (useful for storage like databases)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'places': places,
    };
  }

  // Create a Dorm from a Map (useful for storage)
  factory Dorm.fromJson(Map<String, dynamic> json) {
    return Dorm(
      name: json['name'],
      places: List<String>.from(json['places'] ?? []),
    );
  }
}
